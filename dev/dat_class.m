classdef dat_class < matlab.System 
  properties
    %% class
    class       = 'dat'
    note        = ''
    %% features
    %% cfg (argin)
    toutDir         
    datDir            
    st_frame      
    end_frame    
    btype         
    bnum
    %% obj init
    dat 
    freq
    delT
    tspan
    nSamps
    nVars
    varNames % keep where dat vars are selected 
    %% vars
    KFs_Txyz % pos of 10 KeyFeats Txyz [10*3] --- 1-30
    LG_Txyz % pos of left gripper [3] --- 31-33
    LG_Owyxz % ori of left gripper [4] --- 34-37
    RG_Txyz % pos of right gripper [3] --- 38-40
    RG_Owyxz % ori of right gripper [4] --- 41-44
    KFs_Vxyz % vel of 10 KeyFeats Vxyz [10*3] --- 45-74
    LG_Vxyz % lin vel left gripper [3] --- 75-77
    LG_Wrpy % ang vel left gripper [3] -- 78-80
    RG_Vxyz % lin vel right gripper [3] --- 81-83
    RG_Wrpy % ang vel right gripper [3] -- 84-86
    KFTs_Txyz % target pos for key feats [10*3] --- 87-116
    KFTs_Vxyz % target vel for key feats [10*3] --- 117-146 (add at init)

  end

  methods % constructor
    function obj = dat_class(varargin) 
      setProperties(obj,nargin,varargin{:}) % init obj w name-value args
    end 
  end % methods % constructor
  methods (Access = public) 
    
    function load_cfg(obj, cfg) 
      obj.toutDir       = cfg.toutDir;       
      obj.datDir        = cfg.datDir;
      obj.btype         = cfg.btype;  
      obj.bnum          = cfg.bnum;  
      obj.st_frame      = cfg.st_frame;      
      obj.end_frame     = cfg.end_frame;  
      obj.init();
    end
  end 
  methods  (Access = private)
    function init(obj) %init 
      if strcmp(obj.btype, 'dlo_shape_control')
        obj.datDir = [obj.datDir '/shape_control_of_dlos/3D_txt/state_' ...
          num2str(obj.bnum, '%d') '.txt'];
        obj.freq  = 10; % 10Hz given
        obj.delT  = 1/obj.freq;
      else
        error('undefined dataset...')
      end    

      obj.load_dat(); 
      % select state variables 
      % make sure to follow state space formulation for Hamiltonian energy
      % system [ x, dx], where x is set state vars ([nSamps, nFeats]), and 
      % dx is state vars time derivative.  
      obj.dat = [...
                 obj.KFTs_Txyz, ... % kFeat trgt 
                 obj.KFs_Txyz, ... % kFeat
                 %obj.LG_Txyz,  ... 
                 %obj.LG_Owyxz,  ...
                 %obj.RG_Txyz,  ...
                 %obj.RG_Owyxz,  ...
                 obj.KFTs_Vxyz, ... % kFeat trgt
                 obj.KFs_Vxyz,  ... % kFeat
                 %obj.LG_Vxyz,  ...
                 %obj.LG_Wrpy,  ...
                 %obj.RG_Vxyz,  ...
                 %obj.RG_Wrpy,  ...
                 ] ;

        obj.varNames = [...
                 "KFTs_Txyz", ... % kFeat trgt 
                 "KFs_Txyz", ... % kFeat
                 %"LG_Txyz",  ... 
                 %"LG_Owyxz",  ...
                 %"RG_Txyz",  ...
                 %"RG_Owyxz",  ...
                 "KFTs_Vxyz", ... % kFeat trgt
                 "KFs_Vxyz",  ... % kFeat
                 %"LG_Vxyz",  ...
                 %"LG_Wrpy",  ...
                 %"RG_Vxyz",  ...
                 %"RG_Wrpy",  ...
                 ] ; 
    end

    function load_dat(obj)
      data            = load(obj.datDir);
      obj.KFs_Txyz    = data(:,1:30);
      obj.LG_Txyz     = data(:,31:33);
      obj.LG_Owyxz    = data(:,34:37);
      obj.RG_Txyz     = data(:,38:40);
      obj.RG_Owyxz    = data(:,41:44);
      obj.KFs_Vxyz    = data(:,45:74);
      obj.LG_Vxyz     = data(:,75:77);
      obj.LG_Wrpy     = data(:,78:80);
      obj.RG_Vxyz     = data(:,81:83);
      obj.RG_Wrpy     = data(:,84:86);
      obj.KFTs_Txyz   = data(:,87:116);   
      obj.KFTs_Vxyz   = zeros(size(data,1),30); % stationary target added as state var
      % since we'll add target as input (forcing) we need to add it as state feat, 
      % as well as its vel.   

      % get st, end, nSamps, nVars, n tspan
      if isnan(obj.st_frame); obj.st_frame = 1; end
      if isnan(obj.end_frame); obj.end_frame = size(obj.dat,1); end
      obj.dat = obj.dat(obj.st_frame:obj.end_frame,:);
      obj.nSamps  = size(obj.dat,1);
      obj.nVars   = size(obj.dat,2);
      obj.tspan   = obj.nSamps*obj.delT;
    end
  end
end
 
  
  