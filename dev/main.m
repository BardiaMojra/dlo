%% XEst main
%% init sys
close all; clear; clc;
cfg  = cfg_class(TID    = 'D00002_piDMD_exact_vs_HAVOK', ...
                 brief  = [''], ...
                 bnum   = 1, ...
                 end_frame  = 10000);
dlgr  = dlgr_class(); dlgr.load_cfg(cfg);
%rpt   = report_class(); rpt.load_cfg(cfg);
%% init app modules
pi    = piDMD_class(); pi.load_cfg(cfg); 
hvk   = HAVOK_class(); hvk.load_cfg(cfg);
%knc   = KRONIC_class(); knc.load_cfg(cfg);
%% run
% piDMD methods
% "exact", "exactSVDS", "orthogonal", "uppertriangular", "lowertriangular" ,  
% "diagonal", "diagonalpinv", "diagonaltls", "symtridiagonal", ... 
% "circulant", "circulantTLS", "circulantunitary", "circulantsymmetric","circulantskewsymmetric", ...
% "BCCB", "BCCBtls", "BCCBskewsymmetric", "BCCBunitary", "hankel", "toeplitz", ...
% "symmetric", "skewsymmetric"]

gt_mld      = model_class(name = "ground truth", mthd = "gt", rec = pi.dat); % gt
piExct_mdl  = pi.est(pi.X, pi.Y, "piDMD exact", "exact"); % piDMD baseline
C_mdl  = pi.est(pi.X, pi.Y, "piDMD orth", "orthogonal"); 

% HAVOK methods @todo investiage basis functions 
% add errs 
% plot A kernel
hvk_mdl  = hvk.est(hvk.x, hvk.r, "HAVOK");
%% results
% piDMD models
dlgr.add_mdl(gt_mld);
dlgr.add_mdl(piExct_mdl); % baseline

%
%dlgr.add_mdl(A_mdl);
%dlgr.add_mdl(B_mdl);
dlgr.add_mdl(C_mdl);

% HAVOK models
dlgr.add_mdl(hvk_mdl);
%dlgr.add_mdl(piCirSkSymt_mdl);

%% post processing 
dlgr.get_errs(); 
dlgr.get_tab(); % get res table
dlgr.sav_tab(); % sav log table - result tab
dlgr.plt_recons_grid();
%dlgr.plt_models_grid();

%dlog.get_logs();
%dlog.plot_logs();
%dlog.save_logs();
%% report
%rpt.gen_plots(cfg.dat, dlog, piDMD);
%rpt.gen_report(piDMD);
disp("end of process...");


