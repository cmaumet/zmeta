function run_stouffers(out_dir, z_files, ffx)
%RUN_STOUFFERS Run Stouffer's meta-analysis
%   RUN_STOUFFERS(DIR, Z_FILES) Run one-sample meta-analysis on 
%       Z_FILES using Stouffer's fixed-effects method, store the results in 
%       OUT_DIR.
%   RUN_STOUFFERS(DIR, Z_FILES, false) Run one-sample meta-analysis on 
%       Z_FILES using Stouffer's random-effects method, store the results 
%       in OUT_DIR.

    if ~exist_nii(fullfile(out_dir, 'stouffers_ffx_minus_log10_p.nii'))
        % Delete any halted analysis        
        if isdir(out_dir)
            rmdir(out_dir,'s')
        end
        mkdir(out_dir)
        
        matlabbatch{1}.spm.tools.ibma.stouffers.dir = {out_dir};
        matlabbatch{1}.spm.tools.ibma.stouffers.zimages = z_files;
        if ffx
            matlabbatch{1}.spm.tools.ibma.stouffers.rfx.RFX_no = 0;
        else
            matlabbatch{1}.spm.tools.ibma.stouffers.rfx.RFX_yes = 0;
        end
        
        save(fullfile(out_dir, 'matlabbatch.mat'), 'matlabbatch')
        spm_jobman('run', matlabbatch)
    else
        disp('Stouffer''s already computed')
    end
end

