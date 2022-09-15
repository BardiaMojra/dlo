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
    Asparse      % = sparse(Imat,Jmat,Rmat,nx,nx) - diag
    YF       % = eig(m.Yf);
    A_eM    = [] % eigenFunc matrix
    eVals   = []
    eVecs   = []
    rec     = []
    % inputs 
    r % rank
    d % band width of diag 
    s % block size [2 3]
    p % num elements in the block 
    % piDMD vars
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
    R % uTri
    Q % lTri
    Ut
    M
    N
    T % the block tridiagonal matrix

    % errs
    st_errs % state errors 
    L1
    L2
    MAE
    MSE


    % HAVOK
    B_frcin % HAVOK
  end
  methods  % constructor
    function obj = model_class(varargin) % init obj w name-value args
      setProperties(obj,nargin,varargin{:}) % set toutDir via varargin
      obj.init();
    end
    
    function init(obj)
      obj.name = strcat(obj.mthd," ",obj.cons," ",obj.label," ");
    end
  
    function get_eigModel(obj)
      if strcmp("piDMD",obj.mthd)
        if strcmp(obj.cons,'exact') || strcmp(obj.cons,'exactSVDS')
          obj.A_eM = obj.Atilde;
          fprintf("[model.get_eigModel]-->> %s: Atilde taken as A_eM!\n",obj.name);         
        elseif strcmp(obj.cons,'orthogonal')
          obj.A_eM = obj.Aproj;
          fprintf("[model.get_eigModel]-->> %s: Aproj taken as A_eM!\n",obj.name);
        elseif strcmp(obj.cons,'uppertriangular') || strcmp(obj.cons,'lowertriangular') 
          obj.A_eM = obj.A;
          fprintf("[model.get_eigModel]-->> %s: A taken as A_eM!\n",obj.name);
        elseif startsWith(obj.cons,'diagonal') 
          obj.A_eM = obj.Asparse;
          fprintf("[model.get_eigModel]-->> %s: Asparse taken as A_eM!\n",obj.name);
        elseif strcmp(obj.cons,'symmetric') || strcmp(obj.cons,'skewsymmetric')
          obj.A_eM = obj.YF;
          fprintf("[model.get_eigModel]-->> %s: YF taken as A_eM!\n",obj.name);

        elseif strcmp(obj.cons,'toeplitz') || strcmp(obj.cons,'hankel')
          obj.A_eM = obj.A; 
          fprintf("[model.get_eigModel]-->> %s: A taken as A_eM!\n",obj.name);
        elseif startsWith(obj.cons,'circulant')
          obj.A_eM = real(obj.eVals)*real(obj.eVals'); % TLS, circ
          fprintf("[model.get_eigModel]-->> %s: re{eVals}*re{eVals}' taken as A_eM!\n",obj.name);
        %elseif strcmp(obj.cons,'BCCB') 
        %elseif strcmp(obj.cons,'BC') || strcmp(obj.cons,'BCtri') || strcmp(obj.cons,'BCtls')
        %elseif strcmp(obj.cons,'symtridiagonal')        
        else
          fprintf("[model.get_eigModel]-->> %s: takes no model!\n",obj.name);
          error("[model.get_eigModel]-->> %s: takes no model!\n",obj.name);
        end
        %figure; surf(obj.A_eM);
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
