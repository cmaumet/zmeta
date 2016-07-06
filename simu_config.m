avg_n = 20; % Average number of subjects per group
diff_n = 15;

k_ = [25]% 50];%[5 10 25 50];
wth_sigmas = avg_n*[0.25 0.5 1 2 4];%How to compute z with var = 0?
wth_sigma_schemes = {'same'} %, 'diff'}; don't know yet how to deal with uneq var (for FFX!?)

% Between-studies variance (RFX?)
btw_sigmas = [1]%  1];

% Number of subjects per studies     
numsub_schemes = {'same'}%, 'diff'};

% Proportion of studies with software 2 (fraction)
soft_props = [0 1/5 0.5];

% Correction factor with software 2
soft_factors = [1 2 100];

% Study-specific bias due to units mismatch
units = [false, true];

% Type of analysis: one-sample (1), two-sample(2), two-sample
% unbalanced (3)
analysisTypes = [1]% [1 2 3];

% Size of the simulation image (in 1 direction). Each voxel of the
% simulation image is a simulation sample.
nSimuOneDir = 30;%100;
nSimu = nSimuOneDir^3;

% Number of subject per study
%     nSubjects = [25 400 100 25]; %[10, 15, 20, 25, 30, 10, 15, 20, 25, 30, 10, 15, 20, 25, 30];
%     nStudies = numel(nSubjects);
