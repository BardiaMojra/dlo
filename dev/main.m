%% XEst main

%% init sys
close all; clear; clc;
cfg  = cfg_class(TID    = 'T00007_piDMD_exact_vs_exactSVDS', ...
                 brief  = 'evaluating different piDMD decompositions.', ...
                 bnum   = 1, ...
                 end_frame  = 1000);
dlgr  = dlgr_class(); dlgr.load_cfg(cfg);
%rpt   = report_class(); rpt.load_cfg(cfg);

%% init app modules
pi    = piDMD_class(); pi.load_cfg(cfg); 
hvk   = HAVOK_class(); hvk.load_cfg(cfg);
%knc   = KRONIC_class(); knc.load_cfg(cfg);


%% run
% gt
gt_mld      = model_class(name = 'ground truth', rec = pi.dat); % gt

%% piDMD methods
% "exact", "exactSVDS", ...
% "orthogonal", ...
% "uppertriangular", "lowertriangular" , ... % 
% "diagonal", "diagonalpinv", "diagonaltls", "symtridiagonal", ... 
% "circulant", "circulantTLS", "circulantunitary", "circulantsymmetric","circulantskewsymmetric", ...
% "BCCB", "BCCBtls", "BCCBskewsymmetric", "BCCBunitary", "hankel", "toeplitz", ...
% "symmetric", "skewsymmetric"]
%piOrth_mdl  = pi.est(pi.X, pi.Y, 'piDMD orth', 'orthogonal'); % Energy preserving DMD
piExct_mdl  = pi.est(pi.X, pi.Y, 'piDMD exact', 'exact'); % piDMD baseline

% test
%A_mdl  = pi.est(pi.X, pi.Y, 'piDMD upTri', 'uppertriangular'); 
%B_mdl  = pi.est(pi.X, pi.Y, 'piDMD loTri', 'lowertriangular'); 
C_mdl  = pi.est(pi.X, pi.Y, 'piDMD exactSVDS', 'exactSVDS'); 



% HAVOK methods
% @todo investiage basis functions 
%hvk_mdl  = hvk.est(hvk.x, hvk.r, 'HAVOK');

%% results
% piDMD models
dlgr.add_mdl(gt_mld);
%dlgr.add_mdl(piOrth_mdl);
dlgr.add_mdl(piExct_mdl);
%
%dlgr.add_mdl(A_mdl);
%dlgr.add_mdl(B_mdl);
dlgr.add_mdl(C_mdl);


% HAVOK models
%dlgr.add_mdl(hvk_mdl);
%dlgr.add_mdl(piCirSkSymt_mdl);

%% post processing 
%dlgr.logs.get_tab(); % get res table
%dlgr.logs.sav_tab(); % sav log table - result tab
dlgr.plt_recons_grid();
%dlgr.plt_models_grid();

%dlog.get_logs();
%dlog.plot_logs();
%dlog.save_logs();
%% report
%rpt.gen_plots(cfg.dat, dlog, piDMD);
%rpt.gen_report(piDMD);
disp("end of process...");


