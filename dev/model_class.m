classdef model_class < matlab.System
  properties
    %% features 
    models_sav_en     = true
    %sliding_ref_en  % cfg argin
    %% cfg (argin)
    TID     
    ttag    
    toutDir 
    %% model class (argin)
    name % test name 
    label % piDMD label
    A_mdl
    vals
    rec
    err_L1
    err_L2

  end
  methods  % constructor
    function obj = model_class(name, A_mdl, vals, rec, varargin) % init obj w name-value args
      obj.name  = name; 
      obj.A_mdl     = A_mdl;   
      obj.vals  = vals;
      obj.rec   = rec; 
      setProperties(obj,nargin,varargin{:}) 
    end
  
  end % methods  % constructor
  methods (Access = public) 
   
  end % methods (Access = private) % private functions
end
