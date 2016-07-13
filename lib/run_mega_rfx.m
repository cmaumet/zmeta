function run_mega_rfx(out_dir, con_files, con_files2)
%RUN_MEGA_RFX Run a random-effects GLM  meta-analysis
%   RUN_MEGA_RFX(DIR, CON_FILES) Run one-sample meta-analysis on 
%       CON_FILES using a third level RFX GLM, store the results in 
%       OUT_DIR.
%   RUN_MEGA_RFX(DIR, CON_FILES, CON_FILES2) Run two-sample meta-analysis 
%       on CON_FILES and CON_FILES2 using a third level RFX GLM, store the 
%       results in OUT_DIR.

    if ~exist_nii(fullfile(out_dir, 'mega_rfx_minus_log10_p.nii'))
        % Delete any halted analysis        
        if isdir(out_dir)
            rmdir(out_dir,'s')
        end
        mkdir(out_dir)
        
        if nargin == 2
            matlabbatch{1}.spm.tools.ibma.megarfx.dir = {out_dir};
            matlabbatch{1}.spm.tools.ibma.megarfx.model.one.confiles = con_files;
        else
            matlabbatch{1}.spm.tools.ibma.megarfx.dir = {out_dir};
            matlabbatch{1}.spm.tools.ibma.megarfx.model.two.confiles1 = con_files;
            matlabbatch{1}.spm.tools.ibma.megarfx.model.two.confiles2 = con_files2;
        end
        
        spm_jobman('run', matlabbatch)
    else
        disp('Mega RFX already computed')
    end
end

