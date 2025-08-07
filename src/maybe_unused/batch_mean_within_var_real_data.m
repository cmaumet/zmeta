%-----------------------------------------------------------------------
% Job configuration created by cfg_util (rev $Rev: 4252 $)
%-----------------------------------------------------------------------
%%
matlabbatch{1}.spm.util.imcalc.input = {
                                        '/Users/cmaumet/Projects/Meta-analysis/Results/Pain_studies Miccai/Real data/conweighted_var_filtered_func_data.nii,1'
                                        '/Users/cmaumet/Projects/Meta-analysis/Results/Pain_studies Miccai/Real data/conweighted_var_filtered_func_data.nii,2'
                                        '/Users/cmaumet/Projects/Meta-analysis/Results/Pain_studies Miccai/Real data/conweighted_var_filtered_func_data.nii,3'
                                        '/Users/cmaumet/Projects/Meta-analysis/Results/Pain_studies Miccai/Real data/conweighted_var_filtered_func_data.nii,4'
                                        '/Users/cmaumet/Projects/Meta-analysis/Results/Pain_studies Miccai/Real data/conweighted_var_filtered_func_data.nii,5'
                                        '/Users/cmaumet/Projects/Meta-analysis/Results/Pain_studies Miccai/Real data/conweighted_var_filtered_func_data.nii,6'
                                        '/Users/cmaumet/Projects/Meta-analysis/Results/Pain_studies Miccai/Real data/conweighted_var_filtered_func_data.nii,7'
                                        '/Users/cmaumet/Projects/Meta-analysis/Results/Pain_studies Miccai/Real data/conweighted_var_filtered_func_data.nii,8'
                                        '/Users/cmaumet/Projects/Meta-analysis/Results/Pain_studies Miccai/Real data/conweighted_var_filtered_func_data.nii,9'
                                        '/Users/cmaumet/Projects/Meta-analysis/Results/Pain_studies Miccai/Real data/conweighted_var_filtered_func_data.nii,10'
                                        '/Users/cmaumet/Projects/Meta-analysis/Results/Pain_studies Miccai/Real data/conweighted_var_filtered_func_data.nii,11'
                                        '/Users/cmaumet/Projects/Meta-analysis/Results/Pain_studies Miccai/Real data/conweighted_var_filtered_func_data.nii,12'
                                        '/Users/cmaumet/Projects/Meta-analysis/Results/Pain_studies Miccai/Real data/conweighted_var_filtered_func_data.nii,13'
                                        '/Users/cmaumet/Projects/Meta-analysis/Results/Pain_studies Miccai/Real data/conweighted_var_filtered_func_data.nii,14'
                                        '/Users/cmaumet/Projects/Meta-analysis/Results/Pain_studies Miccai/Real data/conweighted_var_filtered_func_data.nii,15'
                                        '/Users/cmaumet/Projects/Meta-analysis/Results/Pain_studies Miccai/Real data/conweighted_var_filtered_func_data.nii,16'
                                        '/Users/cmaumet/Projects/Meta-analysis/Results/Pain_studies Miccai/Real data/conweighted_var_filtered_func_data.nii,17'
                                        '/Users/cmaumet/Projects/Meta-analysis/Results/Pain_studies Miccai/Real data/conweighted_var_filtered_func_data.nii,18'
                                        '/Users/cmaumet/Projects/Meta-analysis/Results/Pain_studies Miccai/Real data/conweighted_var_filtered_func_data.nii,19'
                                        '/Users/cmaumet/Projects/Meta-analysis/Results/Pain_studies Miccai/Real data/conweighted_var_filtered_func_data.nii,20'
                                        '/Users/cmaumet/Projects/Meta-analysis/Results/Pain_studies Miccai/Real data/conweighted_var_filtered_func_data.nii,21'
                                        };
%%
matlabbatch{1}.spm.util.imcalc.output = 'mean_within.nii';
matlabbatch{1}.spm.util.imcalc.outdir = {''};
matlabbatch{1}.spm.util.imcalc.expression = 'mean(X)';
matlabbatch{1}.spm.util.imcalc.options.dmtx = 1;
matlabbatch{1}.spm.util.imcalc.options.mask = 0;
matlabbatch{1}.spm.util.imcalc.options.interp = 1;
matlabbatch{1}.spm.util.imcalc.options.dtype = 4;
