function ibma_on_real_data()
    realDataDir = fullfile(pwd, 'real_data');
    nSubjects = [25 25 20 20 9 9 9 12 12 12 12 13 32 24 14 14 12 12 16 16 16];
    
    zFiles = cellstr(spm_select('ExtFPList', pwd, 'conweighted_z_func_data.nii', 1:100));
    conFiles = cellstr(spm_select('ExtFPList', pwd, 'conweighted_filtered_func_data.nii', 1:100));
    varConFiles = cellstr(spm_select('ExtFPList', pwd, 'conweighted_var_filtered_func_data.nii', 1:100));

    % --- Compute meta-analysis ---
    matlabbatch = {};
    % Fisher's
    fisherDir = fullfile(realDataDir, 'fishers');
    mkdir(fisherDir);
    matlabbatch{1}.spm.tools.ibma.fishers.dir = {fisherDir};
    matlabbatch{1}.spm.tools.ibma.fishers.zimages = zFiles;

    % Stouffer's
    stoufferDir = fullfile(realDataDir, 'stouffers');
    mkdir(stoufferDir);
    matlabbatch{end+1}.spm.tools.ibma.stouffers.dir = {stoufferDir};
    matlabbatch{end}.spm.tools.ibma.stouffers.zimages = zFiles;
    matlabbatch{end}.spm.tools.ibma.stouffers.rfx.RFX_no = 1;

    % Stouffer's MFX
    stoufferMFXDir = fullfile(realDataDir, 'stouffersMFX');
    mkdir(stoufferMFXDir);
    matlabbatch{end+1}.spm.tools.ibma.stouffers.dir = {stoufferMFXDir};
    matlabbatch{end}.spm.tools.ibma.stouffers.zimages = zFiles;
    matlabbatch{end}.spm.tools.ibma.stouffers.rfx.RFX_yes = 0;

    % Optimally weighted z
    weightedZDir = fullfile(realDataDir, 'weightedZ');
    mkdir(weightedZDir);
    matlabbatch{end+1}.spm.tools.ibma.weightedz.dir = {weightedZDir};
    matlabbatch{end}.spm.tools.ibma.weightedz.zimages = zFiles;
    matlabbatch{end}.spm.tools.ibma.weightedz.nsubjects = nSubjects;

    % Mega-analysis RFX
    megaRfxDir = fullfile(realDataDir, 'megaRFX');
    mkdir(megaRfxDir);
    matlabbatch{end+1}.spm.tools.ibma.megarfx.dir = {megaRfxDir};
    matlabbatch{end}.spm.tools.ibma.megarfx.confiles = conFiles;
    matlabbatch{end}.spm.tools.ibma.megarfx.nsubjects = nSubjects;

    % Mega-analysis FFX
    megaFfxDir = fullfile(realDataDir, 'megaFFX');
    mkdir(megaFfxDir);
    matlabbatch{end+1}.spm.tools.ibma.megaffx.dir = {megaFfxDir};
    matlabbatch{end}.spm.tools.ibma.megaffx.nsubjects = nSubjects;
    matlabbatch{end}.spm.tools.ibma.megaffx.confiles = conFiles;
    matlabbatch{end}.spm.tools.ibma.megaffx.varconfiles = varConFiles;

    % Permutation on conFiles
    matlabbatch{end+1}.spm.tools.snpm.des.OneSampT.DesignName = 'MultiSub: One Sample T test on diffs/contrasts';
    matlabbatch{end}.spm.tools.snpm.des.OneSampT.DesignFile = 'snpm_bch_ui_OneSampT';
    permutConDir = fullfile(realDataDir, 'permutCon');
    mkdir(permutConDir);
    matlabbatch{end}.spm.tools.snpm.des.OneSampT.dir = {permutConDir};
    matlabbatch{end}.spm.tools.snpm.des.OneSampT.P = conFiles;
    matlabbatch{end+1}.spm.tools.snpm.cp.snpmcfg = {fullfile(permutConDir, 'SnPMcfg.mat')};

    % Permutation on zFiles
    matlabbatch{end+1}.spm.tools.snpm.des.OneSampT.DesignName = 'MultiSub: One Sample T test on diffs/contrasts';
    matlabbatch{end}.spm.tools.snpm.des.OneSampT.DesignFile = 'snpm_bch_ui_OneSampT';
    permutZDir = fullfile(realDataDir, 'permutZ');
    mkdir(permutZDir);
    matlabbatch{end}.spm.tools.snpm.des.OneSampT.dir = {permutZDir};
    matlabbatch{end}.spm.tools.snpm.des.OneSampT.P = zFiles;
    matlabbatch{end+1}.spm.tools.snpm.cp.snpmcfg = {fullfile(permutZDir, 'SnPMcfg.mat')};

    spm_jobman('run', matlabbatch)

end