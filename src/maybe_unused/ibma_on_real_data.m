function ibma_on_real_data(analysisDir, recomputeZ)
    if nargin < 2
        recomputeZ = false;
        if nargin < 1
            analysisDir = pwd;
        end
    end

    realDataDir = fullfile(analysisDir, 'real_data');
    nSubjects = [25 25 20 20 9 9 9 12 12 12 12 13 32 24 14 14 12 12 16 16 16];
    nStudies = numel(nSubjects);
    
    con4dFileName = 'conweighted_filtered_func_data.nii';
    varCon4dFileName = 'conweighted_var_filtered_func_data.nii';
    z4dFileName = 'conweighted_z_func_data.nii';
    
    if recomputeZ
        con4dFile = spm_select('FPList', analysisDir, con4dFileName);
        varCon4dFile = spm_select('FPList', analysisDir, varCon4dFileName);

        % Create z-stat
        conData = spm_read_vols(spm_vol(con4dFile));
        varConData = spm_read_vols(spm_vol(varCon4dFile));

        %Safer with a loop
        for v = 1:nStudies
            currCon = conData(:,:,:,v);
            currConVar = varConData(:,:,:,v);

            clear currZ;
            currZ = norminv(cdf('T', currCon./sqrt(currConVar), nSubjects(v)-1));
            infPos = find(isinf(currZ(:)));          
            currZ(infPos) = -norminv(cdf('T', -currCon(infPos)./sqrt(currConVar(infPos)), nSubjects(v)-1));

            zData(:,:,:,v) = currZ;
        end

        zFile = fullfile(analysisDir, z4dFileName);
        copy_nii_image(con4dFile, zFile);
        zNifti = nifti(zFile);
        zNifti.dat(:) = NaN;
        zNifti.dat(:,:,:,:) = zData;
    end
    
    zFiles = cellstr(spm_select('ExtFPList', analysisDir, ['^' string_to_regexp(z4dFileName)], 1:100));
    conFiles = cellstr(spm_select('ExtFPList', analysisDir, ['^' string_to_regexp(con4dFileName)], 1:100));
    varConFiles = cellstr(spm_select('ExtFPList', analysisDir, ['^' string_to_regexp(varCon4dFileName)], 1:100));
    
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