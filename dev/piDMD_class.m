classdef piDMD_class < matlab.System 
  properties
    %% class
    cName       = 'piDMD'
    note        = ''
    %% features
    %% cfg (argin)
    
    %% dat (argin)
    delT
    dat % dat 
    nVars
    nSamps
    %% properties

    normDat % normalized data
    ssDat % dat in ss formulation X = [x; dx], Y = dX
    ssVars  % num of vars in ss 
    ssSamps % num samps in ss 
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
      obj.delT  = cfg.delT;
      %obj.init();
      obj.load_dat(cfg.dat)
    end

    function [A, vals, rec] = train(obj, X, Y, kernel)
      % Train models
      [piA, piVals] = piDMD(X, Y, kernel);

      % Perform reconstructions
      piRec       = zeros(size(obj.ssDat,1), obj.nSamps); 
      piRec(:,1)  = obj.ssDat(:,1);
      exRec       = zeros(size(obj.ssDat,1), obj.nSamps); 
      exRec(:,1)  = obj.ssDat(:,1);
      for j = 2:obj.nSamps
        piRec(:,j) = piA(piRec(:, j-1));
        exRec(:,j) = exA(exRec(:, j-1));
      end
      
      % Rescale reconstructions back into physical norm
      %fpiRec = C\piRec; 
      %fexRec = C\exRec;

      %% Plot results
      % Set number of samples and span
      tend = obj.nSamps*obj.delT; % get end time 
      nt = obj.nSamps;
      tspan= linspace(0, tend, nt);
      figure(1); 
      LW = 'LineWidth'; IN = 'Interpreter'; LT = 'Latex'; FS = 'FontSize';
      
      subplot(3,1,1)
      c1 = .8*[1 1 1]; c2 = .8*[1 1 1];
      plot(tspan, obj.normDat(1,:),LW,2,'Color',c1)
      hold on
      plot(tspan, obj.normDat(2,:),LW,2,'Color',c2)
      hold off; trajPlot('measurements'); xticklabels([])
      
      subplot(3,1,2)
      plot(tspan, obj.normDat(1,:),LW,3,'Color', c1)
      hold on
      plot(tspan, fpiRec(1,:),'b--',LW,2)
      plot(tspan, fexRec(1,:),'r--',LW,2)
      ylabel('$\theta_1$',IN,LT)
      hold off; trajPlot('$\theta_1$'); xticklabels([])
      
      subplot(3,1,3)
      l1=plot(t,x(2,:),LW,3,'Color', c2);
      hold on
      l2=plot(t,fpiRec(2,:),'b--',LW,2);
      l3=plot(t,fexRec(2,:),'r--',LW,2);
      hold off; xlabel('time',FS,20,IN,LT)
      trajPlot('$\theta_2$')
      legend([l1,l2,l3],{'truth','piDMD','exact DMD'},IN,LT)

      mod = fpiRec;
      obj.model = mod;
    end
  end 
  methods  (Access = private)
    %function init(obj)%end
    function load_dat(obj, dat)
      assert(isequal(mod(size(dat,2),2),0), ...
        "-->>> odd num of state vars: %d", size(dat,2));
      % Extract data
      obj.delT    = obj.delT;
      obj.nVars   = size(dat,2)/2;
      x_cols      = 1:obj.nVars; 
      xd_cols     = obj.nVars+1:obj.nVars*2; 
      obj.normDat      = dat + 1e-1*std(dat,[],2); % norm dat
      x           = obj.normDat(:,x_cols); % state vars 
      xd          = obj.normDat(:,xd_cols); % state vars time derivative (vel)
      obj.ssDat  = [x'; xd']; % reorganize data in state space (ss) formulation 
      obj.nSamps  = size(obj.normDat,1)-1;
      obj.X       = obj.ssDat(:,1:obj.nSamps);
      obj.Y       = obj.ssDat(:,2:obj.nSamps+1);
    end
  end
end
 

function trajPlot(j) % Nice plot of trajectories
  yticks([-pi/4,0,pi/4]); yticklabels([{'$-\pi/4$'},{'0'},{'$\pi/4$'}])
  set(gca,'TickLabelInterpreter','Latex','FontSize',20);grid on
  ylim([-1,1])
  ylabel(j,'Interpreter','latex','FontSize',20)
end

  
  