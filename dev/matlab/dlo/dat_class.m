classdef dat_class < matlab.System 
  properties
    %% config (constant)
    projDir         
    datDir            
    st_frame        = nan; % start frame index
    end_frame       = nan;% end frame index
    btype           = 'dlo_shape_control'; % default
    bnum        = 1; % aux config, used in KITTI     
    %surfThresh      = 200; % SURF feature detection threshold
    % vars (init internally)
    dat % raw data
    %imgpath
    %datapath
    %kframes
    %posp_i % init frame ground truth pose (given)
    %ppoints_i; % init frame points 
    %Ip_i; % init frame image 
    %skipframe % num of frames skipped bwt two keyframes        
    %numImag % total num of images
    num_frames % num of frames
    %% run-time variables 

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
    KFs_Target % target pos for key feats [10*3] --- 87-116
  
    

  end

  methods % constructor
    function obj = dat_class(varargin) 
      setProperties(obj,nargin,varargin{:}) % init obj w name-value args
    end 
  end % methods % constructor
  methods (Access = public) 
    
    function load_cfg(obj, cfg) 
      obj.projDir        = cfg.projDir;       
      obj.datDir        = cfg.datDir;
      obj.btype         = cfg.btype;  
      obj.bnum          = cfg.bnum;  
      obj.st_frame      = cfg.st_frame;      
      obj.end_frame     = cfg.end_frame;  

      obj.init();

    end

  end 
  methods  (Access = private)
    
    function init(obj)
      %init 
      if strcmp(obj.btype, 'dlo_shape_control')
        obj.datDir = [obj.datDir '/shape_control_of_dlos/3D_txt/state_' ...
          num2str(obj.bnum, '%d') '.txt'];
      else
        error('undefined dataset...')
      end

      
      obj.load_dat(); 

      obj.dat = [obj.KFs_Txyz, ...
                 obj.LG_Txyz,  ... 
                 obj.LG_Owyxz,  ...
                 obj.RG_Txyz,  ...
                 obj.RG_Owyxz,  ...
                 obj.KFs_Vxyz,  ...
                 obj.LG_Vxyz,  ...
                 obj.LG_Wrpy,  ...
                 obj.RG_Vxyz,  ...
                 obj.RG_Wrpy,  ...
                 obj.KFs_Target ] ; 

      obj.dat = obj.dat(obj.st_frame:obj.end_frame,:);
    end

    function load_dat(obj)
      data = load(obj.datDir);
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
      obj.KFs_Target  = data(:,87:116);   

    end
  end
end
 
  
  