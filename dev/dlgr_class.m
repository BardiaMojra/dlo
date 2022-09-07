classdef dlgr_class < matlab.System 
  properties
    %% class
    class       = "dlgr"
    note        = "manages all data logs for uniform plotting and comparison."
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
    logs % log table
    tab  % res tab
    lcols = ["num", ... 
             "mthd", ... 
             "name", ... 
             "A_mdl", ... 
             "vals", ... 
             "rec", ...
             "A_vec", ... 
             "A_mat", ... 
             "st_errs", ... 
             "L1", ... 
             "L2", ... 
             "MAE", ... 
             "MSE"]
    %% plot 
    font_style   = "Times"
    txt_FS       = "12pt"
    tab_FS       = "10pt"
    num_format   = "%1.4f"
    fig_U        = "inches"
    fig_FS       = 10
    fig_pos      = [0 0 10 10]
    fig_leg_U    = "inches"
    fig_leg_pos  = [9 9 .8 .8]
    fig_leg_FS   = 8
    fig_LW       = .75
    fig_ylim     = "auto" %= [-2 2] 
    fig_Cr       = ["#A2142F", "#77AC30", "#0072BD", "#c451db", ...
                    "#EDB120", "#4DBEEE", "#D95319", "#77AC30"] % unique per alg
    fig_MK       = ["o", "+", "*", ".", ...
                    "x", "s", "d", "^", ...
                    "v", ">", "<", "h"]
    fig_PT       = ["bo:", "gx:", "r+:", "c*:", ...
                    "ms:", "yd:", "kv:", "b^", ...
                    "g<:"]
  end
  methods  % constructor
    function obj = dlgr_class(varargin)
      setProperties(obj,nargin,varargin{:})
    end
  end 
  methods (Access = public) 
 
    function init(obj)
      obj.logs{1, 1}    = obj.lcols{ 1}; %"num"
      obj.logs{1, 2}    = obj.lcols{ 2}; %"mthd" 
      obj.logs{1, 3}    = obj.lcols{ 3}; %"name"
      obj.logs{1, 4}    = obj.lcols{ 4}; %"A_mdl" 
      obj.logs{1, 5}    = obj.lcols{ 5}; %"vals" 
      obj.logs{1, 6}    = obj.lcols{ 6}; %"rec"
      obj.logs{1, 7}    = obj.lcols{ 7}; %"A_vet"
      obj.logs{1, 8}    = obj.lcols{ 8}; %"A_mat"
      obj.logs{1, 9}    = obj.lcols{ 9}; %"st_errs"
      obj.logs{1,10}    = obj.lcols{10}; %"L1" 
      obj.logs{1,11}    = obj.lcols{11}; %"L2" 
      obj.logs{1,12}    = obj.lcols{12}; %"MAE" 
      obj.logs{1,13}    = obj.lcols{13}; %"MSE"
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
      % log table 
      % {"num", "mthd", "name", "A_mdl", "vals", "rec",
      %  "A_vec", "A_mat", "st_errs", "L1", "L2", "MAE", "MSE"}
      len = size(obj.logs,1);
      obj.logs{len+1, 1} = len;
      obj.logs{len+1, 2} = mdl.mthd; % e.g. piDMD, HAVOK 
      obj.logs{len+1, 3} = mdl.name;
      obj.logs{len+1, 4} = mdl.A_mdl;
      obj.logs{len+1, 5} = mdl.vals;
      obj.logs{len+1, 6} = mdl.rec;
      obj.logs{len+1, 7} = mdl.A_vec;
      obj.logs{len+1, 8} = mdl.A_mat;
      obj.logs{len+1, 9} = mdl.st_errs;
      obj.logs{len+1,10} = mdl.L1;
      obj.logs{len+1,11} = mdl.L2;
      obj.logs{len+1,12} = mdl.MAE;
      obj.logs{len+1,13} = mdl.MSE;
    end

     

    function get_errs(obj)
      gt = obj.logs{2,6};
      gt = gt(1:obj.nVars/2,:);
      nAlg = size(obj.logs,1);
      for a = 2:nAlg
        assert(isequal(a-1, obj.logs{a,1}), ...
          "[dlgr.get_errs]->> log num mismatch!\n");
        mrec  = obj.logs{a,6};
        mrec  = mrec(1:obj.nVars/2,:);
        if ~isequal(size(gt),size(mrec)) % check size
          fprintf("[dlgr.get_errs]->> log dim DO NOT match gt!\n");
          fprintf("[dlgr.get_errs]->> gt size: %s \n", mat2str(size(gt)));
          fprintf("[dlgr.get_errs]->> %s size: %s \n", obj.logs{a,3}, mat2str(size(mrec)));
        end
  
        if size(gt) >= size(mrec)
          pSize = size(gt) - size(mrec);
          mrec = padarray(mrec, pSize, 0, 'post');
          obj.logs{a,6} = mrec  ;
        else
          error("[dlgr.get_errs]->> log size is greater than gt!\n")
        end

        errs    = gt - mrec;
        L1      = sum(abs(errs),"all"); % get st L1
        L2      = sum((errs.^2),"all"); 
        MAE     = L1/size(errs,2);
        MSE     = L2/size(errs,2); 
        obj.logs{a, 9}    = errs; %"st_errs"
        obj.logs{a,10}    = L1; %"L1" 
        obj.logs{a,11}    = L2; %"L2" 
        obj.logs{a,12}    = MAE; %"MAE" 
        obj.logs{a,13}    = MSE; %"MSE"
      end
      %obj.logs % disp res tab
    end
    
    function get_tab(obj)
      labels = {obj.lcols{01}, ...
                obj.lcols{02}, ...
                obj.lcols{03}, ...
                obj.lcols{10}, ...
                obj.lcols{11}, ...
                obj.lcols{12}, ...
                obj.lcols{13}}';
      % all tab entries must be col cel and col vec   
      obj.tab = table([obj.logs{2:end,01}]', ... % {01} "num", 
                      [obj.logs{2:end,02}]', ... % {02} "mthd" 
                      [obj.logs{2:end,03}]', ... % {03} "name" 
                      [obj.logs{2:end,10}]', ... % {10} "L1" 
                      [obj.logs{2:end,11}]', ... % {11} "L2" 
                      [obj.logs{2:end,12}]', ... % {12} "MAE"
                      [obj.logs{2:end,13}]', ... % {13} "MSE"
                      VariableNames=labels);
      obj.tab % show tab
    end
    
    function sav_tab(obj)
      fname = strcat(obj.toutDir, "res_tab.txt");
      writetable(obj.tab,fname,'Delimiter',',', ...
        'QuoteStrings',true, 'WriteRowNames',true);  
      %type  fname % disp
      %tab % disp
    end

    function plt_recons_grid(obj)
      nSol = size(obj.logs,1)-1;
      TX="$T_{x}$"; TY="$T_{y}$"; TZ="$T_{z}$";
      IN="Interpreter";LT="latex";MK="Marker";
      FS="fontsize";Cr="Color";LW ="LineWidth";
      fig = figure(); % 10*3 subplots 10 KFs * 3 Txyz 
      sgtitle("Key Feature Pose Reconstruction",IN,LT);
      fig.Units    = obj.fig_U;
      fig.Position = obj.fig_pos;
      hold on
      algNames = cell(nSol,0);
      for kf = 1:10 % 10 KFs, 10 rows
        for s = 1:nSol % nAlgs colors
          % log table {"num", "name", "A-model", "vals", "rec"} 
          algNames{s} = obj.logs{s+1,3};
          RL = strcat("$KF_", num2str(kf, "{%02.f}$"));
          dat_a = obj.logs{s+1,6};
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
        saveas(fig, strcat(figname,".png")); % sav as png file
      end
      if ~obj.plt_shw_en
        close(fig);
      end
    end % plt_KFs_grid(obj)
  
    function plt_models_grid(obj)
      nSol = size(obj.logs,1)-1;
      IN="Interpreter";LT="latex";DN='DisplayName';
      FS="fontsize";LW ="LineWidth";
      fig = figure(); hold on
      title("Models $(A_{method})$ in Phase Domain",IN,LT);
      fig.Units    = obj.fig_U;
      fig.Position = obj.fig_pos;
      algNames = cell(nSol,0);
      xlabel("$real$",IN,LT,FS,obj.fig_FS);
      ylabel("$imag.$",IN,LT,FS,obj.fig_FS);
          
      for s = 1:nSol
        algNames{s} = obj.logs{s+1,3}; 
        %vals  = obj.logs{s+1,5};
        %A_vec = obj.logs{s+1,7};
        A_mat = obj.logs{s+1,8};
        real_A = real(A_mat);
        imag_A = imag(A_mat);
        plot(real_A,imag_A,obj.fig_PT(s),LW,obj.fig_LW,DN,algNames{s});
      end
      lg          = legend('show','location','best'); 
      lg.Units    = obj.fig_leg_U;
      lg.Position = obj.fig_leg_pos;
      lg.FontSize = obj.fig_leg_FS;
      grid on;
      if obj.plt_sav_en
        figname = strcat(obj.toutDir,"plt_mdl_phase");
        saveas(fig, figname); % sav as fig file
        saveas(fig, strcat(figname,".png")); % sav as png file
      end
      if ~obj.plt_shw_en
        close(fig);
      end
    end
  end % methods (Access = public) 
end
