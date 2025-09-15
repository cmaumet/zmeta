addpath(pwd);
addpath(fullfile(pwd, 'lib'));
pkg load statistics

meta_sim('/home/cmaumet/simus',true,fullfile(pwd, '..', 'spm12-r7771'), 1, 1, 1, 1, 1, 1);
