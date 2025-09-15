function run_mega_mfx(data_dir, out_dir, analysis_type, nsub, k, ...
    fsl_designs_dir, flame_type)
%RUN_MEGA_MFX Run a mixed-effects GLM  meta-analysis
%   RUN_MEGA_MFX(DIR, CON_FILES) Run a meta-analysis on CON_FILES using a 
%       third level MFX GLM, store the results in OUT_DIR.

    if ~exist_nii(fullfile(out_dir,'mega_mfx_minus_log10_p.nii'))
        % Delete any halted analysis        
        if isdir(out_dir)
            rmdir(out_dir,'s')
        end
        mkdir(out_dir)
        run_fsl_mfx(data_dir, out_dir, analysis_type, nsub, k, ...
            fsl_designs_dir, flame_type)
    else
        disp(['Mega MFX (FSL FLAME' num2str(flame_type) ') already computed'])
    end

end

