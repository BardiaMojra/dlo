%% XEst main

%% init
close all; clear; clc;
cfg   = config_class(TID        = 'T00001', ...
                     btype      = 'dlo_shape_control', ...
                     bnum       = 1, ...
                     end_frame  = 1000  );

dlgr  = dlogger_class(); dlgr.load_cfg(cfg);
pi = piDMD_class(); pi.load_cfg(cfg);
%rpt   = report_class(); rpt.load_cfg(cfg);


%% model and est dat
gt_mld      = model_class('ground truth', [], [], pi.dat);
piOrth_mdl  = pi.est(pi.X, pi.Y, 'piDMD orthogonal', 'orthogonal'); % piDMD orthogonal: Energy preserving DMD
piExct_mdl  = pi.est(pi.X, pi.Y, 'piDMD exact', 'exact'); % piDMD base line


dlgr.add_mdl(gt_mld);
dlgr.add_mdl(piOrth_mdl);
dlgr.add_mdl(piExct_mdl);
dlgr.logs % show logs
dlgr.plt_KFs_grid();

% Rescale reconstructions back into physical norm
%fpiRec = C\piRec; fexRec = C\exRec;

%% Plot results

%plot_hd_dat()



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


