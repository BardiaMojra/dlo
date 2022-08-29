classdef config_class < matlab.System 
  properties
    %% class
    class       = 'config'
    note        = ''
    %% features
    %% configs --->> write to other modules
    TID         = '_test_'
    brief       = '' % test brief 
    projDir     =  pwd 
    outDir      = [pwd '/out']   
    datDir      = '~/data'   
    ttag        % test tag [TID]_[btype]_[bnum]% dset
    toutDir     % outDir+ttag
    % dataset 
    btype       = ''
    bnum        = nan % btype subset
    st_frame    = nan % start frame index
    end_frame   = nan % end frame index
    %% private
    dat  
  end
  methods  % constructor
    function obj = config_class(varargin)
      setProperties(obj,nargin,varargin{:}) % init obj w name-value args
      addpath(genpath('./'));
      init(obj);
    end
  end 
  methods (Access = private)
  
    function init(obj)
      assert(~isempty(obj.btype), '[config]->> cfg.btype is empty: %s', ...
        obj.btype)
      if isnan(obj.bnum) % get test tag and toutDir
        obj.ttag  = strcat(obj.TID,'_',obj.btype);
      else
        obj.ttag  = strcat(obj.TID,'_',obj.btype,'_',num2str(obj.bnum,'%02.f'));
      end      
      obj.toutDir = strcat(obj.outDir,'/',obj.ttag,'/');

      if not(isfolder(obj.toutDir)) % create toutDir
        disp("[config]->> test_outDir does NOT exist: ");
        disp(obj.toutDir);
        mkdir(obj.toutDir);
        disp("[config]->> directory has been created!");
      end 

      if ~isempty(obj.brief) % write test brief
        fPath = strcat(obj.toutDir,'/brief.txt');        
        file = fopen(fPath,'wt');
        fprintf(file, obj.TID);
        fprintf(file, obj.brief);
        fclose(file);
      end

      obj.dat = dat_class(btype = obj.btype, datDir = obj.datDir); % load data
      obj.dat.load_cfg(obj);
      obj.st_frame = obj.dat.st_frame;
      obj.end_frame = obj.dat.end_frame;
    end
  end % methods (Access = private)
end
