%% DLO main
%% init sys 
close all; clear; clc;
cfg  = cfg_class(TID    = ['B000', '00', '_piDMD_', 'Errs'], ...
                 brief  = [''], ...
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
piExct_mdl  = pi.est(pi.X, pi.Y, "piDMD exact", "exact"); % piDMD baseline
%A_mdl  = pi.est(pi.X, pi.Y, "piDMD orth", "orthogonal"); 
%B_mdl  = pi.est(pi.X, pi.Y, "piDMD orth", "orthogonal"); 

% piDMD methods B000
%C_mdl  = pi.est(pi.X, pi.Y, "piDMD ExactSVDS", "exactSVDS"); % 01
%C_mdl  = pi.est(pi.X, pi.Y, "piDMD Orth", "orthogonal"); % 02
%C_mdl  = pi.est(pi.X, pi.Y, "piDMD UpTri", "uppertriangular"); % 03
%C_mdl  = pi.est(pi.X, pi.Y, "piDMD LoTri", "lowertriangular"); % 04
%D_mdl  = pi.est(pi.X, pi.Y, "piDMD Diag", "diagonal"); % 05
%E_mdl  = pi.est(pi.X, pi.Y, "piDMD DiagPInv", "diagonalpinv"); % 06
%F_mdl  = pi.est(pi.X, pi.Y, "piDMD DiagTLS", "diagonaltls"); % 07
%C_mdl  = pi.est(pi.X, pi.Y, "piDMD SymTriDiag", "symtridiagonal"); % 08
%G_mdl  = pi.est(pi.X, pi.Y, "piDMD Circ", "circulant"); % 09
%H_mdl  = pi.est(pi.X, pi.Y, "piDMD CircTLS", "circulantTLS"); % 10
%I_mdl  = pi.est(pi.X, pi.Y, "piDMD CircUnitary", "circulantunitary"); % 11
%J_mdl  = pi.est(pi.X, pi.Y, "piDMD CircSym", "circulantsymmetric"); % 12
%K_mdl  = pi.est(pi.X, pi.Y, "piDMD CircSkwSym", "circulantskewsymmetric"); % 13 
%C_mdl  = pi.est(pi.X, pi.Y, "piDMD BCCB", "BCCB"); % 14
%C_mdl  = pi.est(pi.X, pi.Y, "piDMD BCCBtls", "BCCBtls"); 
%C_mdl  = pi.est(pi.X, pi.Y, "piDMD BCCBSkwSym", "BCCBskewsymmetric"); 
%C_mdl  = pi.est(pi.X, pi.Y, "piDMD BCCBUnitary", "BCCBunitary"); 
%C_mdl  = pi.est(pi.X, pi.Y, "piDMD Hankel", "hankel"); 
%C_mdl  = pi.est(pi.X, pi.Y, "piDMD Toeplitz", "toeplitz"); 
%C_mdl  = pi.est(pi.X, pi.Y, "piDMD Sym", "symmetric"); 
%C_mdl  = pi.est(pi.X, pi.Y, "piDMD SkwSym", "skewsymmetric"); 

% HAVOK methods @todo investiage basis functions 
%hvk_mdl  = hvk.est(hvk.x, hvk.r, "HAVOK");

%% results
% piDMD models
dlgr.add_mdl(gt_mld);
dlgr.add_mdl(piExct_mdl); % baseline

%
%dlgr.add_mdl(A_mdl);
%dlgr.add_mdl(B_mdl);
%dlgr.add_mdl(C_mdl);
%dlgr.add_mdl(C_mdl);
%dlgr.add_mdl(D_mdl);
%dlgr.add_mdl(E_mdl);
%dlgr.add_mdl(F_mdl);
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
dlgr.sav_tab(); % sav log table - result tab
dlgr.plt_recons_grid();
dlgr.plt_models_grid();

%% report
%rpt.gen_plots(cfg.dat, dlog, piDMD);
%rpt.gen_report(piDMD);
disp("end of process...");


