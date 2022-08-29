classdef model_class < matlab.System
  properties
    %% features 
    models_sav_en     = true
    plts_sav_en     = true
    plts_shw_en     = false
    %sliding_ref_en  % cfg argin
    %% cfg (argin)
    TID     
    ttag    
    toutDir 
    btype  
    bnum
    dat
    %% model class (argin)
    cName 






    %% var dims
    d_T 
    d_Q 
    d_V 
    d_W 
    d_Z 
    d_U 

    d_X 
    d_Y 
    %d_P 
    %d_K
    %% plt cfg
    fig_txt_size      = 8
    fig_units         = "inches"
    fig_pos           = [0 0 7 10]
    fig_leg_units     = "inches"
    fig_leg_pos       = [6 9 .8 .8]
    plt_ylim          = "auto" %= [-2 2] 

    %% private vars
    pos_numAlgs
    vel_numAlgs
    pfeat_logs % pfeat mod
    pos_logs
    vel_logs
    qekf_logs
    %% logs ------->> log objects 
    cntr_hist
    kf_hist 
    T_hist % quest
    Q_hist 
    V_hist % vest
    W_hist 
    Z_hist % qekf
    U_hist
    X_hist
    Y_hist
    P_hist
    K_hist
    % Log Errs
    % init in init() but always compute and fill at post-processing 
    T_errs % trans err for each method
    Q_errs % rot err for each method
    VEst_T_errs % based on VEst V .* delta_t
    VEst_Q_errs % based on VEst exp_map(W)
    % qekf
    % gt - x
    x_t_errs % st trans est errs
    x_q_errs % st rot est errs
    x_v_errs % st vel est errs
    % gt - z 
    z_t_errs % meas trans errs
    z_v_errs % meas rot errs
    z_q_errs % meas vel errs
    % L1 residual
    y_t_L1 % st trans L1 res
    y_q_L1 % st rot L1 res
    y_v_L1 % st vel L1 res
    % L2 residual
    y_t_L2 % st trans L2 res
    y_q_L2 % st rot L2 res
    y_v_L2 % st vel L2 res
    % private constants 
    plt_ref_lclr = "--xk"
    plt_lclrs = ["#A2142F", "#77AC30", "#0072BD", "#7E2F8E", ...
                 "#EDB120", "#4DBEEE", "#D95319", "#77AC30"] % unique per alg
    plt_mrkrs = ["o", "+", "*", ".", ...
                 "x", "s", "d", "^", ...
                 "v", ">", "<", "h"]
  end
  methods  % constructor
    function obj = log_class(varargin) % init obj w name-value args
      setProperties(obj,nargin,varargin{:}) 
    end
    
    function load_cfg(obj, cfg) % load config from cfg
      obj.TID            = cfg.TID;
      obj.ttag           = cfg.ttag;
      obj.toutDir        = cfg.toutDir;
      obj.btype          = cfg.btype;
      obj.init();
    end 
  
  end % methods  % constructor
  methods (Access = public) 
    function plot_logs(obj, logNames)
      
    end
    function plot_recon(obj)
      gtlog = obj.pos_logs{2,obj.pos_numAlgs+1};
      for a = 1:obj.pos_numAlgs
        assert(isequal(obj.pos_logs{1,a}, obj.pos_algs{a}), ...
          "pos alg not matching pos log name!")
        obj.plot_pos_log(obj.pos_logs{1,a}, obj.pos_logs{2,a}, a, gtlog, "Groundtruth");
      end 
    end 

  


    function plot_pos_log(obj, logNameA, logA, a, logB, logNameB)
      idx = logA(:,1);
      fig = figure(); % 7 subplots Txyz Qwxyz
      figtitle = strcat("Pose Est.: ",logNameA," vs. ",logNameB);
      sgtitle(figtitle,"Interpreter","latex");
      fig.Units    = obj.fig_units;
      fig.Position = obj.fig_pos;
      hold on
      subplot(7,1,1); hold on; subtitle('$T_{x}$',"Interpreter","latex", ... % Tx
        'fontsize',obj.fig_txt_size); grid on;
      plot(idx, logA(:,3), "Color",obj.plt_lclrs(a), "Marker",obj.plt_mrkrs(a));
      plot(idx, logB(:,3), obj.plt_ref_lclr);
      subplot(7,1,2); hold on; subtitle('$T_{y}$',"Interpreter","latex", ... % Ty
        'fontsize',obj.fig_txt_size); grid on;
      plot(idx, logA(:,4), "Color",obj.plt_lclrs(a), "Marker", obj.plt_mrkrs(a));
      plot(idx, logB(:,4), obj.plt_ref_lclr);
      subplot(7,1,3); hold on; subtitle('$T_{z}$',"Interpreter","latex", ... % Tz
        'fontsize',obj.fig_txt_size); grid on;
      plot(idx, logA(:,5), "Color",obj.plt_lclrs(a), "Marker",obj.plt_mrkrs(a));   
      plot(idx, logB(:,5), obj.plt_ref_lclr);
      subplot(7,1,4); hold on; subtitle('$Q_{w}$',"Interpreter","latex", ... % Qw
        'fontsize',obj.fig_txt_size); grid on;
      plot(idx, logA(:,6), "Color", obj.plt_lclrs(a), "Marker",obj.plt_mrkrs(a));
      plot(idx, logB(:,6), obj.plt_ref_lclr);
      subplot(7,1,5); hold on; subtitle('$Q_{x}$',"Interpreter","latex", ... % Qx
        'fontsize',obj.fig_txt_size); grid on;
      plot(idx, logA(:,7), "Color", obj.plt_lclrs(a), "Marker",obj.plt_mrkrs(a));
      plot(idx, logB(:,7), obj.plt_ref_lclr);
      subplot(7,1,6); hold on; subtitle('$Q_{y}$',"Interpreter","latex", ... % Qy
        'fontsize',obj.fig_txt_size); grid on; 
      plot(idx, logA(:,8), "Color", obj.plt_lclrs(a), "Marker",obj.plt_mrkrs(a));
      plot(idx, logB(:,8), obj.plt_ref_lclr);
      subplot(7,1,7); hold on; subtitle('$Q_{z}$',"Interpreter","latex", ... % Qz
        'fontsize',obj.fig_txt_size); grid on;
      plot(idx, logA(:,9), "Color", obj.plt_lclrs(a), "Marker",obj.plt_mrkrs(a));
      plot(idx, logB(:,9), obj.plt_ref_lclr);
      hold off
      lg          = legend([logNameA; logNameB],"Interpreter","latex"); 
      lg.Units    = obj.fig_leg_units;
      lg.Position = obj.fig_leg_pos;
      lg.FontSize = obj.fig_txt_size;
      if obj.plts_sav_en
        figname = strcat(obj.toutDir,"plt_pos_log_"+logNameA+".png");
        saveas(fig, figname);
      end
      if obj.plts_shw_en
        waitforbuttonpress;
      end
      close(fig);
    end % plot_recons










    
   

    function plot_pos_logs(obj)
      gtlog = obj.pos_logs{2,obj.pos_numAlgs+1};
      for a = 1:obj.pos_numAlgs
        assert(isequal(obj.pos_logs{1,a}, obj.pos_algs{a}), ...
          "pos alg not matching pos log name!")
        obj.plot_pos_log(obj.pos_logs{1,a}, obj.pos_logs{2,a}, a, gtlog, "Groundtruth");
      end 
    end 

    function plot_pos_log(obj, logNameA, logA, a, logB, logNameB)
      idx = logA(:,1);
      fig = figure(); % 7 subplots Txyz Qwxyz
      figtitle = strcat("Pose Est.: ",logNameA," vs. ",logNameB);
      sgtitle(figtitle,"Interpreter","latex");
      fig.Units    = obj.fig_units;
      fig.Position = obj.fig_pos;
      hold on
      subplot(7,1,1); hold on; subtitle('$T_{x}$',"Interpreter","latex", ... % Tx
        'fontsize',obj.fig_txt_size); grid on;
      plot(idx, logA(:,3), "Color",obj.plt_lclrs(a), "Marker",obj.plt_mrkrs(a));
      plot(idx, logB(:,3), obj.plt_ref_lclr);
      subplot(7,1,2); hold on; subtitle('$T_{y}$',"Interpreter","latex", ... % Ty
        'fontsize',obj.fig_txt_size); grid on;
      plot(idx, logA(:,4), "Color",obj.plt_lclrs(a), "Marker", obj.plt_mrkrs(a));
      plot(idx, logB(:,4), obj.plt_ref_lclr);
      subplot(7,1,3); hold on; subtitle('$T_{z}$',"Interpreter","latex", ... % Tz
        'fontsize',obj.fig_txt_size); grid on;
      plot(idx, logA(:,5), "Color",obj.plt_lclrs(a), "Marker",obj.plt_mrkrs(a));   
      plot(idx, logB(:,5), obj.plt_ref_lclr);
      subplot(7,1,4); hold on; subtitle('$Q_{w}$',"Interpreter","latex", ... % Qw
        'fontsize',obj.fig_txt_size); grid on;
      plot(idx, logA(:,6), "Color", obj.plt_lclrs(a), "Marker",obj.plt_mrkrs(a));
      plot(idx, logB(:,6), obj.plt_ref_lclr);
      subplot(7,1,5); hold on; subtitle('$Q_{x}$',"Interpreter","latex", ... % Qx
        'fontsize',obj.fig_txt_size); grid on;
      plot(idx, logA(:,7), "Color", obj.plt_lclrs(a), "Marker",obj.plt_mrkrs(a));
      plot(idx, logB(:,7), obj.plt_ref_lclr);
      subplot(7,1,6); hold on; subtitle('$Q_{y}$',"Interpreter","latex", ... % Qy
        'fontsize',obj.fig_txt_size); grid on; 
      plot(idx, logA(:,8), "Color", obj.plt_lclrs(a), "Marker",obj.plt_mrkrs(a));
      plot(idx, logB(:,8), obj.plt_ref_lclr);
      subplot(7,1,7); hold on; subtitle('$Q_{z}$',"Interpreter","latex", ... % Qz
        'fontsize',obj.fig_txt_size); grid on;
      plot(idx, logA(:,9), "Color", obj.plt_lclrs(a), "Marker",obj.plt_mrkrs(a));
      plot(idx, logB(:,9), obj.plt_ref_lclr);
      hold off
      lg          = legend([logNameA; logNameB],"Interpreter","latex"); 
      lg.Units    = obj.fig_leg_units;
      lg.Position = obj.fig_leg_pos;
      lg.FontSize = obj.fig_txt_size;
      if obj.plts_sav_en
        figname = strcat(obj.toutDir,"plt_pos_log_"+logNameA+".png");
        saveas(fig, figname);
      end
      if obj.plts_shw_en
        waitforbuttonpress;
      end
      close(fig);
    end % plot_pos_logs()

    function plot_qekf_logs(obj)
      for a = 1:obj.pos_numAlgs % alg,Z,U,X,Y,P,K
        assert(isequal(obj.pos_logs{1,a}, obj.pos_algs{a}), "[log.plot_qekf]--> pos alg not matching!");
        logA = obj.qekf_logs{4,a+1}; % X
        logB = obj.qekf_logs{2,a+1}; % Z
        logNameA = "est";
        logNameB = "meas";
        obj.plot_qekf_log(a, "Z vs. X", logA, logNameA, logB, logNameB);
        logA = obj.qekf_logs{4,a+1}; % Y
        logB = zeros(obj.nSamps,size(logA,2)); % zero
        logNameA = "residual";
        logNameB = "zero";
        obj.plot_qekf_log(a, " residual", logA, logNameA, logB, logNameB);
        
      end 
    end 
    
    function plot_qekf_log(obj, a, plt_tit, logA, logNameA, logB, logNameB)
      %logA = log{4,a+1}; % X
      %logB = log{2,a+1}; % Z
      %logNameA = "est";
      %logNameB = "meas";
      title = strcat(plt_tit, " - ", obj.pos_algs{a});
      %disp(zlog);
      %disp(xlog);
      idx = logA(:,1);
      fig = figure(); % 7 subplots Txyz Qwxyz
      figtitle = strcat("QEKF: ", title);
      sgtitle(figtitle,"Interpreter", "latex");
      fig.Units    = obj.fig_units;
      fig.Position = obj.fig_pos;
      hold on
      subplot(10,1,1); hold on; subtitle('$T_{x}$',"Interpreter","latex", ... % Tx
        'fontsize',obj.fig_txt_size); grid on;
      plot(idx, logA(:,3), "Color",obj.plt_lclrs(a), "Marker",obj.plt_mrkrs(a));
      plot(idx, logB(:,3), obj.plt_ref_lclr);
      subplot(10,1,2); hold on; subtitle('$T_{y}$',"Interpreter","latex", ... % Ty
        'fontsize',obj.fig_txt_size); grid on;
      plot(idx, logA(:,4), "Color",obj.plt_lclrs(a), "Marker", obj.plt_mrkrs(a));
      plot(idx, logB(:,4), obj.plt_ref_lclr);
      subplot(10,1,3); hold on; subtitle('$T_{z}$',"Interpreter","latex", ... % Tz
        'fontsize',obj.fig_txt_size); grid on;
      plot(idx, logA(:,5), "Color",obj.plt_lclrs(a), "Marker",obj.plt_mrkrs(a));   
      plot(idx, logB(:,5), obj.plt_ref_lclr);
      subplot(10,1,4); hold on; subtitle('$V_{x}$',"Interpreter","latex", ... % Vx
        'fontsize',obj.fig_txt_size); grid on;
      plot(idx, logA(:,6), "Color",obj.plt_lclrs(a), "Marker",obj.plt_mrkrs(a));
      plot(idx, logB(:,6), obj.plt_ref_lclr);
      subplot(10,1,5); hold on; subtitle('$V_{y}$',"Interpreter","latex", ... % Vy
        'fontsize',obj.fig_txt_size); grid on;
      plot(idx, logA(:,7), "Color",obj.plt_lclrs(a), "Marker", obj.plt_mrkrs(a));
      plot(idx, logB(:,7), obj.plt_ref_lclr);
      subplot(10,1,6); hold on; subtitle('$V_{z}$',"Interpreter","latex", ... % Vz
        'fontsize',obj.fig_txt_size); grid on;
      plot(idx, logA(:,8), "Color",obj.plt_lclrs(a), "Marker",obj.plt_mrkrs(a));   
      plot(idx, logB(:,8), obj.plt_ref_lclr);
      subplot(10,1,7); hold on; subtitle('$Q_{x}$',"Interpreter","latex", ... % Qx
        'fontsize',obj.fig_txt_size); grid on;
      plot(idx, logA(:,9), "Color", obj.plt_lclrs(a), "Marker",obj.plt_mrkrs(a));
      plot(idx, logB(:,9),  obj.plt_ref_lclr);
      subplot(10,1,8); hold on; subtitle('$Q_{y}$',"Interpreter","latex", ... % Qy
        'fontsize',obj.fig_txt_size); grid on;
      plot(idx, logA(:,10), "Color", obj.plt_lclrs(a), "Marker",obj.plt_mrkrs(a));
      plot(idx, logB(:,10), obj.plt_ref_lclr);
      subplot(10,1,9); hold on; subtitle('$Q_{z}$',"Interpreter","latex", ... % Qz
        'fontsize',obj.fig_txt_size); grid on; 
      plot(idx, logA(:,11), "Color", obj.plt_lclrs(a), "Marker",obj.plt_mrkrs(a));
      plot(idx, logB(:,11), obj.plt_ref_lclr);
      subplot(10,1,10); hold on; subtitle('$Q_{w}$',"Interpreter","latex", ... % Qw
        'fontsize',obj.fig_txt_size); grid on;
      plot(idx, logA(:,12), "Color", obj.plt_lclrs(a), "Marker",obj.plt_mrkrs(a));
      plot(idx, logB(:,12), obj.plt_ref_lclr);
      hold off
      lg          = legend([logNameA; logNameB],"Interpreter","latex"); 
      lg.Units    = obj.fig_leg_units;
      lg.Position = obj.fig_leg_pos;
      lg.FontSize = obj.fig_txt_size;
      if obj.plts_sav_en
        title = strrep(title, ".", "");
        title = strrep(title, " ", "");
        title = strrep(title, "-", "_");
        figname = strcat(obj.toutDir,"plt_qekf_log_"+title+".png");
        saveas(fig, figname);
      end
      if obj.plts_shw_en
        waitforbuttonpress;
      end
      close(fig);
    end % plot_qekf_log()
      
   

  end % methods (Access = public) % public functions
  methods (Access = private) % private functions
    
    function init(obj) 
      % consider changing to matrices instead of cells, (matrix runs faster)
      obj.pos_numAlgs         = length(obj.pos_algs);
      obj.vel_numAlgs         = length(obj.vel_algs);
      obj.nSamps               = length(obj.kframes);
      obj.cntr_hist           = NaN(obj.nSamps,1);
      obj.kf_hist             = NaN(obj.nSamps,1);
      %% --->> logs
      obj.T_hist              = cell(obj.nSamps,obj.pos_numAlgs); % quest
      obj.Q_hist              = cell(obj.nSamps,obj.pos_numAlgs); 
      obj.V_hist              = cell(obj.nSamps,obj.vel_numAlgs); % vest
      obj.W_hist              = cell(obj.nSamps,obj.vel_numAlgs);
      obj.Z_hist              = cell(obj.nSamps,obj.pos_numAlgs); % qekf
      obj.U_hist              = cell(obj.nSamps,obj.pos_numAlgs); 
      obj.X_hist              = cell(obj.nSamps,obj.pos_numAlgs); 
      obj.Y_hist              = cell(obj.nSamps,obj.pos_numAlgs); 
      obj.P_hist              = cell(obj.nSamps,obj.pos_numAlgs); 
      obj.K_hist              = cell(obj.nSamps,obj.pos_numAlgs); 
      %% --->> errs    
      obj.T_errs              = NaN(obj.nSamps,obj.pos_numAlgs); % quest
      obj.Q_errs              = NaN(obj.nSamps,obj.pos_numAlgs); 
      obj.VEst_T_errs         = NaN(obj.nSamps,obj.vel_numAlgs); % vest
      obj.VEst_Q_errs         = NaN(obj.nSamps,obj.vel_numAlgs); 
    end % function init(obj)

    function plot_something(obj)
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
  end % methods (Access = private) % private functions
end
