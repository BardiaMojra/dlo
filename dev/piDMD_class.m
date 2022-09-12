classdef piDMD_class < matlab.System 
  properties
    %% class
    cName       = "piDMD" % Physics-informed dynamic mode decompositions
    desc        = ["Computes a dynamic mode decomposition when the solution " ...
      "matrix is constrained to lie in a matrix manifold. The options " ...
      "availablefor the 'method' so far are listed are 'mthd' property."]
    credit      = ""
    %% cfg (argin)
    toutDir
    %% dat (argin)
    dat % dat 
    dt
    nVars % x and dx from raw data
    nSamps
    st_frame
    end_frame
    %% dat n state 
    nss % x state vars (dont include dx)
    x_cols
    xd_cols
    x % states
    xd % state derivative 
    ndat % dat normalized 
    nTrain % num training samps
    tspan
    X % state in ss 
    Y % state est 
    %% piDMD methods (const)
    mthds   = ["exact", "exactSVDS", ...
               "orthogonal", ...
               "uppertriangular", "lowertriangular" , ... % 
               "diagonal", "diagonalpinv", "diagonaltls", "symtridiagonal", ... 
               "circulant", "circulantTLS", "circulantunitary", "circulantsymmetric","circulantskewsymmetric", ...
               "BCCB", "BCCBtls", "BCCBskewsymmetric", "BCCBunitary", "hankel", "toeplitz", ...
               "symmetric", "skewsymmetric"]
  end
  methods % constructor
    
    function obj = piDMD_class(varargin) 
      setProperties(obj,nargin,varargin{:}) % init obj w name-value args
    end 

  end % methods % constructor
  methods (Access = public) 
    
    function load_cfg(obj, cfg) 
      obj.toutDir     = cfg.toutDir;
      obj.dt          = cfg.dat.dt;  
      obj.nVars       = cfg.dat.nVars;  
      obj.nSamps      = cfg.dat.nSamps;       
      obj.st_frame    = cfg.dat.st_frame;   
      obj.end_frame   = cfg.dat.end_frame; 

      obj.init();
      obj.load_dat(cfg.dat.dat);
    end

    function m = get_model(obj, X, Y, mthd, varargin)
      
      m = model_class(name = strcat("piDMD ", mthd));
      [nx, nt] = size(X); 
      
      if strcmp(m.mthd,'exact') || strcmp(m.mthd,'exactSVDS')
        if nargin>4
          m.r = varargin{1};
        else
          m.r = min(nx,nt);
        end
        if strcmp(mthd,'exact')
          [m.Ux,m.Sx,m.Vx] = svd(X,0);
          m.Ux = m.Ux(:,1:m.r); m.Sx = m.Sx(1:m.r,1:m.r); m.Vx = m.Vx(:,1:m.r);
        elseif strcmp(mthd,'exactSVDS')
          [m.Ux,m.Sx,m.Vx] = svds(X,m.r);
        end
        m.Atilde = (m.Ux'*Y)*m.Vx*pinv(m.Sx);
        m.A = @(v) m.Ux*(m.Atilde*(m.Ux'*v));
        m.eigen_Atilde = eig(m.Atilde);
        [m.eVecs, m.eVals] = eig(m.Atilde);
        m.eVals = diag(m.eVals); 
        m.eVecs = Y*m.Vx*pinv(m.Sx)*m.eVecs./m.eVals.';
      elseif strcmp(m.mthd,'orthogonal')
        if nargin>4
          m.r = varargin{1}; 
        else 
          m.r = min(nx,nt);
        end
        [m.Ux,~,~] = svd(X,0); m.Ux = m.Ux(:,1:m.r);
        m.Yproj = m.Ux'*Y; m.Xproj = m.Ux'*X; % Project X and Y onto principal components
        [m.Uyx, ~, m.Vyx] = svd(Yproj*Xproj',0);
        m.Aproj = m.Uyx*m.Vyx';    
        m.A = @(x) m.Ux*(m.Aproj*(m.Ux'*x));
        [m.eVecs, m.eVals] = eig(m.Aproj);
      elseif strcmp(m.mthd,'uppertriangular')
        [m.R,m.Q] = obj.rq(X); % Q*Q' = I
        m.Ut = triu(Y*m.Q');
        m.A = m.Ut/m.R;
      elseif strcmp(m.mthd,'lowertriangular')  
        m.A = rot90(piDMD(flipud(X),flipud(Y),'uppertriangular'),2);
% The codes allows for matrices of variable banded width. The fourth input,
% a 2xn matrix called d, specifies the upper and lower bounds of the
% indices of the non-zero elements. The first column corresponds to the width of
% the band below the diagonal and the second column is the width of the
% band above. For example, a diagonal matrix would have d = ones(nx,2) and 
% a tridiagonal matrix would have d = [2 2]+zeros(nx,2). If you only specify
% d as a scalar then the algorithm converts the input to obtain a banded 
% diagonal matrix of width d. 
      elseif startsWith(m.mthd,'diagonal') 
        if nargin>3
          d = varargin{1}; % arrange d into an nx-by-2 matrix
          if numel(d) == 1
            d = d*ones(nx,2);
          elseif numel(d) == nx
            d = repmat(d,[1,2]);
          elseif any(size(d)~=[nx,2])
            error('Diagonal number is not in an allowable format.')
          end
        else 
          d = ones(nx,2); % default is for a diagonal matrix
        end
        % Allocate cells to build sparse matrix
        Icell = cell(1,nx); Jcell = cell(1,nx); Rcell = cell(1,nx);
        for j = 1:nx
          l1 = max(j-(d(j,1)-1),1); l2 = min(j+(d(j,2)-1),nx);
          C = X(l1:l2,:); b = Y(j,:); % preparing to solve min||Cx-b|| along each row
          if strcmp(mthd,'diagonal')
            sol = b/C;
          elseif strcmp(mthd,'diagonalpinv')
            sol = b*pinv(C);
          elseif strcmp(mthd,'diagonaltls')
            sol = tls(C.',b.').';
          end
          Icell{j} = j*ones(1,1+l2-l1); Jcell{j} = l1:l2; Rcell{j} = sol;
        end
        Imat = cell2mat(Icell); Jmat = cell2mat(Jcell); Rmat = cell2mat(Rcell);
        Asparse = sparse(Imat,Jmat,Rmat,nx,nx);
        A = @(v) Asparse*v;
        if nargout==2
          eVals = eigs(Asparse,nx);
          varargout{1} = eVals;
        elseif nargout>2
          [eVecs, eVals] = eigs(Asparse,nx);
          varargout{1} = diag(eVals); varargout{2} = eVecs;
        end
      elseif strcmp(mthd,'symmetric') || strcmp(mthd,'skewsymmetric')
        [Ux,S,V] = svd(X,0);
        C = Ux'*Y*V;
        C1 = C;
        if nargin>3; r = varargin{1}; else; r = rank(X); end
        Ux = Ux(:,1:r);
        Yf = zeros(r);
        if strcmp(mthd,'symmetric') 
          for i = 1:r
            Yf(i,i) = real(C1(i,i))/S(i,i);
            for j = i+1:r
              Yf(i,j) = (S(i,i)*conj(C1(j,i)) + S(j,j)*C1(i,j)) / (S(i,i)^2 + S(j,j)^2);
            end
          end
          Yf = Yf + Yf' - diag(diag(real(Yf)));
        elseif strcmp(mthd,'skewsymmetric')
          for i = 1:r
            Yf(i,i) = 1i*imag(C1(i,i))/S(i,i);
            for j = i+1:nx
              Yf(i,j) = (-S(i,i)*conj(C1(j,i)) + S(j,j)*(C1(i,j))) / (S(i,i)^2 + S(j,j)^2);
            end
          end
          Yf = Yf - Yf' - 1i*diag(diag(imag(Yf)));
        end

        A = @(v) Ux*Yf*(Ux'*v);

        if nargout==2
          varargout{1} = eig(Yf);
        elseif nargout>2
          [eVecs,eVals] = eig(Yf);
          eVals = diag(eVals);
          eVecs = Ux*eVecs;
          varargout{1} = eVals; varargout{2} = eVecs;
        end
      elseif strcmp(mthd,'toeplitz') || strcmp(mthd,'hankel')
        if  strcmp(mthd,'toeplitz'); J = eye(nx); 
        elseif strcmp(mthd,'hankel'); J = fliplr(eye(nx)); end
        Am = fft([eye(nx) zeros(nx)].',[],1)'/sqrt(2*nx); % Define the left matrix
        B = fft([(J*X)' zeros(nt,nx)].',[],1)'/sqrt(2*nx); % Define the right matrix
        BtB = B'*B; 
        AAt = ifft(fft([eye(nx) zeros(nx); zeros(nx,2*nx)]).').'; % Fast computation of A*A'
        y = diag(Am'*conj(Y)*B)'; % Construct the RHS of the linear system
        L = (AAt.*BtB.')'; % Construct the matrix for the linear system
        d = [y(1:end-1)/L(1:end-1,1:end-1) 0]; % Solve the linear system
        newA = ifft(fft(diag(d)).').'; % Convert the eigenvalues into the circulant matrix
        A = newA(1:nx,1:nx)*J; % Extract the Toeplitz matrix from the circulant matrix
      elseif startsWith(mthd,'circulant')
        fX = fft(X); fY = fft(conj(Y));
        d = zeros(nx,1);
        if endsWith(mthd,'TLS') % Solve in the total least squares sense     
          for j = 1:nx
            d(j) = tls(fX(j,:)',fY(j,:)');
          end
        elseif ~endsWith(mthd,'TLS') % Solve the other cases
          d = diag(fX*fY')./vecnorm(fX,2,2).^2;
          if endsWith(mthd,'unitary'); d = exp(1i*angle(d));
          elseif endsWith(mthd,'symmetric'); d = real(d);
          elseif endsWith(mthd,'skewsymmetric'); d = 1i*imag(d);
          end
        end
        eVals = d; % These are the eigenvalues
        eVecs = fft(eye(nx)); % These are the eigenvectors
        if nargin>3
          r = varargin{1}; % Rank constraint
          res = diag(abs(fX*fY'))./vecnorm(fX')'; % Identify least important eigenvalues
          [~,idx] = mink(res,nx-r); % Remove least important eigenvalues
          d(idx) = 0; eVals(idx) = []; eVecs(:,idx) = [];
        end
        if nargout>1; varargout{1} = eVals; end
        if nargout>2; varargout{2} = eVecs; end
        A = @(v) fft(d.*ifft(v)); % Reconstruct the operator in terms of FFTs

      elseif strcmp(mthd,'BCCB') || strcmp(mthd,'BCCBtls') || strcmp(mthd,'BCCBskewsymmetric') || strcmp(mthd,'BCCBunitary')
    
        if isempty(varargin); error('Need to specify size of blocks.'); end
        s = varargin{1}; p = prod(s);
        % Equivalent to applying the block-DFT matrix F 
        % defined by F = kron(dftmtx(M),dftmtx(N)) to the 
        % matrix X
        aF =  @(x) reshape(     fft2(reshape(x ,[s,size(x,2)])) ,[p,size(x,2)])/sqrt(p);
        aFt = @(x) conj(aF(conj(x)));
        fX = aF(conj(X)); fY = aF(conj(Y));
        d = zeros(p,1);
            
        if strcmp(mthd,'BCCB') 
        for j = 1:p; d(j) = conj(fX(j,:)*fY(j,:)')/norm(fX(j,:)').^2; end
        elseif strcmp(mthd,'BCCBtls')
        for j = 1:p; d(j) = tls(fX(j,:)',fY(j,:)')'; end
        elseif strcmp(mthd,'BCCBskewsymmetric')
        for j = 1:p; d(j) = 1i*imag(fY(j,:)/fX(j,:)); end
        elseif strcmp(mthd,'BCCBsymmetric')
        for j = 1:p; d(j) = real(fY(j,:)/fX(j,:)); end
        elseif strcmp(mthd,'BCCBunitary')
        for j = 1:p; d(j) = exp(1i*angle(fY(j,:)/fX(j,:))); end
        end

        % Returns a function handle that applies A
        if nargin>4
          r = varargin{2};
          res = diag(abs(fX*fY'))./vecnorm(fX')';
          [~,idx] = mink(res,nx-r);
          d(idx) = 0;
        end
        A = @(x) aF((conj(d).*aFt(x)));
        varargout{1} = d;
        % Eigenvalues are given by d

      elseif strcmp(mthd,'BC') || strcmp(mthd,'BCtri') || strcmp(mthd,'BCtls')
        s = varargin{1}; p = prod(s);
        M = s(2); N = s(1);
        if isempty(s); error('Need to specify size of blocks.'); end
        % Equivalent to applying the block-DFT matrix F 
        % defined by F = kron(dftmtx(M),eye(N)) to the 
        % matrix X
        aF  =  @(x) reshape(fft(reshape(x,[s,size(x,2)]),[],2) ,[p,size(x,2)])/sqrt(M);
        aFt =  @(x) conj(aF(conj(x)));
        fX = aF(X); fY = aF(Y);
        d = cell(M,1);
        for j = 1:M
          ls = (j-1)*N + (1:N);
          if strcmp(mthd,'BC')
            d{j} = fY(ls,:)/fX(ls,:);
          elseif strcmp(mthd,'BCtri')
            d{j} = piDMD(fX(ls,:),fY(ls,:),'diagonal',2);
          elseif strcmp(mthd,'BCtls')
            d{j} = tls(fX(ls,:)',fY(ls,:)')';
          end
        end 
        BD = blkdiag(d{:});
        A = @(v) aFt(BD*aF(v));           
      elseif strcmp(mthd,'symtridiagonal')
        T1e = vecnorm(X,2,2).^2; % Compute the entries of the first block
        T1 = spdiags(T1e,0,nx,nx); % Form the leading block
        T2e = dot(X(2:end,:),X(1:end-1,:),2); % Compute the entries of the second block
        T2 = spdiags([T2e T2e],-1:0,nx,nx-1); % Form the second and third blocks
        T3e = [0; dot(X(3:end,:),X(1:end-2,:),2)]; % Compute the entries of the final block
        T3 = spdiags(T1e(1:end-1) + T1e(2:end),0,nx-1,nx-1) ...
             + spdiags(T3e,1,nx-1,nx-1) + spdiags(T3e,1,nx-1,nx-1)'; % Form the final block
        T = [T1 T2; T2' T3]; % Form the block tridiagonal matrix
        d = [dot(X,Y,2); dot(X(1:end-1,:),Y(2:end,:),2) + dot(X(2:end,:),Y(1:end-1,:),2)]; % Compute the RHS vector
        c = real(T)\real(d); % Take real parts then solve linear system
        % Form the solution matrix
        A = spdiags(c(1:nx),0,nx,nx) + spdiags([0;c(nx+1:end)],1,nx,nx) + spdiags([c(nx+1:end); 0],-1,nx,nx);
      else
        error('The selected method doesn''t exist.');
      end 
    end % get_model()

    function rec = get_rec(obj, m)
      rec = zeros(obj.nVars, obj.nSamps); % reconstruct dat
      rec(:,1) = obj.dat(:,1);       
      for j = 2:obj.nSamps
        rec(:,j) = m.A(rec(:,j-1));
      end
      m.rec = rec;
    end % get_rec()
  
  end 
  methods  (Access = private)
    function init(obj)
      obj.nss       = obj.nVars/2;
      obj.nTrain    = obj.nSamps - 1; 
      obj.x_cols    = 1:obj.nss; 
      obj.xd_cols   = obj.nss+1:obj.nVars; 
      obj.tspan     = obj.dt*obj.nSamps;
    end
    
    function load_dat(obj, dat)
      assert(isequal(mod(size(dat,2),2),0), ...
        "-->>> odd num of state vars: %d", size(dat,2));
      obj.x       = dat(:,obj.x_cols); % state vars 
      obj.xd      = dat(:,obj.xd_cols); % state vars time derivative (vel)
      obj.dat     = [obj.x'; obj.xd']; % reorganize data in state space (ss) formulation 
      obj.ndat    = obj.dat + 1e-1*std(obj.dat,[],2); % norm dat
      obj.X       = obj.dat(:,1:obj.nTrain);
      obj.Y       = obj.dat(:,2:obj.nTrain+1);
    end

    function trajPlot(~,j) % Nice plot of trajectories
      yticks([-pi/4,0,pi/4]); yticklabels([{"$-\pi/4$"},{"0"},{"$\pi/4$"}])
      set(gca,"TickLabelInterpreter","Latex","FontSize",20);grid on
      ylim([-1,1])
      ylabel(j,"Interpreter","latex","FontSize",20)
    end

    function [R,Q,varargout] = rq(A) % Performs RQ decomposition
      n = size(A,1);
      if nargout<3
        [Q,R] = qr(flipud(A)',0);
      else
        [Q,R,P1] = qr(flipud(A)',0);
        P(n+1-P1) = n:-1:1; % arrange permutation in right way
        varargout{1} = P;
      end
      R = rot90(R',2);
      Q = flipud(Q');
      [n,m]=size(A);
      if n>m
        R = [zeros(n,n-m), R];
        Q = [zeros(n-m,m); Q];
      end  
    end % rq()
      
    function [Xhat] = tls(A,B)
      n = size(A,2);
      if size(A,1)~=size(B,1); error('Matrices are not conformant.'); end
      R1 = [A B];
      [~,~,V] = svd(R1,0);
      r = size(A,2);
      R = rq(V(:,r+1:end));Gamma = R(n+1:end,n-r+1:end);
      Z = R(1:n,n-r+1:end);
      Xhat = -Z/Gamma;
    end % tls

    function c = redblue(m)
      %REDBLUE    Shades of red and blue color map
      %  REDBLUE(M), is an M-by-3 matrix that defines a colormap.
      %  The colors begin with bright blue, range through shades of
      %  blue to white, and then through shades of red to bright red.
      %  REDBLUE, by itself, is the same length as the current figure's
      %  colormap. If no figure exists, MATLAB creates one.
      %  For example, to reset the colormap of the current figure:
      %            colormap(redblue)
      %  See also HSV, GRAY, HOT, BONE, COPPER, PINK, FLAG, 
      %  COLORMAP, RGBPLOT.
      %  Adam Auton, 9th October 2009
      if nargin < 1, m = size(get(gcf,'colormap'),1); end
      if (mod(m,2) == 0)
        % From [0 0 1] to [1 1 1], then [1 1 1] to [1 0 0];
        m1 = m*0.5;
        r = (0:m1-1)'/max(m1-1,1);
        g = r;
        r = [r; ones(m1,1)];
        g = [g; flipud(g)];
        b = flipud(r);
      else
        % From [0 0 1] to [1 1 1] to [1 0 0];
        m1 = floor(m*0.5);
        r = (0:m1-1)'/max(m1,1);
        g = r;
        r = [r; ones(m1+1,1)];
        g = [g; 1; flipud(g)];
        b = flipud(r);
      end
      c = [r g b]; 
    end % redblue()

  end % private methods
end
 



  
  