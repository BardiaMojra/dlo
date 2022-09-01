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
    lcols = {'num', 'name', 'A_mdl', 'vals', 'rec', 'st_errs', 'L1_err', 'L2_err'}
    logs  = cell(1,5) % num of logs by lcols
    %% plot 
    font_style   = 'Times'
    txt_FS       = '12pt'
    tab_FS       = '10pt'
    num_format   = "%1.4f"
    fig_U        = "inches"
    fig_FS       = 10
    fig_pos      = [0 0 10 10]
    fig_leg_U    = "inches"
    fig_leg_pos  = [9 9 .8 .8]
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

      obj.logs{1,6}     = obj.lcols{6};
      obj.logs{1,7}     = obj.lcols{7};
      obj.logs{1,8}     = obj.lcols{8};

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

        function res = get_res(obj, cfg, dlog)
      obj.res{1}   = dlog.log.benchtype;
      obj.res{2}   = obj.get_res_tab(dlog.log, cfg.dat); % returns a table object
      if obj.res_tab_prt_en
        disp(strcat(obj.mod_name, ' module:')); disp(obj.rpt_note);
        disp(obj.res{1}); disp(obj.res{1});
      end 
      if obj.res_tab_sav_en
        fname = strcat(obj.toutDir,'res_', ...
                       ...%obj.ttag, "_", ...
                       obj.mod_name,'_tab.csv');
        writetable(obj.res{2}, fname);
      end 
      res = obj.res;
    end % get_res()      

    function get_errs(obj)
      gt = obj.logs{2,5};
      nAlg = size(obj.logs,1);
      for a = 2:nAlg
        mrec = obj.logs{a,5};
        st_err = mrec - gt;
        L1_err = sum(abs(st_err),2); % get st L1
        L2_err = sqrt(sum((st_err.^2),2)); % get st L1
        obj.logs{a,6} = st_err;
        obj.logs{a,7} = L1_err;
        obj.logs{a,8} = L2_err;
        
      end
    end
    
    function get_tab(obj)
      % all tab entries must be col cel and col vec
      obj.tab = table(obj.logs{2:end, 1}, ...
                  obj.logs{2:end, 2}, ...
                  obj.logs{2:end, 7},...
                  obj.logs{2:end, 8}, ...
                  'VariableNames', obj.lcols{1,2,7,8});
    end
    
    function sav_tab(obj)
      %fname = strcat(obj.toutDir, 'res_tab.txt');
      %writetable(tab,fname,'Delimiter',',  ', 'QuoteStrings',true, 'WriteRowNames',true);  
      %type  fname % disp
      %tab % disp
    end


    function plt_recons_grid(obj)
      nSet = size(obj.logs,1)-1;
      TX='$T_{x}$'; TY='$T_{y}$'; TZ='$T_{z}$';
      IN="Interpreter";LT="latex";MK="Marker";
      FS='fontsize';Cr="Color";LW ='LineWidth';
      fig = figure(); % 10*3 subplots 10 KFs * 3 Txyz 
      sgtitle("Key Feature Pose Reconstruction",IN,LT);
      fig.Units    = obj.fig_U;
      fig.Position = obj.fig_pos;
      hold on
      algNames = cell(nSet,0);
      for kf = 1:10 % 10 KFs, 10 rows
        for s = 1:nSet % nAlgs colors
          % log table {'num', 'name', 'A-model', 'vals', 'rec'} 
          algNames{s} = obj.logs{s+1,2};
          RL = strcat("$KF_", num2str(kf, "{%02.f}$"));
          dat_a = obj.logs{s+1,5};
          Txyz = dat_a((((kf-1)*3)+1):(((kf-1)*3)+3),:);
          %fprintf("from row %d to %d, all cols\n", ...
          %  (((kf-1)*3)+1),(((kf-1)*3)+3)); % keep for debugging
          subplot(10,3,  1+((kf-1)*3) ); hold on; % Tx 
          subtitle(TX,IN,LT,FS,obj.fig_FS); grid on;
          ylabel(RL,IN,LT,FS,obj.fig_FS);
          plot(1:obj.nSamps,Txyz(  1,:),Cr,obj.fig_Cr(s),LW,obj.fig_LW);
          subplot(10,3,  2+((kf-1)*3) ); hold on; % Ty 
          subtitle(TY,IN,LT,FS,obj.fig_FS); grid on;
          plot(1:obj.nSamps,Txyz(  2,:),Cr,obj.fig_Cr(s),LW,obj.fig_LW);
          subplot(10,3,  3+((kf-1)*3) ); hold on; % Tz 
          subtitle(TZ,IN,LT,FS,obj.fig_FS); grid on;
          plot(1:obj.nSamps,Txyz(  3,:),Cr,obj.fig_Cr(s),LW,obj.fig_LW);
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
