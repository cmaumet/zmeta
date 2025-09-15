function run_permut_z(out_dir, nperms, z_files, z_files2)
%RUN_PERMUT_Z Run a permutation meta-analysis on the z statistic maps.
%   RUN_PERMUT_Z(DIR, Z_FILES, Z_FILES2) Run one-sample meta-analysis on 
%       Z_FILES, store the results in OUT_DIR.
%   RUN_PERMUT_Z(DIR, Z_FILES, Z_FILES2) Run two-sample meta-analysis 
%       on Z_FILES and Z_FILES2 store the results in OUT_DIR.
% 
    if ~exist(fullfile(out_dir, 'lP+.img'), 'file')
        % Delete any halted analysis        
        if isdir(out_dir)
            rmdir(out_dir,'s')
        end
        mkdir(out_dir)
        
        if ~exist('z_files2', 'var')
            matlabbatch{1}.spm.tools.snpm.des.OneSampT.DesignName = 'MultiSub: One Sample T test on diffs/contrasts';
            matlabbatch{1}.spm.tools.snpm.des.OneSampT.DesignFile = 'snpm_bch_ui_OneSampT';
            matlabbatch{1}.spm.tools.snpm.des.OneSampT.dir = {out_dir};
            matlabbatch{1}.spm.tools.snpm.des.OneSampT.P = z_files;
            matlabbatch{1}.spm.tools.snpm.des.OneSampT.nPerm = nperms;
            matlabbatch{2}.spm.tools.snpm.cp.snpmcfg = {fullfile(out_dir, 'SnPMcfg.mat')};
        else
            matlabbatch{1}.spm.tools.snpm.des.TwoSampT.dir = {out_dir};
            matlabbatch{1}.spm.tools.snpm.des.TwoSampT.scans1 = z_files;
            matlabbatch{1}.spm.tools.snpm.des.TwoSampT.scans2 = z_files2;
            matlabbatch{1}.spm.tools.snpm.des.TwoSampT.nPerm = nperms;
            matlabbatch{2}.spm.tools.snpm.cp.snpmcfg = {fullfile(out_dir, 'SnPMcfg.mat')};
        end
        
        save(fullfile(out_dir, 'matlabbatch.mat'), 'matlabbatch')
        spm_jobman('run', matlabbatch)
    else
        disp('Permutation on Z already computed')
    end
end

