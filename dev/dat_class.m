classdef dat_class < matlab.System 
  properties
    %% class
    class       = 'dat'
    note        = ''
    %% cfg (argin)
    toutDir         
    datDir            
    st_frame      
    end_frame    
    btype         
    bnum
    %% obj init
    raw   % raw dat as given
    dat   % dat to be used 
    freq
    dt
    tspan
    nSamps
    nVars
    varNames % keep where dat vars are selected 
    %% vars
    KFs_Txyz  % pos of 10 KeyFeats Txyz [10*3] --- 1-30
    LG_Txyz   % pos of left gripper [3] --- 31-33
    LG_Owxyz  % ori of left gripper [4] --- 34-37
    RG_Txyz   % pos of right gripper [3] --- 38-40
    RG_Owxyz  % ori of right gripper [4] --- 41-44
    KFs_Vxyz  % vel of 10 KeyFeats Vxyz [10*3] --- 45-74
    LG_Vxyz   % lin vel left gripper [3] --- 75-77
    LG_Wrpy   % ang vel left gripper [3] -- 78-80
    RG_Vxyz   % lin vel right gripper [3] --- 81-83
    RG_Wrpy   % ang vel right gripper [3] -- 84-86
    KFTs_Txyz % target pos for key feats [10*3] --- 87-116
    KFTs_Vxyz % target vel for key feats [10*3] --- 117-146 (add at init)
    KFs_Tx % [1,4,7,10,13,16,19,22,25,28]
    KFs_Ty % [2,5,8,11,14,17,20,23,26,29]
    KFs_Tz % [3,6,9,12,15,18,21,24,27,30]
    KFs_Vx % [45,48,51,54,57,60,63,66,69,72]
    KFs_Vy % [46,49,52,55,58,61,64,67,70,73]
    KFs_Vz % [47,50,53,56,59,62,65,68,71,74]
    KF01_Tx
    KF02_Tx
    KF03_Tx
    KF04_Tx
    KF05_Tx
    KF06_Tx
    KF07_Tx
    KF08_Tx
    KF09_Tx
    KF10_Tx
    KF01_Ty
    KF02_Ty
    KF03_Ty
    KF04_Ty
    KF05_Ty
    KF06_Ty
    KF07_Ty
    KF08_Ty
    KF09_Ty
    KF10_Ty
    KF01_Tz
    KF02_Tz
    KF03_Tz
    KF04_Tz
    KF05_Tz
    KF06_Tz
    KF07_Tz
    KF08_Tz
    KF09_Tz
    KF10_Tz
    KF01_Vx
    KF02_Vx
    KF03_Vx
    KF04_Vx
    KF05_Vx
    KF06_Vx
    KF07_Vx
    KF08_Vx
    KF09_Vx
    KF10_Vx
    KF01_Vy
    KF02_Vy
    KF03_Vy
    KF04_Vy
    KF05_Vy
    KF06_Vy
    KF07_Vy
    KF08_Vy
    KF09_Vy
    KF10_Vy
    KF01_Vz
    KF02_Vz
    KF03_Vz
    KF04_Vz
    KF05_Vz
    KF06_Vz
    KF07_Vz
    KF08_Vz
    KF09_Vz
    KF10_Vz
    LG_Ow  
    LG_Ox  
    LG_Oy  
    LG_Oz  
    RG_Ow  
    RG_Ox  
    RG_Oy  
    RG_Oz  
    LG_Wr  
    LG_Wp  
    LG_Wy  
    RG_Wr  
    RG_Wp  
    RG_Wy  
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
          num2str(obj.bnum,'%d') '.txt'];
        obj.freq  = 10; % 10Hz given
        obj.dt  = 1/obj.freq;
      else
        error('undefined dataset...');
      end    
      obj.load_dat(); 
      obj.select_dat();
    end

    function load_dat(obj)
      data            = load(obj.datDir);
      % load
      obj.KFs_Txyz    = data(:,1:30);
      obj.LG_Txyz     = data(:,31:33);
      obj.LG_Owxyz    = data(:,34:37);
      obj.RG_Txyz     = data(:,38:40);
      obj.RG_Owxyz    = data(:,41:44);
      obj.KFs_Vxyz    = data(:,45:74);
      obj.LG_Vxyz     = data(:,75:77);
      obj.LG_Wrpy     = data(:,78:80);
      obj.RG_Vxyz     = data(:,81:83);
      obj.RG_Wrpy     = data(:,84:86);
      obj.KFTs_Txyz   = data(:,87:116);   
      obj.KFTs_Vxyz   = zeros(size(data,1),30); % stationary target added as state var
      % since we'll add target as input (forcing) we need to add it as state feat, 
      % as well as its vel.   
      % load 
      obj.KFs_Tx      = data(:,[1,4,7,10,13,16,19,22,25,28]);      
      obj.KFs_Ty      = data(:,[2,5,8,11,14,17,20,23,26,29]);
      obj.KFs_Tz      = data(:,[3,6,9,12,15,18,21,24,27,30]);
      obj.KFs_Vx      = data(:,[45,48,51,54,57,60,63,66,69,72]);
      obj.KFs_Vy      = data(:,[46,49,52,55,58,61,64,67,70,73]);
      obj.KFs_Vz      = data(:,[47,50,53,56,59,62,65,68,71,74]);

      % load
      obj.KF01_Tx     = obj.KFs_Tx(:,01); % KFs_Tx
      obj.KF02_Tx     = obj.KFs_Tx(:,02);
      obj.KF03_Tx     = obj.KFs_Tx(:,03);
      obj.KF04_Tx     = obj.KFs_Tx(:,04);
      obj.KF05_Tx     = obj.KFs_Tx(:,05);
      obj.KF06_Tx     = obj.KFs_Tx(:,06);
      obj.KF07_Tx     = obj.KFs_Tx(:,07);
      obj.KF08_Tx     = obj.KFs_Tx(:,08);
      obj.KF09_Tx     = obj.KFs_Tx(:,09);
      obj.KF10_Tx     = obj.KFs_Tx(:,10);
      obj.KF01_Ty     = obj.KFs_Ty(:,01); % KFs_Ty
      obj.KF02_Ty     = obj.KFs_Ty(:,02);
      obj.KF03_Ty     = obj.KFs_Ty(:,03);
      obj.KF04_Ty     = obj.KFs_Ty(:,04);
      obj.KF05_Ty     = obj.KFs_Ty(:,05);
      obj.KF06_Ty     = obj.KFs_Ty(:,06);
      obj.KF07_Ty     = obj.KFs_Ty(:,07);
      obj.KF08_Ty     = obj.KFs_Ty(:,08);
      obj.KF09_Ty     = obj.KFs_Ty(:,09);
      obj.KF10_Ty     = obj.KFs_Ty(:,10);
      obj.KF01_Tz     = obj.KFs_Tz(:,01); % KFs_Tz
      obj.KF02_Tz     = obj.KFs_Tz(:,02);
      obj.KF03_Tz     = obj.KFs_Tz(:,03);
      obj.KF04_Tz     = obj.KFs_Tz(:,04);
      obj.KF05_Tz     = obj.KFs_Tz(:,05);
      obj.KF06_Tz     = obj.KFs_Tz(:,06);
      obj.KF07_Tz     = obj.KFs_Tz(:,07);
      obj.KF08_Tz     = obj.KFs_Tz(:,08);
      obj.KF09_Tz     = obj.KFs_Tz(:,09);
      obj.KF10_Tz     = obj.KFs_Tz(:,10);
      obj.KF01_Vx     = obj.KFs_Vx(:,01); % KFs_Tx
      obj.KF02_Vx     = obj.KFs_Vx(:,02);
      obj.KF03_Vx     = obj.KFs_Vx(:,03);
      obj.KF04_Vx     = obj.KFs_Vx(:,04);
      obj.KF05_Vx     = obj.KFs_Vx(:,05);
      obj.KF06_Vx     = obj.KFs_Vx(:,06);
      obj.KF07_Vx     = obj.KFs_Vx(:,07);
      obj.KF08_Vx     = obj.KFs_Vx(:,08);
      obj.KF09_Vx     = obj.KFs_Vx(:,09);
      obj.KF10_Vx     = obj.KFs_Vx(:,10);
      obj.KF01_Vy     = obj.KFs_Vy(:,01); % KFs_Ty
      obj.KF02_Vy     = obj.KFs_Vy(:,02);
      obj.KF03_Vy     = obj.KFs_Vy(:,03);
      obj.KF04_Vy     = obj.KFs_Vy(:,04);
      obj.KF05_Vy     = obj.KFs_Vy(:,05);
      obj.KF06_Vy     = obj.KFs_Vy(:,06);
      obj.KF07_Vy     = obj.KFs_Vy(:,07);
      obj.KF08_Vy     = obj.KFs_Vy(:,08);
      obj.KF09_Vy     = obj.KFs_Vy(:,09);
      obj.KF10_Vy     = obj.KFs_Vy(:,10);
      obj.KF01_Vz     = obj.KFs_Vz(:,01); % KFs_Tz
      obj.KF02_Vz     = obj.KFs_Vz(:,02);
      obj.KF03_Vz     = obj.KFs_Vz(:,03);
      obj.KF04_Vz     = obj.KFs_Vz(:,04);
      obj.KF05_Vz     = obj.KFs_Vz(:,05);
      obj.KF06_Vz     = obj.KFs_Vz(:,06);
      obj.KF07_Vz     = obj.KFs_Vz(:,07);
      obj.KF08_Vz     = obj.KFs_Vz(:,08);
      obj.KF09_Vz     = obj.KFs_Vz(:,09);
      obj.KF10_Vz     = obj.KFs_Vz(:,10);
      obj.LG_Ow       = obj.LG_Owxyz(:,1); % LG_Owxyz
      obj.LG_Ox       = obj.LG_Owxyz(:,2);
      obj.LG_Oy       = obj.LG_Owxyz(:,3);
      obj.LG_Oz       = obj.LG_Owxyz(:,4);
      obj.RG_Ow       = obj.RG_Owxyz(:,1); % RG_Owxyz
      obj.RG_Ox       = obj.RG_Owxyz(:,2);
      obj.RG_Oy       = obj.RG_Owxyz(:,3);
      obj.RG_Oz       = obj.RG_Owxyz(:,4);
      obj.LG_Wr       = obj.LG_Wrpy(:,1); % LG_Wrpy
      obj.LG_Wp       = obj.LG_Wrpy(:,2);
      obj.LG_Wy       = obj.LG_Wrpy(:,3);
      obj.RG_Wr       = obj.RG_Wrpy(:,1); % RG_Wrpy
      obj.RG_Wp       = obj.RG_Wrpy(:,2);
      obj.RG_Wy       = obj.RG_Wrpy(:,3);

      
      % get st, end
      if isnan(obj.st_frame); obj.st_frame = 1; end
      if isnan(obj.end_frame); obj.end_frame = size(data,1); end
    end

    function select_dat(obj)
      %% select data
      % make sure to follow state space formulation for Hamiltonian energy
      % system [ x; dx], where x is set state vars ([nSamps, nFeats]), and 
      % dx is state vars time derivative.  
      
      %obj.dat = cat(2, ... % adj_dims_dat
      %              obj.LG_Owxyz, ...
      %              obj.KFs_Tx, ...
      %              obj.KFs_Ty, ...
      %              obj.KFs_Tz, ...
      %              obj.RG_Owxyz, ...
      %              obj.LG_Wrpy, ...
      %              obj.KFs_Vx, ...
      %              obj.KFs_Vy, ...
      %              obj.KFs_Vz, ...
      %              obj.RG_Wrpy);
      
      %obj.dat = cat(2, ... % normal dat 
      %              obj.LG_Owxyz, ... 
      %              obj.KFs_Txyz, ... 
      %              obj.RG_Owxyz, ... 
      %              obj.LG_Wrpy, ... 
      %              obj.KFs_Vxyz, ... 
      %              obj.RG_Wrpy);

      % LG_Ow LG_Ox LG_Wr, LG_Oy LG_Wp,  x1 dx1 x2 dx2 x3 dx3... y1 dy1 
      obj.dat = cat(2, ... % adj_dims_dat02
                    obj.LG_Ow, ...
                    obj.LG_Ox, ...
                    obj.LG_Wr, ...
                    obj.LG_Oy, ...
                    obj.LG_Wp, ...
                    obj.LG_Oz, ...
                    obj.LG_Wy, ...
                    obj.KF01_Tx, ...
                    obj.KF01_Vx, ...
                    obj.KF02_Tx, ...
                    obj.KF02_Vx, ...
                    obj.KF03_Tx, ...
                    obj.KF03_Vx, ...
                    obj.KF04_Tx, ...
                    obj.KF04_Vx, ...
                    obj.KF05_Tx, ...
                    obj.KF05_Vx, ...
                    obj.KF06_Tx, ...
                    obj.KF06_Vx, ...
                    obj.KF07_Tx, ...
                    obj.KF07_Vx, ...
                    obj.KF08_Tx, ...
                    obj.KF08_Vx, ...
                    obj.KF09_Tx, ...
                    obj.KF09_Vx, ...
                    obj.KF10_Tx, ...
                    obj.KF10_Vx, ...
                    obj.KF01_Ty, ...
                    obj.KF01_Vy, ...
                    obj.KF02_Ty, ...
                    obj.KF02_Vy, ...
                    obj.KF03_Ty, ...
                    obj.KF03_Vy, ...
                    obj.KF04_Ty, ...
                    obj.KF04_Vy, ...
                    obj.KF05_Ty, ...
                    obj.KF05_Vy, ...
                    obj.KF06_Ty, ...
                    obj.KF06_Vy, ...
                    obj.KF07_Ty, ...
                    obj.KF07_Vy, ...
                    obj.KF08_Ty, ...
                    obj.KF08_Vy, ...
                    obj.KF09_Ty, ...
                    obj.KF09_Vy, ...
                    obj.KF10_Ty, ...
                    obj.KF10_Vy, ...
                    obj.KF01_Tz, ...
                    obj.KF01_Vz, ...
                    obj.KF02_Tz, ...
                    obj.KF02_Vz, ...
                    obj.KF03_Tz, ...
                    obj.KF03_Vz, ...
                    obj.KF04_Tz, ...
                    obj.KF04_Vz, ...
                    obj.KF05_Tz, ...
                    obj.KF05_Vz, ...
                    obj.KF06_Tz, ...
                    obj.KF06_Vz, ...
                    obj.KF07_Tz, ...
                    obj.KF07_Vz, ...
                    obj.KF08_Tz, ...
                    obj.KF08_Vz, ...
                    obj.KF09_Tz, ...
                    obj.KF09_Vz, ...
                    obj.KF10_Tz, ...
                    obj.KF10_Vz, ...
                    obj.RG_Ow, ...     
                    obj.RG_Ox, ...
                    obj.RG_Wr, ...     
                    obj.RG_Oy, ...
                    obj.RG_Wp, ...     
                    obj.RG_Oz, ...
                    obj.RG_Wy); 

      % cut dat per st:end n finish init 
      obj.dat     = obj.dat(obj.st_frame:obj.end_frame,:);
      obj.nSamps  = size(obj.dat,1);
      obj.nVars   = size(obj.dat,2);
      obj.tspan   = obj.nSamps*obj.dt;
    end
  end
end
 
  
  