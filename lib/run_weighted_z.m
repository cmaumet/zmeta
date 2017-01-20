function run_weighted_z(out_dir, z_files, n_per_study)
%RUN_WEIGHTED_Z Run weighted-Z meta-analysis
%   RUN_WEIGHTED_Z(DIR, Z_FILES) Run one-sample meta-analysis on 
%       Z_FILES using weighted-Z method, store the results in 
%       OUT_DIR.
    if ~exist_nii(fullfile(out_dir, 'weightedz_ffx_minus_log10_p.nii'))
        % Delete any halted analysis        
        if isdir(out_dir)
            rmdir(out_dir,'s')
        end
        mkdir(out_dir)
        
        matlabbatch{1}.spm.tools.ibma.weightedz.dir = {out_dir};
        matlabbatch{1}.spm.tools.ibma.weightedz.zimages = z_files;
        matlabbatch{1}.spm.tools.ibma.weightedz.nsubjects = n_per_study;
        
        save(fullfile(out_dir, 'matlabbatch.mat'), 'matlabbatch')
        spm_jobman('run', matlabbatch)
    else
        disp('Weighted Z already computed')
    end
end

