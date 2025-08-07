%-----------------------------------------------------------------------
% Job saved on 23-Jun-2014 15:35:38 by cfg_util (rev $Rev: 5797 $)
% spm SPM - SPM12b (6025)
%-----------------------------------------------------------------------
matlabbatch{1}.spm.spatial.smooth.data = {'/Users/cmaumet/Projects/Meta-analysis/Results/2014-06-23 Z-meta/data/TPM.nii,1'};
matlabbatch{1}.spm.spatial.smooth.fwhm = [5 5 5];
matlabbatch{1}.spm.spatial.smooth.dtype = 64;
matlabbatch{1}.spm.spatial.smooth.im = 0;
matlabbatch{1}.spm.spatial.smooth.prefix = 's';
matlabbatch{2}.spm.util.imcalc.input(1) = cfg_dep('Smooth: Smoothed Images', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
matlabbatch{2}.spm.util.imcalc.output = 'WM_mask.nii';
matlabbatch{2}.spm.util.imcalc.outdir = {'/Users/cmaumet/Projects/Meta-analysis/Results/2014-06-23 Z-meta/data'};
matlabbatch{2}.spm.util.imcalc.expression = 'i1<0.02';
matlabbatch{2}.spm.util.imcalc.var = struct('name', {}, 'value', {});
matlabbatch{2}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{2}.spm.util.imcalc.options.mask = 0;
matlabbatch{2}.spm.util.imcalc.options.interp = 1;
matlabbatch{2}.spm.util.imcalc.options.dtype = 4;
