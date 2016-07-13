function run_fishers( out_dir, z_files )
%RUN_FISHERS Run Fisher's meta-analysis
%   RUN_FISHERS(DIR, Z_FILES) Run one-sample meta-analysis on Z_FILES using
%       Fisher's method and store the results in OUT_DIR.

    if ~exist_nii(fullfile(out_dir, 'fishers_ffx_minus_log10_p.nii'))
        % Delete any halted analysis        
        if isdir(out_dir)
            rmdir(out_dir,'s')
        end
        mkdir(out_dir)        
        
        matlabbatch{1}.spm.tools.ibma.fishers.dir = {out_dir};
        matlabbatch{1}.spm.tools.ibma.fishers.zimages = z_files;
        
        spm_jobman('run', matlabbatch)
    else
        disp('Fisher''s already computed')
    end
end

