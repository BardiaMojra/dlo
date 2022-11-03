classdef HAVOK_class < matlab.System 
  properties
    %% class
    cName       = 'HAVOK'
    note        = ''
    %% features
    %% cfg.dat (argin)
    dat % dat 
    dt
    nVars % x and dx from raw data
    nSamps
    st_frame
    end_frame
    %% HAVOK config
    stackmax = 100 % the number of shift-stacked rows
    lambda = 0 % threshold for sparse regression (use 0.02 to kill terms)
    rmax = 15 % maximum singular vectors to include
    rec_len = 4000 % moving window len % 25% of dat
    polyorder = 1
    sin_bs_en = 0 
    use_opt_r = false % use optimal num of roots
    %% vars
    nss % 30 x state vars (dont include dx)
    xdat
    x_cols
    xd_cols
    x % states
    dx % (=V) -- time series
    r % optimal number of roots 
    Theta
    normTheta
    Xi
    A % mdl
    B % control input mapping 
    sys % recon ODE 
    y % reconstruction 
    t % (nSamps-1)*dt
    toutDir
  end
  methods % constructor
    function obj = HAVOK_class(varargin) 
      setProperties(obj,nargin,varargin{:}) % init obj w name-value args
    end 

  end % methods % constructor
  methods (Access = public) 
    
    function load_cfg(obj, cfg) 
      obj.dt          = cfg.dat.dt;  
      obj.nVars       = cfg.dat.nVars;  
      obj.nSamps      = cfg.dat.nSamps;       
      obj.st_frame    = cfg.dat.st_frame;   
      obj.end_frame   = cfg.dat.end_frame; 

      obj.init();
      obj.load_dat(cfg.dat.dat);
    end

    function m = est(obj, x, r, label)
      if ~isinteger(r); r = obj.r; else; obj.r = r; end

      %%  BUILD HAVOK REGRESSION MODEL ON TIME DELAY COORDINATES
      % This implementation uses the SINDY code, but least-squares works too
      % Build library of nonlinear time series
      obj.Theta = poolData(x,r,obj.polyorder,obj.sin_bs_en); 
      % normalize columns of Theta (required in new time-delay coords)
      for k=1:size(obj.Theta,2)
        obj.normTheta(k) = norm(obj.Theta(:,k));
        obj.Theta(:,k) = obj.Theta(:,k)/obj.normTheta(k);
      end 
      m = size(obj.Theta,2);
      % compute Sparse regression: sequential least squares
      % requires different lambda parameters for each column
      clear Xi
      for k = 1:r-1
        Xi(:,k) = sparsifyDynamics(obj.Theta,obj.dx(:,k),obj.lambda*k,1);  % lambda = 0 gives better results 
      end
      obj.Theta = poolData(x,r,obj.polyorder,obj.sin_bs_en);
      for k = 1:length(Xi)
        Xi(k,:) = Xi(k,:)/obj.normTheta(k);
      end
      obj.Xi = Xi;
      obj.A = obj.Xi(2:r+1, 1:r-1)'; % model A
      obj.B = obj.A(:,r);
      obj.A = obj.A(:,1:r-1);
      %
      L = 1:obj.nSamps-(obj.stackmax+5);
      obj.sys = ss(obj.A,obj.B,eye(r-1),0*obj.B);
      [obj.y, obj.t] = lsim(obj.sys,obj.x(L,r),obj.dt*(L-1),obj.x(1,1:r-1));
      m = model_class(name    = label, ...
                      mthd    = "HAVOK", ...
                      A_mdl   = obj.A, ...
                      vals    = [], ...
                      rec     = obj.y', ...
                      toutDir = obj.toutDir); % create model obj
    end
  
  end 
  methods  (Access = private)
    function init(obj)
      obj.nss       = obj.nVars/2;
      obj.x_cols    = 1:obj.nss; 
      obj.xd_cols   = obj.nss+1:obj.nVars; 
    end
    function load_dat(obj, dat)
      assert(isequal(mod(size(dat,2),2),0), ...
        "-->>> odd num of state vars: %d", size(dat,2));
      obj.xdat    = dat(:,obj.x_cols); % state vars (x) -- [nSamps * nVars]  
      %% EIGEN-TIME DELAY COORDINATES
      clear V, clear dV, clear histcounts2
      H = zeros(obj.stackmax,size(obj.xdat,1)-obj.stackmax);
      for k = 1:obj.stackmax
        H(k,:) = obj.xdat(k:end-obj.stackmax-1+k,1);
      end
      [U,S,V] = svd(H,'econ');
      sigs = diag(S);
      beta = size(H,1)/size(H,2);
      thresh = optimal_SVHT_coef(beta,0) * median(sigs);
      if obj.use_opt_r
        obj.r = length(sigs(sigs>thresh));
        obj.r = min(obj.rmax,obj.r);
      else
        obj.r = obj.nss+1;
      end
      %% COMPUTE DERIVATIVES
      % compute derivative using fourth order central difference
      % use TVRegDiff if more error 
      dV = zeros(length(V)-5,obj.r);
      for i=3:length(V)-3
        for k=1:obj.r
          dV(i-2,k) = (1/(12*obj.dt))*(-V(i+2,k)+8*V(i+1,k)-8*V(i-1,k)+V(i-2,k));
        end
      end  
      % concatenate
      obj.x = V(3:end-3,1:obj.r);
      obj.dx = dV;
    end % load_dat()
  end
end
 



  
  