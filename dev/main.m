%% XEst main

%% init
close all; clear; clc;
cfg   = config_class(TID    = 'T00001', ...
                     btype  = 'dlo_shape_control', ...
                     bnum   = 1);

%dlog  = dlogger_class(); dlog.load_cfg(cfg);
piDMDc = piDMD_class(); piDMDc.load_cfg(cfg.dat);
%rpt   = report_class(); rpt.load_cfg(cfg);


%% piDMD


% Generate an orthogonal model
[trueA,~,~] = svd(cfg.dat.dat);
trueVals = eig(trueA);

% Generate random but consistent data
%X = randn(n,m);
%Y = trueA*X;

% Make the data noisy
noiseMag = .5;
Yn = Y + noiseMag*randn(size(Y));
Xn = X + noiseMag*randn(size(X));

% Train the models
[piA, piVals] = piDMD(piDMDc.X,piDMDc.Y,'orthogonal'); % Energy preserving DMD
[exA, exVals] = piDMD(piDMDc.X,piDMDc.Y,'exact'); % Exact DMD

% Display the error between the learned operators
I = eye(n);
disp(['piDMD model error is     ' num2str(norm(piA(I) - trueA,'fro')/norm(trueA,'fro'))])
disp(['exact DMD model error is ' num2str(norm(exA(I) - trueA,'fro')/norm(trueA,'fro')) newline])

%% Plot some results
FS = 'FontSize'; IN = 'Interpreter'; LT = 'Latex'; MS = 'MarkerSize'; LW = 'LineWidth';

figure(1)
clf
plot(exp(1i*linspace(0,2*pi)),'--','Color',[1 1 1]*.5,LW,2)
hold on
p2 = plot((exVals)+1i*eps,'r^',LW,2,MS,10);
p3 = plot((piVals)+1i*eps,'bx',LW,2,MS,10);
p4 = plot((trueVals)+1i*eps,'o','Color',.5*[1 1 1],LW,2,MS,10);
grid on; axis equal; hold off
axis(1.3*[-1,1,-1,1])

legend([p2,p3,p4],{'exact DMD','piDMD','truth'},FS,15,IN,LT)
title('Spectrum of linear operator',FS,20,IN,LT)



%% run
%piDMD.get_model();

% Train the models
%[piA, piVals] = piDMD.train(Xn,Yn,'orthogonal'); % Energy preserving DMD
%[exA, exVals] = piDMD(Xn,Yn,'exact'); % Exact DMD


%% results
%dlog.get_logs();
%dlog.plot_logs();
%dlog.save_logs();
%% report
%rpt.gen_plots(cfg.dat, dlog, piDMD);
%rpt.gen_report(piDMD);
disp("end of process...");
