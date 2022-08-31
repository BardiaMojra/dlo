classdef config_class < matlab.System 
  properties
    %% class
    class       = 'config'
    note        = ''
    %% features
    sav_cfg_en  = true % sav cfg as txt file
    %% configs --->> write to other modules
    TID         = '_test_'
    brief       = '' % test brief 
    projDir     =  pwd 
    outDir      = [pwd '/out']   
    datDir      = '~/data'   
    ttag        % test tag [TID]_[btype]_[bnum]% dset
    toutDir     % outDir+ttag
    % dataset 
    btype       = 'dlo_shape_control'
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
      
      obj.load_dat(); % 
      obj.sav_cfg(); % sav cfg to file
    end

    function load_dat(obj)
      obj.dat = dat_class(btype = obj.btype, datDir = obj.datDir); % load data
      obj.dat.load_cfg(obj);
      obj.st_frame = obj.dat.st_frame;
      obj.end_frame = obj.dat.end_frame;
    end
    function sav_cfg(obj)
      if ~isempty(obj.brief) || obj.sav_cfg_en
        fname = strcat(obj.toutDir,'cfg.txt'); 
        file = fopen(fname,'wt');
        fprintf(file, ['TID: ', obj.TID, '\n']);
        fprintf(file, ['brief: ', obj.brief, '\n']);
        fprintf(file, ['projDir: ', obj.projDir, '\n']);
        fprintf(file, ['outDir: ', obj.outDir, '\n']);
        fprintf(file, ['datDir: ', obj.datDir, '\n']);
        fprintf(file, ['ttag: ', obj.ttag, '\n']);
        fprintf(file, ['toutDir: ', obj.toutDir, '\n']);
        fprintf(file, ['btype: ', obj.btype, '\n']);
        fprintf(file, ['bnum: ', num2str(obj.bnum), '\n']);
        fprintf(file, ['st_frame: ', num2str(obj.st_frame), '\n']);
        fprintf(file, ['end_frame: ', num2str(obj.end_frame), '\n']);
        fclose(file);
        save strcat(obj.toutDir,'cfg.mat')
      end
    end
  end % methods (Access = private)
end
