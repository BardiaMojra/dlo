classdef config_class < matlab.System 
  properties
    %% features
    test_single_bench_en    = true
    sliding_ref_en          = true
    %% configs --->> write to other modules
    TID               = 'XEst_dev_test'
    projDir           = [pwd '/dlo']
    outDir            = [pwd '/dlo/out']   
    datDir            = [pwd '/dlo/data']   
    st_frame          = nan % start frame index
    end_frame         = nan % end frame index
    del_T             = 0.1 % time period 

    %surfThresh        = 150 % SURF feature detection threshold
    bnum              = 3 % btype subset
    btype             = 'dlo_shape_control' % 10 frames/sec 


    %% cfgs <<--- read from a submod and write to other submods 
    kframes % read from dat_class obj 
    %% private
    toutDir
    ttag % TID+btype
    dat
    %numbtypes    
  end
  methods  % constructor
    
    function obj = config_class(varargin)
      setProperties(obj,nargin,varargin{:}) % init obj w name-value args
      addpath(genpath('./'));
      %addpath(genpath('/home/smerx/DATA')); 
      %addpath(genpath('/home/smerx/git/opengv/matlab')); % add opengv
      init(obj);
    end
  
  end 
  methods (Access = private)
  
    function init(obj)

      obj.ttag            = strcat(obj.TID,'_',obj.btype);
      obj.toutDir         = strcat(obj.outDir,'/',obj.ttag,'/');

      if not(isfolder(obj.toutDir))
        disp("[config]->> test_outDir does NOT exist: ");
        disp(obj.toutDir);
        %pause(5);
        mkdir(obj.toutDir);
        disp("[config]->> directory has been created!");
      end 
      obj.dat = dat_class(btype = obj.btype, datDir = obj.datDir);
      obj.dat.load_cfg(obj);
    end
  
      
  end % methods (Access = private)
end
