classdef dlogger_class < matlab.System 
  properties
    %% class
    class       = 'dlogger'
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
    delT    
    tspan   
    nSamps  
    nVars   
    varNames
    lcols = {'num', 'name', 'A_mdl', 'vals', 'rec'}
    logs  = cell(1,5) % num of logs by lcols
    %% plot 
    font_style        = 'Times'
    txt_FS            = '12pt'
    tab_FS            = '10pt'
    num_format        = "%1.4f"
    fig_U             = "inches"
    fig_FS            = 10
    fig_pos           = [0 0 7 10]
    fig_leg_U         = "inches"
    fig_leg_pos       = [6 9 .8 .8]
    fig_leg_FS        = 8
    plt_ylim          = "auto" %= [-2 2] 
    plt_clrs  = ["#A2142F", "#77AC30", "#0072BD", "#7E2F8E", ...
                 "#EDB120", "#4DBEEE", "#D95319", "#77AC30"] % unique per alg
    plt_mrkrs = ["o", "+", "*", ".", ...
                 "x", "s", "d", "^", ...
                 "v", ">", "<", "h"]
  end
  methods  % constructor
    function obj = dlogger_class(varargin)
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
      obj.delT          = obj.dat.delT;
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
      obj.dat              = cfg.dat;
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
      if obj.csv_sav_en % --->> save logs to file
        tag   = strcat(num2str(len,'%02.f_'), mdl.name); % log tag 
        tag = strrep(tag,' ','_');
        tag = strrep(tag,'-','_');
        if ~isempty(mdl.A_mdl)
          fname = strcat(obj.toutDir,"log_",tag,"_A_mdl.mat"); % sav A_mod
          A = mdl.A_mdl;
          %save(fname, A);
        end
        if ~isempty(mdl.vals)
          fname = strcat(obj.toutDir,"log_",tag,"_vals.csv"); % sav vals
          writematrix(mdl.vals, fname);
        end
        fname = strcat(obj.toutDir,"log_",tag,"_rec.csv"); % sav rec
        writematrix(mdl.rec, fname);
      end
    end


    function plt_KFs_grid(obj)
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
          dat_a = obj.logs{a+1,5};
          Txyz = dat_a((((kf-1)*3)+1):(((kf-1)*3)+3),:);
          subplot(10,3,  1+((kf-1)*3)); hold on; % Tx 
          RL = "KF_"+num2str(kf, '{%02.f}');
          subtitle(TX,IN,LT,FS,obj.fig_FS); grid on;
          ylabel(RL,IN,LT,FS,obj.fig_FS);
          plot(1:obj.nSamps,Txyz(  1,:),Cr,obj.plt_clrs(a),LW,2);
          subplot(10,3,  2+((kf-1)*3)); hold on; % Ty 
          subtitle(TY,IN,LT,FS,obj.fig_FS); grid on;
          plot(1:obj.nSamps,Txyz(  2,:),Cr,obj.plt_clrs(a),LW,2);
          subplot(10,3,  3+((kf-1)*3)); hold on; % Tz 
          subtitle(TZ,IN,LT,FS,obj.fig_FS); grid on;
          plot(1:obj.nSamps,Txyz(  3,:),Cr,obj.plt_clrs(a),LW,2);
        end
      end
      hold off
      lg          = legend(algNames); 
      lg.Units    = obj.fig_leg_U;
      lg.Position = obj.fig_leg_pos;
      lg.FontSize = obj.fig_leg_FS;
      if obj.plt_sav_en
        figname = strcat(obj.toutDir,"plt_KFs_grid_recs.png");
        saveas(fig, figname);
      end
      if obj.plt_shw_en
        waitforbuttonpress;
      end
      %close(fig);
    end % plt_KFs_grid(obj)
  end % methods (Access = public) 
end
