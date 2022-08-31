%% XEst main

%% init
close all; clear; clc;
cfg   = config_class(TID        = 'T00005', ...
                     brief      = 'adding HAVOK.', ...
                     bnum       = 1 );%...
                     %end_frame  = 1000);
pi    = piDMD_class(); pi.load_cfg(cfg); 
hvk   = HAVOK_class(); hvk.load_cfg(cfg);
%knc   = KRONIC_class(); knc.load_cfg(cfg);
dlgr  = dlogger_class(); dlgr.load_cfg(cfg);
%rpt   = report_class(); rpt.load_cfg(cfg);

%% run
gt_mld      = model_class('ground truth', [], [], pi.dat); % gt
% piDMD methods
piOrth_mdl  = pi.est(pi.X, pi.Y, 'piDMD orth', 'orthogonal'); % Energy preserving DMD
piExct_mdl  = pi.est(pi.X, pi.Y, 'piDMD exact', 'exact'); % piDMD baseline
%piCirSkSymt_mdl  = pi.est(pi.X, pi.Y, 'piDMD cirSkwSym', 'circulantskewsymmetric'); 
% HAVOK methods
% @todo investiage basis functions 
hvk_mdl  = hvk.est(hvk.x, hvk.r, 'HAVOK');

%% results
dlgr.add_mdl(gt_mld);
dlgr.add_mdl(piOrth_mdl);
dlgr.add_mdl(piExct_mdl);
dlgr.add_mdl(hvk_mdl);
%dlgr.add_mdl(piCirSkSymt_mdl);
dlgr.logs % show logs
dlgr.plt_KFs_grid();

%dlog.get_logs();
%dlog.plot_logs();
%dlog.save_logs();
%% report
%rpt.gen_plots(cfg.dat, dlog, piDMD);
%rpt.gen_report(piDMD);
disp("end of process...");


