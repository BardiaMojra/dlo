classdef dp_dat < matlab.System 
  properties
    %% class
    class       = 'dp_dat'
    note        = 'double pendulum data class'
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
    dt    %
    tspan
    nSamps
    nVars
    varNames % keep where dat vars are selected 
    %% vars
    t     
    th1   
    th2   
    l1x   
    l1y   
    l2x   
    l2y   
    th1q  
    th1w  
    th2q  
    th2w

    %"t"
    %"th1"
    %"th2"
    %"l1x"
    %"l1y"
    %"l2x"
    %"l2y"
    %"th1q"
    %"th1w"
    %"th2q"
    %"th2w"



  end

  methods % constructor
    function obj = dp_dat(varargin) 
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
      assert(~isempty(obj.bnum),"[dp_dat.init]->> no bnum ...\n")
      if strcmp(obj.btype, 'dp') % --------->>> dp data
        obj.datDir = strcat(obj.datDir,'/vtol/dp_', ...
          num2str(obj.bnum,'%04.f'), '.xlsx');
      else
        error('[dp_dat.init]->> undefined dataset...\n');
      end    
      obj.load_dat(); 
      obj.select_dat();
    end

    function load_dat(obj)
      data            = table2array(readtable(obj.datDir));
      % load
      obj.t     = data(:,1);
      obj.th1   = data(:,2);
      obj.th2   = data(:,3);
      obj.l1x   = data(:,4);
      obj.l1y   = data(:,5);
      obj.l2x   = data(:,6);
      obj.l2y   = data(:,7);
      obj.th1q  = data(:,8);
      obj.th1w  = data(:,9);
      obj.th2q  = data(:,10);
      obj.th2w  = data(:,11);
          
      % get st, end
      if isnan(obj.st_frame); obj.st_frame = 1; end
      if isnan(obj.end_frame); obj.end_frame = size(data,1); end
    end

    function select_dat(obj)
      %% select data
      % make sure to follow state space formulation for Hamiltonian energy
      % system [ x; dx], where x is set state vars ([nSamps, nFeats]), and 
      % dx is state vars time derivative.  
      obj.dat = cat(2, ... 
                    obj.th1q, ...
                    obj.th1w, ...
                    obj.th2q, ...
                    obj.th2w);
      obj.varNames = [ "th1", ...
                       "dth1", ...
                       "th2", ...
                       "dth2"];
      % cut dat per st:end n finish init 
      obj.dat     = obj.dat(obj.st_frame:obj.end_frame,:);
      obj.nSamps  = size(obj.dat,1);
      obj.nVars   = size(obj.dat,2);
      obj.dt      = obj.t(2,1) - obj.t(1,1);
      obj.tspan   = obj.nSamps*obj.dt;
    end
  end
end
 
  
  