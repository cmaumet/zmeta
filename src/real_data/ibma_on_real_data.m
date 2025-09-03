function matlabbatch=ibma_on_real_data(recomputeZ)
    if nargin < 1
        recomputeZ = false;
    end

    filedir = fileparts(which('ibma_on_real_data.m'));
    analysisDir = fullfile(filedir, '..', '..', 'data');

    realDataDir = fullfile(analysisDir, 'real_data');

    if ! isfolder(realDataDir)
        mkdir(realDataDir)
    end

    nStudies = 2;
    nSubjects = [25 25 20 20 9 9 9 12 12 12 12 13 32 24 14 14 12 12 16 16 16];

    if length(dir(realDataDir))==2
        error('Empty folder, NIDM zips should be downloaded first (see README)');
    end

    
    conFiles = cellstr(nStudies);
    stdConFiles = cellstr(nStudies);
    varConFiles = cellstr(nStudies);
    % studyDirs = cell{nStudies, 1};
    for k = 1:nStudies
        studyDirs{k} = fullfile(realDataDir, ...
            strcat('pain_', num2str(k, '%02d'), '.nidm'));
        conFiles{k} = spm_select('FPList', studyDirs{k}, 'Contrast.nii');
        stdConFiles{k} = spm_select('FPList', studyDirs{k}, 'ContrastStandardError.nii');
        if isempty(conFiles{k})
            conFiles{k} = spm_select('FPList', studyDirs{k}, 'Contrast_T001.nii');
            stdConFiles{k} = spm_select('FPList', studyDirs{k}, 'ContrastStandardError_T001.nii');
        end
    end

    % Compute contrast variance from standard error
    matlabbatch = {};
    for k = 1:nStudies
        disp(stdConFiles{k})
        matlabbatch{1}.spm.util.imcalc.input = cellstr(stdConFiles{k});
        matlabbatch{1}.spm.util.imcalc.output = 'ContrastVariance.nii';
        matlabbatch{1}.spm.util.imcalc.outdir = studyDirs(k);
        matlabbatch{1}.spm.util.imcalc.expression = 'i1.^2';
        spm_jobman('run', matlabbatch);

        varConFiles{k} = fullfile(studyDirs{k}, 'ContrastVariance.nii');
    end

    
    % return;

    % con4dFileName = 'conweighted_filtered_func_data.nii';
    % varCon4dFileName =  'conweighted_var_filtered_func_data.nii';
    z4dFileName = 'z_file.nii';
    
    if recomputeZ
        con4dFile = conFiles; %spm_select('FPList', analysisDir, con4dFileName);
        varCon4dFile = varConFiles; %spm_select('FPList', analysisDir, varCon4dFileName);

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
    
    zFiles = cellstr(spm_select('ExtFPList', analysisDir, z4dFileName, 1:100));
    disp(zFiles)
    
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
