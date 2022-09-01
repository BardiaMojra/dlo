classdef dlgr_class < matlab.System 
  properties
    %% class
    class       = 'dlgr'
    note        = 'manages all data logs for uniform plotting and comparison.'
    %% features
    %log_prt_en      = false
    %log_sav_en      = true
    csv_sav_en      = true
    plt_sav_en      = true
    plt_shw_en      = true
    %% cfg (argin)
    TID
    ttag
    toutDir
    btype
    bnum
    dat % ground truth
    %% logs
    freq    
    dt    
    tspan   
    nSamps  
    nVars   
    varNames
    lcols = {'num', 'name', 'A_mdl', 'vals', 'rec'}
    logs  = cell(1,5) % num of logs by lcols
    %% plot 
    font_style   = 'Times'
    txt_FS       = '12pt'
    tab_FS       = '10pt'
    num_format   = "%1.4f"
    fig_U        = "inches"
    fig_FS       = 10
    fig_pos      = [0 0 7 10]
    fig_leg_U    = "inches"
    fig_leg_pos  = [6 9 .8 .8]
    fig_leg_FS   = 8
    fig_LW       = 1.5
    fig_ylim     = "auto" %= [-2 2] 
    fig_Cr       = ["#A2142F", "#77AC30", "#0072BD", "#c451db", ...
                    "#EDB120", "#4DBEEE", "#D95319", "#77AC30"] % unique per alg
    fig_MK       = ["o", "+", "*", ".", ...
                         "x", "s", "d", "^", ...
                         "v", ">", "<", "h"]
  end
  methods  % constructor
    function obj = dlgr_class(varargin)
      setProperties(obj,nargin,varargin{:})
    end
  end 
  methods (Access = public) 
 
    function init(obj)
      obj.logs{1,1}     = obj.lcols{1};
      obj.logs{1,2}     = obj.lcols{2};
      obj.logs{1,3}     = obj.lcols{3};
      obj.logs{1,4}     = obj.lcols{4};
      obj.logs{1,5}     = obj.lcols{5};
      obj.freq          = obj.dat.freq;
      obj.dt            = obj.dat.dt;
      obj.tspan         = obj.dat.tspan;
      obj.nSamps        = obj.dat.nSamps; 
      obj.nVars         = obj.dat.nVars;
      obj.varNames      = obj.dat.varNames;
    end
        
    function load_cfg(obj, cfg)
      obj.TID               = cfg.TID; 
      obj.ttag              = cfg.ttag; 
      obj.toutDir           = cfg.toutDir; 
      obj.btype             = cfg.btype; 
      obj.bnum              = cfg.bnum;   
      obj.dat               = cfg.dat;
      obj.init();
    end

    function add_mdl(obj, mdl) 
      % log table {'num', 'name', 'A_mdl', 'vals', 'rec'}
      len = size(obj.logs,1);
      obj.logs{len+1, 1} = len;
      obj.logs{len+1, 2} = mdl.name;
      obj.logs{len+1, 3} = mdl.A_mdl;
      obj.logs{len+1, 4} = mdl.vals;
      obj.logs{len+1, 5} = mdl.rec;

    end

    function get_tab(obj)
      % all tab entries must be col cel and col vec
      %idx = [1;2;3;4]; % internal use
      %method = obj.logs{2:end, 2}; % format {'str1';'str2'};
      %L1_err = get
      %L2_err = get
      
      %tab = table(method, ...
      %            L1_err,...
      %            L2_err);
    end
    
    function sav_tab(obj)
      %fname = strcat(obj.toutDir, 'res_tab.txt');
      %writetable(tab,fname,'Delimiter',',  ', 'QuoteStrings',true, 'WriteRowNames',true);  
      %type  fname % disp
      %tab % disp
    end


    function plt_recons_grid(obj)
      nAlgs = size(obj.logs,1)-1;
      TX='$T_{x}$'; TY='$T_{y}$'; TZ='$T_{z}$';
      IN="Interpreter";LT="latex";MK="Marker";
      FS='fontsize';Cr="Color";LW ='LineWidth';
      fig = figure(); % 10*3 subplots 10 KFs * 3 Txyz 
      sgtitle("Key Feature Pose Reconstruction",IN,LT);
      fig.Units    = obj.fig_U;
      fig.Position = obj.fig_pos;
      hold on
      algNames = cell(nAlgs,0);
      for kf = 1:10 % 10 KFs, 10 rows
        for a = 1:nAlgs % nAlgs colors
          % log table {'num', 'name', 'A-model', 'vals', 'rec'} 
          algNames{a} = obj.logs{a+1,2};
          RL = strcat("$KF_", num2str(kf, "{%02.f}$"));
          dat_a = obj.logs{a+1,5};
          Txyz = dat_a((((kf-1)*3)+1):(((kf-1)*3)+3),:);
          subplot(10,3,  1+((kf-1)*3) ); hold on; % Tx 
          subtitle(TX,IN,LT,FS,obj.fig_FS); grid on;
          ylabel(RL,IN,LT,FS,obj.fig_FS);
          plot(1:obj.nSamps,Txyz(  1,:),Cr,obj.fig_Cr(a),LW,obj.fig_LW);
          subplot(10,3,  2+((kf-1)*3) ); hold on; % Ty 
          subtitle(TY,IN,LT,FS,obj.fig_FS); grid on;
          plot(1:obj.nSamps,Txyz(  2,:),Cr,obj.fig_Cr(a),LW,obj.fig_LW);
          subplot(10,3,  3+((kf-1)*3) ); hold on; % Tz 
          subtitle(TZ,IN,LT,FS,obj.fig_FS); grid on;
          plot(1:obj.nSamps,Txyz(  3,:),Cr,obj.fig_Cr(a),LW,obj.fig_LW);
        end
      end
      hold off
      lg          = legend(algNames); 
      lg.Units    = obj.fig_leg_U;
      lg.Position = obj.fig_leg_pos;
      lg.FontSize = obj.fig_leg_FS;
      if obj.plt_sav_en
        figname = strcat(obj.toutDir,"plt_KFs_grid_recs");
        saveas(fig, figname); % sav as fig file
        saveas(fig, strcat(figname,'.png')); % sav as png file
      end
      if ~obj.plt_shw_en
        close(fig);
      end
      
    end % plt_KFs_grid(obj)
  end % methods (Access = public) 
end
