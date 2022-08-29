classdef dlogger_class < matlab.System 
  properties
    %% class
    class       = 'dlogger'
    note        = 'manages all data logs for uniform plotting and comparison.'
    %% features
    log_prt_en        = false
    log_sav_en        = true
    log_csv_sav_en    = true
    %% cfg (argin)
    TID
    ttag
    toutDir
    btype
    bnum
    dat % ground truth
    %% logs
    lcols = {'num', 'name', 'model', 'est', 'varNames'}
    logs  = cell(2,5) % num of logs by lcols
       
  end
  methods  % constructor
    function obj = dlogger_class(varargin)
      setProperties(obj,nargin,varargin{:})
    end
  end 
  methods (Access = public) 

    function load_cfg(obj, cfg)
      obj.TID               = cfg.TID; 
      obj.ttag              = cfg.ttag; 
      obj.toutDir           = cfg.toutDir; 
      obj.btype             = cfg.btype; 
      obj.bnum              = cfg.bnum; 
      obj.dat               = cfg.dat; 
      
           obj.logs{2,5}         = obj.dat.varNames; % 'varNames'
     
     
     
     
      obj.init();
      obj.logs{1,:}         = obj.lcols;
      obj.logs{2,1}         = 1; % 'num'
      obj.logs{2,2}         = 'ground truth'; % 'name'
      obj.logs{2,3}         = ; % 'model'
      obj.logs{2,4}         = obj.dat.dat; % 'est'
      obj.logs{2,5}         = obj.dat.varNames; % 'varNames'
      

    end
    
    function log_model(obj, mName, model, recon, varNames)
      nLogs = size(obj.logs,1);
      obj.logs{nLogs+1,:} = {nLogs+1, mName, model, recon, varNames};
    end
     
    function init(obj)
      obj.logs{1,:}         = obj.lcols;
      obj.logs{2,1}         = 1; % 'num'
      obj.logs{2,2}         = 'ground truth'; % 'name'
      %obj.logs{2,3}         = ; % 'model'
      obj.logs{2,4}         = obj.dat.dat; % 'est'
      obj.logs{2,5}         = obj.dat.varNames; % 'varNames'
        
      obj.freq      = obj.dat.freq;
      obj.delT      = obj.dat.delT;
      obj.tspan     = obj.dat.tspan;
      obj.nSamps    = obj.dat.nSamps; 
      obj.nVars     = obj.dat.nVars;
      obj.varNames  = obj.dat.varNames;
    
    end
    function plot_recons(obj)
      names = obj.logs{:,2};
      logs  = obj.logs{:,4};
      nlogs = length(logs);
      nSamps = obj.sm
      















      idx       = log.cntr_hist;
      T         = log.T_hist;
      Q         = log.Q_hist;
      numAlgs   = log.pos_numAlgs;
      Tx    = zeros(log.numKF, numAlgs + 1); % Xs+GT
      Ty    = zeros(log.numKF, numAlgs + 1);
      Tz    = zeros(log.numKF, numAlgs + 1);
      Qw    = zeros(log.numKF, numAlgs + 1);
      Qx    = zeros(log.numKF, numAlgs + 1);
      Qy    = zeros(log.numKF, numAlgs + 1);
      Qz    = zeros(log.numKF, numAlgs + 1);
      for a = 1:obj.pos_numAlgs
        Tcols   = get_cols(a, log.d_T); % --->> get var cols
        Qcols   = get_cols(a, log.d_Q);
        Tx(:,a) = T(:, Tcols(1)); % --->> load to plt cols
        Ty(:,a) = T(:, Tcols(2));
        Tz(:,a) = T(:, Tcols(3));    
        Qw(:,a) = Q(:, Qcols(1));
        Qx(:,a) = Q(:, Qcols(2));
        Qy(:,a) = Q(:, Qcols(3));
        Qz(:,a) = Q(:, Qcols(4));
      end
      Tx(:, end) = rgt_T(:,1); % --->> load ground truth to last col
      Ty(:, end) = rgt_T(:,2);
      Tz(:, end) = rgt_T(:,3);    
      Qw(:, end) = rgt_Q(:,1);
      Qx(:, end) = rgt_Q(:,2);
      Qy(:, end) = rgt_Q(:,3);
      Qz(:, end) = rgt_Q(:,4);
      fig = figure(); % 7 subplots Txyz Qwxyz
      sgtitle("QuEst+ Pose Estimate Logs","Interpreter","latex");
      fig.Units    = obj.fig_units;
      fig.Position = obj.fig_pos;
      hold on
      for a = 1:obj.pos_numAlgs+1 % +gt

        subplot(7,1,1); hold on; subtitle('$T_{x}$',"Interpreter","latex", ... % Tx
          'fontsize',obj.fig_txt_size); grid on;
        plot(idx, Tx(:,a), "Color",obj.plt_lclrs(a), "Marker",obj.plt_mrkrs(a));
        subplot(7,1,2); hold on; subtitle('$T_{y}$',"Interpreter","latex", ... % Ty
          'fontsize',obj.fig_txt_size); grid on;
        plot(idx, Ty(:,a), "Color",obj.plt_lclrs(a), "Marker", obj.plt_mrkrs(a));
        subplot(7,1,3); hold on; subtitle('$T_{z}$',"Interpreter","latex", ... % Tz
          'fontsize',obj.fig_txt_size); grid on;
        plot(idx, Tz(:,a), "Color",obj.plt_lclrs(a), "Marker",obj.plt_mrkrs(a));        
        subplot(7,1,4); hold on; subtitle('$Q_{w}$',"Interpreter","latex", ... % Qw
          'fontsize',obj.fig_txt_size); grid on;
        plot(idx, Qw(:,a), "Color", obj.plt_lclrs(a), "Marker",obj.plt_mrkrs(a));
        subplot(7,1,5); hold on; subtitle('$Q_{x}$',"Interpreter","latex", ... % Qx
          'fontsize',obj.fig_txt_size); grid on;
        plot(idx, Qx(:,a), "Color", obj.plt_lclrs(a), "Marker",obj.plt_mrkrs(a));
        subplot(7,1,6); hold on; subtitle('$Q_{y}$',"Interpreter","latex", ... % Qy
          'fontsize',obj.fig_txt_size); grid on; 
        plot(idx, Qy(:,a), "Color", obj.plt_lclrs(a), "Marker",obj.plt_mrkrs(a));  
        subplot(7,1,7); hold on; subtitle('$Q_{z}$',"Interpreter","latex", ... % Qz
          'fontsize',obj.fig_txt_size); grid on;
        plot(idx, Qz(:,a), "Color", obj.plt_lclrs(a), "Marker",obj.plt_mrkrs(a));
      end
      hold off
      lg          = legend([obj.pos_algs; "Groundtruth"]); 
      lg.Units    = obj.fig_leg_units;
      lg.Position = obj.fig_leg_pos;
      lg.FontSize = obj.fig_txt_size-4;
      if obj.plt_questp_sav_en
        figname = strcat(obj.toutDir,"plt_QuEst+_logs.png");
        saveas(fig, figname);
      end
      if obj.plt_questp_shw_en
        waitforbuttonpress;
      end
      close(fig);
    end % function figname = plt_quest_logs(obj, log, rgt_T, rgt_Q)





    function plot_recons(obj, logNames)
      for i = 1:size(obj.logs{:,2})
        for n = 1:length(logNames)
          if strcmp(logNames{n},obj.logs{i,2})
            
          end
        end
      obj.log.plot_logs(logNames);
    end 

  end % methods (Access = public) 
end
