function run_mega_ffx(data_dir, out_dir, analysis_type, nsub, k, fsl_designs_dir)
%RUN_MEGA_FFX Run a mixed-effects GLM  meta-analysis
%   RUN_MEGA_FFX(DIR, CON_FILES) Run a meta-analysis on CON_FILES using a 
%       third level FFX GLM, store the results in OUT_DIR.

    if ~exist_nii(fullfile(out_dir,'mega_ffx_minus_log10_p.nii'))
        % Delete any halted analysis        
        if isdir(out_dir)
            rmdir(out_dir,'s')
        end
        mkdir(out_dir)        
        run_fsl_ffx(data_dir, out_dir, analysis_type, nsub, k, fsl_designs_dir)
    else
        disp('Mega FFX (FSL) already computed')
    end

end

