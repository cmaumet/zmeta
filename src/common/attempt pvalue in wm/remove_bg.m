%-----------------------------------------------------------------------
% Job saved on 23-Jun-2014 15:38:51 by cfg_util (rev $Rev: 5797 $)
% spm SPM - SPM12b (6025)
%-----------------------------------------------------------------------
matlabbatch{1}.spm.util.imcalc.input = {
                                        '/Users/cmaumet/Projects/Meta-analysis/Results/2014-06-23 Z-meta/data/WM_mask.nii,1'
                                        '/Users/cmaumet/Projects/Meta-analysis/Results/2014-06-23 Z-meta/data/TPM.nii,2'
                                        };
matlabbatch{1}.spm.util.imcalc.output = 'WM_mask_nobg.nii';
matlabbatch{1}.spm.util.imcalc.outdir = {'/Users/cmaumet/Projects/Meta-analysis/Results/2014-06-23 Z-meta/data'};
matlabbatch{1}.spm.util.imcalc.expression = 'i1>0 & i2>0.5';
matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{1}.spm.util.imcalc.options.mask = 0;
matlabbatch{1}.spm.util.imcalc.options.interp = 1;
matlabbatch{1}.spm.util.imcalc.options.dtype = 4;
