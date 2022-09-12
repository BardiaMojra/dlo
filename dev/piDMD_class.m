classdef piDMD_class < matlab.System 
  properties
    %% class
    cName       = "piDMD" % Physics-informed dynamic mode decompositions
    desc        = ["Computes a dynamic mode decomposition when the solution " ...
      "matrix is constrained to lie in a matrix manifold. The options " ...
      "availablefor the 'method' so far are listed are 'mthd' property."]
    credit      = ""
    %% cfg (argin)
    toutDir
    %% dat (argin)
    dat % dat 
    dt
    nVars % x and dx from raw data
    nSamps
    st_frame
    end_frame
    %% dat n state 
    nss % x state vars (dont include dx)
    x_cols
    xd_cols
    x % states
    xd % state derivative 
    ndat % dat normalized 
    nTrain % num training samps
    tspan
    X % state in ss 
    Y % state est 
    %% piDMD methods (const)
    mthds   = ["exact", "exactSVDS", ...
               "orthogonal", ...
               "uppertriangular", "lowertriangular" , ... % 
               "diagonal", "diagonalpinv", "diagonaltls", "symtridiagonal", ... 
               "circulant", "circulantTLS", "circulantunitary", "circulantsymmetric","circulantskewsymmetric", ...
               "BCCB", "BCCBtls", "BCCBskewsymmetric", "BCCBunitary", "hankel", "toeplitz", ...
               "symmetric", "skewsymmetric"]
  end
  methods % constructor
    
    function obj = piDMD_class(varargin) 
      setProperties(obj,nargin,varargin{:}) % init obj w name-value args
    end 

  end % methods % constructor
  methods (Access = public) 
    
    function load_cfg(obj, cfg) 
      obj.toutDir     = cfg.toutDir;
      obj.dt          = cfg.dat.dt;  
      obj.nVars       = cfg.dat.nVars;  
      obj.nSamps      = cfg.dat.nSamps;       
      obj.st_frame    = cfg.dat.st_frame;   
      obj.end_frame   = cfg.dat.end_frame; 

      obj.init();
      obj.load_dat(cfg.dat.dat);
    end

    function m = est(obj, X, Y, piDMD_label, varargin)
      [A,vals] = piDMD(X, Y, piDMD_label, varargin{:}); % est
      rec = zeros(obj.nVars, obj.nSamps); % reconstruct dat
      rec(:,1) = obj.dat(:,1); 
      for j = 2:obj.nSamps
        rec(:,j) = A(rec(:,j-1));
      end
      
      m = model_class(name    = strcat("piDMD ", piDMD_label), ...
                      mthd    = "piDMD", ...
                      A_mdl   = A, ...
                      vals    = vals, ...
                      rec     = rec, ...
                      toutDir = obj.toutDir); % create model obj
    end
  
  end 
  methods  (Access = private)
    function init(obj)
      obj.nss       = obj.nVars/2;
      obj.nTrain    = obj.nSamps - 1; 
      obj.x_cols    = 1:obj.nss; 
      obj.xd_cols   = obj.nss+1:obj.nVars; 
      obj.tspan     = obj.dt*obj.nSamps;
    end
    function load_dat(obj, dat)
      assert(isequal(mod(size(dat,2),2),0), ...
        "-->>> odd num of state vars: %d", size(dat,2));
      obj.x       = dat(:,obj.x_cols); % state vars 
      obj.xd      = dat(:,obj.xd_cols); % state vars time derivative (vel)
      obj.dat     = [obj.x'; obj.xd']; % reorganize data in state space (ss) formulation 
      obj.ndat    = obj.dat + 1e-1*std(obj.dat,[],2); % norm dat
      obj.X       = obj.dat(:,1:obj.nTrain);
      obj.Y       = obj.dat(:,2:obj.nTrain+1);
    end

    function trajPlot(~,j) % Nice plot of trajectories
      yticks([-pi/4,0,pi/4]); yticklabels([{"$-\pi/4$"},{"0"},{"$\pi/4$"}])
      set(gca,"TickLabelInterpreter","Latex","FontSize",20);grid on
      ylim([-1,1])
      ylabel(j,"Interpreter","latex","FontSize",20)
    end
  end
end
 



  
  