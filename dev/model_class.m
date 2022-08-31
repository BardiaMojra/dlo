classdef model_class < matlab.System
  properties
     %% class
    cName       = 'model'
    note        = ['model class is used as a general class for system ' ...
      'operations, i.e. plots and general data/output logging.']
    sav_mdl_en     = true
    %sliding_ref_en  % cfg argin
    %% cfg (argin)
    TID     
    ttag    
    toutDir 
    %% model class (argin)
    name % test name 
    label % piDMD/HAVOV label
    A_mdl
    B_frcin
    vals
    rec
    err_L1
    err_L2
    

  end
  methods  % constructor
    function obj = model_class(name, A_mdl, vals, rec, varargin) % init obj w name-value args
      obj.name  = name; 
      obj.A_mdl = A_mdl;   
      obj.vals  = vals;
      obj.rec   = rec; 
      setProperties(obj,nargin,varargin{:}) 
    end
  
    function sav(~)
      
        save strcat(obj.toutDir,'mdl_',obj.name,'.mat')
    end
  end % methods  % constructor
  methods (Access = public) 
   
  end % methods (Access = private) % private functions
end
