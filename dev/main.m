%% DLO main
%% init sys 
warning('off','all')
close all; clear; clc;
cfg  = cfg_class(TID    = ['D000', '01', '_piDMD_', 'vars'], ...
                 brief  = [""], ...
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
gt_m      = model_class(mthd = "ground truth", rec = pi.dat); % gt
pi_m  = pi.get_model(pi.X, pi.Y, "exact", ''); % piDMD baseline
%A_m  = pi.get_model(pi.X, pi.Y, "piDMD orth", "orthogonal"); 
%B_m  = pi.get_model(pi.X, pi.Y, "piDMD orth", "orthogonal"); 

% piDMD methods B000
%extS_mA = pi.get_model(pi.X, pi.Y, "exactSVDS",  "A"); % 01
orth_mA = pi.get_model(pi.X, pi.Y, "orthogonal", "A"); % 02 r
%orth_mB = pi.get_model(pi.X, pi.Y, "orthogonal", "B:r40",40); % 02 r
%D_mA  = pi.get_model(pi.X, pi.Y, "uppertriangular"); % 03
%C_mA  = pi.get_model(pi.X, pi.Y, "lowertriangular"); % 04
diag_mA  = pi.get_model(pi.X, pi.Y, "diagonal", "A"); % 05
diag_mB  = pi.get_model(pi.X, pi.Y, "diagonal", "B:d2",2); % 05
diag_mC  = pi.get_model(pi.X, pi.Y, "diagonal", "C:d3",3); % 05
diag_mD  = pi.get_model(pi.X, pi.Y, "diagonal", "C:d4",4); % 05
diag_mE  = pi.get_model(pi.X, pi.Y, "diagonal", "C:d6",6); % 05
%F_mA  = pi.get_model(pi.X, pi.Y, "diagonaltls"); % 07
%C_mA  = pi.get_model(pi.X, pi.Y, "symtridiagonal"); % 08
%circ_mA = pi.get_model(pi.X, pi.Y, "circulant", "A"); % 09
%cTLS_mA = pi.get_model(pi.X, pi.Y, "circulantTLS", "A"); % 10
%I_mA  = pi.get_model(pi.X, pi.Y, "circulantunitary"); % 11
%J_mA  = pi.get_model(pi.X, pi.Y, "circulantsymmetric"); % 12
%K_mA  = pi.get_model(pi.X, pi.Y, "circulantskewsymmetric"); % 13 
%BCCB_mA  = pi.get_model(pi.X, pi.Y, "BCCB", "A:s[1 1]", [1 1]); % 14
%C_mA  = pi.get_model(pi.X, pi.Y, "TLS"); % 15
%BC_mA  = pi.get_model(pi.X, pi.Y, "BC", "A:s[2 2]", [2 2]); % 16
%C_mA  = pi.get_model(pi.X, pi.Y, "BCtri"); % 17
%C_mA  = pi.get_model(pi.X, pi.Y, "BCtls"); % 18
%C_mA  = pi.get_model(pi.X, pi.Y, ""); % 19
%C_mA  = pi.get_model(pi.X, pi.Y, "BCCBtls"); 
%C_mA  = pi.get_model(pi.X, pi.Y, "BCCBskewsymmetric"); 
%C_mA  = pi.get_model(pi.X, pi.Y, "BCCBunitary"); 
%C_mA  = pi.get_model(pi.X, pi.Y, "hankel"); 
%C_mA  = pi.get_model(pi.X, pi.Y, "toeplitz"); 
%C_mA  = pi.get_model(pi.X, pi.Y, "symmetric"); 
%C_mA  = pi.get_model(pi.X, pi.Y, "skewsymmetric"); 

% HAVOK methods @todo investiage basis functions 
%hvk_mA  = hvk.est(hvk.x, hvk.r, "HAVOK");

%% results
% piDMD models
dlgr.add_mdl(gt_m);
dlgr.add_mdl(pi_m); % piDMD baseline
%dlgr.add_mdl(A_mA); % pot sol A
%dlgr.add_mdl(B_mA);
%dlgr.add_mdl(C_mA);
%dlgr.add_mdl(extS_mA);
dlgr.add_mdl(orth_mA);
%dlgr.add_mdl(orth_mB);
dlgr.add_mdl(diag_mA);
dlgr.add_mdl(diag_mB);
dlgr.add_mdl(diag_mC);
dlgr.add_mdl(diag_mD);
dlgr.add_mdl(diag_mE);
%dlgr.add_mdl(circ_mA);
%dlgr.add_mdl(cTLS_mA);
%dlgr.add_mdl(BC_mA  );


% HAVOK models
%dlgr.add_mdl(hvk_mA);

%% post processing 
dlgr.get_errs(); 
dlgr.get_tab(); % get res table
dlgr.plt_recons_grid();
dlgr.plt_A_roots(); % overlay in one fig
dlgr.plt_A_roots_sep(); % separate figs 
dlgr.plt_A_bmaps_sep(); % separate figs 
dlgr.plt_A_surfs_sep(); % separate figs 
%dlgr.plt_A_hmaps_sep(); % separate figs 

%% report
%rpt.gen_plots(cfg.dat, dlog, piDMD);
%rpt.gen_report(piDMD);
disp("end of process...");


