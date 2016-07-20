function run_permut_con(out_dir, nperms, con_files, con_files2)
%RUN_PERMUT_CON Run a permutation meta-analysis on the contrast estimates.
%   RUN_PERMUT_CON(DIR, CON_FILES) Run one-sample meta-analysis on 
%       CON_FILES, store the results in OUT_DIR.
%   RUN_PERMUT_CON(DIR, CON_FILES, CON_FILES2) Run two-sample meta-analysis 
%       on CON_FILES and CON_FILES2 store the results in OUT_DIR.

    if ~exist(fullfile(out_dir, 'lP+.img'), 'file')
        % Delete any halted analysis        
        if isdir(out_dir)
            rmdir(out_dir,'s')
        end
        mkdir(out_dir)
        
        if ~exist('con_files2', 'var')
            matlabbatch{1}.spm.tools.snpm.des.OneSampT.DesignName = 'MultiSub: One Sample T test on diffs/contrasts';
            matlabbatch{1}.spm.tools.snpm.des.OneSampT.DesignFile = 'snpm_bch_ui_OneSampT';
            matlabbatch{1}.spm.tools.snpm.des.OneSampT.dir = {out_dir};
            matlabbatch{1}.spm.tools.snpm.des.OneSampT.P = con_files;
            matlabbatch{1}.spm.tools.snpm.des.OneSampT.nPerm = nperms;
            matlabbatch{2}.spm.tools.snpm.cp.snpmcfg = {fullfile(out_dir, 'SnPMcfg.mat')};
        else
            matlabbatch{1}.spm.tools.snpm.des.TwoSampT.dir = {out_dir};
            matlabbatch{1}.spm.tools.snpm.des.TwoSampT.scans1 = con_files;
            matlabbatch{1}.spm.tools.snpm.des.TwoSampT.scans2 = con_files2;
            matlabbatch{1}.spm.tools.snpm.des.TwoSampT.nPerm = nperms;
            matlabbatch{2}.spm.tools.snpm.cp.snpmcfg = {fullfile(out_dir, 'SnPMcfg.mat')};
        end
        
        save('matlabbatch.mat', 'matlabbatch')
        spm_jobman('run', matlabbatch)
    else
        disp('Permutation on contrast files already computed')
    end
end

