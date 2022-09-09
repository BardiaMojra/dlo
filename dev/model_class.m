classdef model_class < matlab.System
  properties
     %% class
    cName       = "model"
    note        = ["model class is used as a general class for system " ...
      "operations, i.e. plots and general data/output logging."]
    sav_mdl_en     = true
    %sliding_ref_en  % cfg argin
    %% cfg (argin)
    TID     
    ttag    
    toutDir 
    %% vars (argin)
    name % mdl name 
    mthd  = [] % piDMD, HAVOK
    A_mdl = [] % state transient function (per piDMD)
    vals  = []
    rec
    A_vec = [] % eigenFunc state stransition vec
    A_mat = [] % eigenFunc sysmmetric matrix model     % method specific vars
    %% private vars
    st_errs % state errors 
    L1
    L2
    MAE
    MSE

    % piDMD

    % HAVOK
    B_frcin % HAVOK
  end
  methods  % constructor
    function obj = model_class(varargin) % init obj w name-value args
      setProperties(obj,nargin,varargin{:}) % set toutDir via varargin
      obj.init();
    end
    
    function init(obj)
      obj.get_eigenFunc_Rep();
      obj.sav(); 
    end
  
    function get_eigenFunc_Rep(obj)
      if strcmp(obj.mthd, "piDMD")
        obj.A_vec = obj.A_mdl(obj.vals);
        %obj.A_mat = obj.A_vec*obj.A_vec';
      elseif strcmp(obj.mthd, "HAVOK")
        obj.A_vec = obj.A_mdl(obj.vals);
      else
        fprintf("[model.getEigenFunc_Rep]->> undefined or no mthd...\n");
      end
    end
      
    function sav(obj) 
      if ~isempty(obj.toutDir) % --->> save logs to file
        tag = strrep(obj.name," ","_");
        tag = strrep(tag,"-","_");  
        if (obj.sav_mdl_en==true && ~isempty(obj.A_mdl))
          fname = strcat(obj.toutDir,"log_",tag,"_A_mdl"); % sav A_mod
          writematrix(obj.A_mat, fname);
        end
        if ~isempty(obj.vals)
          fname = strcat(obj.toutDir,"log_",tag,"_vals.csv"); % sav vals
          writematrix(obj.vals, fname);
        end
        fname = strcat(obj.toutDir,"log_",tag,"_rec.csv"); % sav rec
        writematrix(obj.rec, fname);  
        if ~isempty(obj.A_vec)
          fname = strcat(obj.toutDir,"log_",tag,"_A_vec.csv"); % sav A_vec
          writematrix(obj.A_vec, fname);
        end
        if ~isempty(obj.A_mat)
          fname = strcat(obj.toutDir,"log_",tag,"_A_mat.csv"); % sav A_mat
          writematrix(obj.A_mat, fname);
        end
      end
    end
  end % methods  % constructor
  methods (Access = public) 
   
  end % methods (Access = private) % private functions
end
