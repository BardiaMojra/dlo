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
    mthd    = [] % piDMD, HAVOK
    A       = [] % state transient function pointer (per piDMD)
    Aproj   = [] % A projection matrix
    Atilde  = [] % A est matrix 
    eVals   = []
    eVecs   = []
    rec
    A_vec   = [] % eigenFunc state stransition vec
    A_mat   = [] % eigenFunc sysmmetric matrix model     % method specific vars
    % inputs 
    s % block size 
    d % band width of diag 
    p % num element for block 
    r % rank

    % other piDMD vars
    eig_Atilde = [] % = eig(Atilde)
    U
    S
    V
    Ux
    Sx
    Vx
    Yproj
    Xproj 
    Uyx
    Vyx
    R
    Q
    Ut
    Asparse 
    Yf
    Xf
    eig_YF
    M
    N
    T % the block tridiagonal matrix

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
      %obj.init();
    end
    
    function init(obj)
      %obj.get_eigenFunc_Rep();
      %obj.sav(); 
    end
  
    function get_eigenFunc_Rep(obj)
      if strcmp(obj.mthd, "piDMD")
        obj.A_vec = obj.A(obj.eVals);
        %obj.A_mat = obj.A_vec*obj.A_vec';
      elseif strcmp(obj.mthd, "HAVOK")
        obj.A_vec = obj.A(obj.eVals);
      else
        fprintf("[model.getEigenFunc_Rep]->> undefined or no mthd...\n");
      end
    end
      
    function sav(obj) 
      if ~isempty(obj.toutDir) % --->> save logs to file
        tag = strrep(obj.name," ","_");
        tag = strrep(tag,"-","_");  
        if (obj.sav_mdl_en==true && ~isempty(obj.A))
          fname = strcat(obj.toutDir,"log_",tag,"_A_mdl"); % sav A_mod
          writematrix(obj.A_mat, fname);
        end
        if ~isempty(obj.Aproj)
          fig = surf(obj.Aproj);
          fname = strcat(obj.toutDir,"log_",tag,"_Aproj.png"); % sav Aproj
          saveas(fig, fname); % sav as png file
          close(fig);
        end
        if ~isempty(obj.eVals)
          fname = strcat(obj.toutDir,"log_",tag,"_eVals.csv"); % sav eVals
          writematrix(obj.eVals, fname);
        end
        if ~isempty(obj.eVecs)
          fname = strcat(obj.toutDir,"log_",tag,"_eVecs.csv"); % sav eVecs
          writematrix(obj.eVecs, fname);
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
