classdef model_class < matlab.System
  properties
    %% class
    cName       = "model"
    note        = ["model class is used as a general class for system " ...
      "operations, i.e. plots and general data/output logging."]
    sav_mdl_en     = true
    shw_mdl_en     = true
    %sliding_ref_en  % cfg argin
    %% cfg (argin)
    TID     
    ttag    
    toutDir 
    %% vars (argin)
    name % mdl name 
    mthd    = [] % piDMD, HAVOK
    cons    = [] % e.g. orth
    label   = [] % show model cfg and is used in plots
    A       = [] % state transient function pointer (per piDMD)
    Aproj   = [] % A projection matrix
    Atilde  = [] % A est matrix 
    eVals   = []
    eVecs   = []
    rec     = []
    A_eV   = [] % eigenFunc vec
    A_eM   = [] % eigenFunc matrix
    % inputs 
    r % rank
    d % band width of diag 
    s % block size [2 3]
    p % num elements in the block 

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

    end
  
    function get_eigModel(obj)
      if contains("piDMD",obj.mthd,"IgnoreCase",true)
        if ~isempty(obj.Aproj)
          obj.A_eM = obj.Aproj;
          fprintf("[model.get_eigModel]-->> %0.10s - %0.10s: Aproj  is used as A_eM!\n",obj.mthd,obj.cons);
        end
        if ~isempty(obj.Atilde)
          obj.A_eM = obj.Atilde;
          fprintf("[model.get_eigModel]-->> %0.10s - %0.10s: Atilde is used as A_eM!\n",obj.mthd,obj.cons);
        end
        if ~isempty(obj.Asparse)
          obj.A_eM = obj.Asparse;
          fprintf("[model.get_eigModel]-->> %0.10s - %0.10s: Asparse is used as A_eM!\n",obj.mthd,obj.cons);
        end
        
        %figure; surf(obj.A_eM);
        obj.A_eV = obj.A(obj.eVals);
        %obj.A_mat = obj.A_vec*obj.A_vec';
      elseif contains("HAVOK",obj.mthd,"IgnoreCase",true)
        obj.A_eV = obj.A(obj.eVals);
      else
        fprintf("[model.get_eigModel]->> undefined or no mthd: %s \n", obj.mthd);
      end
    end
      
    function sav(obj) 
      if ~isempty(obj.toutDir) % --->> save logs to file
        tag = strrep(obj.name," ","_");
        tag = strrep(tag,"-","_");  
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
        if ~isempty(obj.A_eV)
          fname = strcat(obj.toutDir,"log_",tag,"_A_eV.csv"); % sav A_vec
          writematrix(obj.A_eV, fname);
        end
        if ~isempty(obj.A_eM)
          fname = strcat(obj.toutDir,"log_",tag,"_A_eM.csv"); % sav A_mat
          writematrix(obj.A_eM, fname);
        end
      end
    end
  end % methods  % constructor
  methods (Access = public) 
   
  end % methods (Access = private) % private functions
end
