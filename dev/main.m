%% XEst main

%% init
close all; clear; clc;
cfg   = config_class(TID        = 'T00001', ...
                     btype      = 'dlo_shape_control', ...
                     bnum       = 1, ...
                     end_frame  = 1000  );

%dlog  = dlogger_class(); dlog.load_cfg(cfg);
pi = piDMD_class(); pi.load_cfg(cfg);
%rpt   = report_class(); rpt.load_cfg(cfg);


%% piDMD orthogonal - Energy preserving DMD
xn = pi.ndat;
tspan = pi.tspan;
x = pi.dat;
t = pi.st_frame:pi.end_frame;
nt = pi.nSamps;

% Train models
[piA,piVals] = piDMD(pi.X, pi.Y, 'orthogonal');
[exA,exVals] = piDMD(pi.X, pi.Y, 'exact');

% Perform reconstructions
piRec = zeros(pi.nVars,nt); piRec(:,1) = pi.dat(:,1);
exRec = zeros(pi.nVars,nt); exRec(:,1) = pi.dat(:,1);
for j = 2:nt
  piRec(:,j) = piA(piRec(:,j-1));
  exRec(:,j) = exA(exRec(:,j-1));
end

% Rescale reconstructions back into physical norm
%fpiRec = C\piRec; fexRec = C\exRec;

%% Plot results

%plot_hd_dat()

figure(1); LW = 'LineWidth'; IN = 'Interpreter'; LT = 'Latex'; FS = 'FontSize';




dims
dimLabs
% data and datLabs
datLabs
tspan
gtdat
dat01
dat02
dat03
dat04


for dim = 1:xdims

end
subplot(15,1,dim)
c1 = .8*[1 1 1]; c2 = .8*[1 1 1];
plot(tspan, gtdat(dim,:),LW,2,'Color',c1)
hold on
plot(tspan, xn(dim,:),LW,2,'Color',c2)
hold off; trajPlot('measurements'); xticklabels([])

subplot(3,1,2)
plot(tspan, x(1,:),LW,3,'Color', c1)
hold on
plot(tspan, piRec(1,:),'b--',LW,2)
plot(tspan, exRec(1,:),'r--',LW,2)
ylabel('$\theta_1$',IN,LT)
hold off; trajPlot('$\theta_1$'); xticklabels([])
subplot(3,1,3)
l1=plot(t, x(2,:),LW,3,'Color', c2);
hold on
l2=plot(t, piRec(2,:),'b--',LW,2);
l3=plot(t, exRec(2,:),'r--',LW,2);
hold off; xlabel('time',FS,20,IN,LT)
trajPlot('$\theta_2$')
legend([l1,l2,l3],{'truth','piDMD','exact DMD'},IN,LT)






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


