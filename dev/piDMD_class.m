classdef piDMD_class < matlab.System 
  properties
    %% class
    cName       = 'piDMD'
    note        = ''
    %% features
    %% cfg (argin)
    
    %% dat (argin)
    dat % dat 
    delT
    nVars % x and dx from raw data
    nSamps
    st_frame
    end_frame
    %% properties
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

  end
  methods % constructor
    
    function obj = piDMD_class(varargin) 
      setProperties(obj,nargin,varargin{:}) % init obj w name-value args
    end 

  end % methods % constructor
  methods (Access = public) 
    
    function load_cfg(obj, cfg) 
      obj.delT        = cfg.dat.delT;  
      obj.nVars       = cfg.dat.nVars;  
      obj.nSamps      = cfg.dat.nSamps;       
      obj.st_frame    = cfg.dat.st_frame;   
      obj.end_frame   = cfg.dat.end_frame; 

      obj.init();
      obj.load_dat(cfg.dat.dat);
    end

    function m = est(obj, X, Y, label, piDMD_label)
      [A,vals] = piDMD(X, Y, piDMD_label); % est
      rec = zeros(obj.nVars, obj.nSamps); % reconstruct dat
      rec(:,1) = obj.dat(:,1); 
      for j = 2:obj.nSamps
        rec(:,j) = A(rec(:,j-1));
      end
      m = model_class(label,A,vals,rec); % create model obj
    end
  
  end 
  methods  (Access = private)
    function init(obj)
      obj.nss       = obj.nVars/2;
      obj.nTrain    = obj.nSamps - 1; 
      obj.x_cols    = 1:obj.nss; 
      obj.xd_cols   = obj.nss+1:obj.nVars; 
      obj.tspan     = obj.delT*obj.nSamps;
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
      yticks([-pi/4,0,pi/4]); yticklabels([{'$-\pi/4$'},{'0'},{'$\pi/4$'}])
      set(gca,'TickLabelInterpreter','Latex','FontSize',20);grid on
      ylim([-1,1])
      ylabel(j,'Interpreter','latex','FontSize',20)
    end
  end
end
 



  
  