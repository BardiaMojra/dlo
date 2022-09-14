%% DLO main
%% init sys 
close all; clear; clc;
cfg  = cfg_class(TID    = ['D000', '01', '_piDMD_', 'adj_dims_dat02'], ...
                 brief  = ["Added orientation states "], ...
                 ...
                 bnum   = 1, ...
                 end_frame  = 1000);
dlgr  = dlgr_class(); dlgr.load_cfg(cfg);
%rpt   = report_class(); rpt.load_cfg(cfg);
%% init app modules
pi    = piDMD_class(); pi.load_cfg(cfg); 
hvk   = HAVOK_class(); hvk.load_cfg(cfg);
%knc   = KRONIC_class(); knc.load_cfg(cfg);

%% run
gt_mld      = model_class(name = "ground truth", mthd = "gt", rec = pi.dat); % gt
piExct_mdl  = pi.get_model(pi.X, pi.Y, "exact", ''); % piDMD baseline
%A_mdl  = pi.get_model(pi.X, pi.Y, "piDMD orth", "orthogonal"); 
%B_mdl  = pi.get_model(pi.X, pi.Y, "piDMD orth", "orthogonal"); 



%C_mdl  = pi.est(pi.X, pi.Y, "uppertriangular"); % 03

% piDMD methods B000
B_mdl  = pi.get_model(pi.X, pi.Y, "exactSVDS", ""); % 01
C_mdl  = pi.get_model(pi.X, pi.Y, "orthogonal", ""); % 02 r
%D_mdl  = pi.get_model(pi.X, pi.Y, "uppertriangular"); % 03
%C_mdl  = pi.get_model(pi.X, pi.Y, "lowertriangular"); % 04
D_mdl  = pi.get_model(pi.X, pi.Y, "diagonal", " - d=2", 2); % 05
E_mdl  = pi.get_model(pi.X, pi.Y, "diagonal", " - d=1", 1); % 05
F_mdl  = pi.get_model(pi.X, pi.Y, "diagonal", " - d=6", 6); % 06
%F_mdl  = pi.get_model(pi.X, pi.Y, "diagonaltls"); % 07
%C_mdl  = pi.get_model(pi.X, pi.Y, "symtridiagonal"); % 08
%G_mdl  = pi.get_model(pi.X, pi.Y, "circulant"); % 09
%H_mdl  = pi.get_model(pi.X, pi.Y, "circulantTLS"); % 10
%I_mdl  = pi.get_model(pi.X, pi.Y, "circulantunitary"); % 11
%J_mdl  = pi.get_model(pi.X, pi.Y, "circulantsymmetric"); % 12
%K_mdl  = pi.get_model(pi.X, pi.Y, "circulantskewsymmetric"); % 13 
%C_mdl  = pi.get_model(pi.X, pi.Y, "BCCB", [9 9]); % 14
%C_mdl  = pi.get_model(pi.X, pi.Y, "TLS"); % 15
%C_mdl  = pi.get_model(pi.X, pi.Y, "BC"); % 16
%C_mdl  = pi.get_model(pi.X, pi.Y, "BCtri"); % 17
%C_mdl  = pi.get_model(pi.X, pi.Y, "BCtls"); % 18
%C_mdl  = pi.get_model(pi.X, pi.Y, ""); % 19
%C_mdl  = pi.get_model(pi.X, pi.Y, "BCCBtls"); 
%C_mdl  = pi.get_model(pi.X, pi.Y, "BCCBskewsymmetric"); 
%C_mdl  = pi.get_model(pi.X, pi.Y, "BCCBunitary"); 
%C_mdl  = pi.get_model(pi.X, pi.Y, "hankel"); 
%C_mdl  = pi.get_model(pi.X, pi.Y, "toeplitz"); 
%C_mdl  = pi.get_model(pi.X, pi.Y, "symmetric"); 
%C_mdl  = pi.get_model(pi.X, pi.Y, "skewsymmetric"); 

% HAVOK methods @todo investiage basis functions 
%hvk_mdl  = hvk.est(hvk.x, hvk.r, "HAVOK");

%% results
% piDMD models
dlgr.add_mdl(gt_mld);
dlgr.add_mdl(piExct_mdl); % baseline

%
%dlgr.add_mdl(A_mdl);
dlgr.add_mdl(B_mdl);
%dlgr.add_mdl(C_mdl);
dlgr.add_mdl(C_mdl);
dlgr.add_mdl(D_mdl);
dlgr.add_mdl(E_mdl);
dlgr.add_mdl(F_mdl);
%dlgr.add_mdl(G_mdl);
%dlgr.add_mdl(H_mdl);
%dlgr.add_mdl(I_mdl);
%dlgr.add_mdl(J_mdl);
%dlgr.add_mdl(K_mdl);

% HAVOK models
%dlgr.add_mdl(hvk_mdl);

%% post processing 
dlgr.get_errs(); 
dlgr.get_tab(); % get res table
dlgr.plt_recons_grid();
dlgr.plt_A_roots(); % overlay in one fig
dlgr.plt_A_roots_sep(); % separate figs 
dlgr.plt_A_surfs_sep(); % separate figs 
abiouydlgr.plt_A_hmaps_sep(); % separate figs 

%% report
%rpt.gen_plots(cfg.dat, dlog, piDMD);
%rpt.gen_report(piDMD);
disp("end of process...");


