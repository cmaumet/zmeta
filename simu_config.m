nStudiesArray = [25]% 50];%[5 10 25 50];
AVG_NUM_SUB = 20;
NUM_SUB_DIFF = 15;
sigmaSquareArray = AVG_NUM_SUB*[0.25 0.5 1 2 4];%How to compute z with var = 0?
studyVarianceSchemes = {'same'} %, 'diff'}; don't know yet how to deal with uneq var (for FFX!?)

% Between-studies variance (RFX?)
sigmaBetweenStudiesArray = [1]%  1];

% Number of subjects per studies     
subjectPerStudiesScheme = {'same'}%, 'diff'};

% Number of studies with software 2 (fraction)
nStudiesWithSoftware2 = [0 1/5 0.5];

% Correction factor with software 2
sigmaFactorWithSoftware2 = [1 2 100];

% Study-specific bias due to units mismatch
unitMismatch = [false, true];

% Type of analysis: one-sample (1), two-sample(2), two-sample
% unbalanced (3)
analysisTypes = [1]% [1 2 3];

% Size of the simulation image (in 1 direction). Each voxel of the
% simulation image is a simulation sample.
nSimuOneDir = 30;%100;
nSimu = nSimuOneDir^3;