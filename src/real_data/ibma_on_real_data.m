function matlabbatch=ibma_on_real_data(recomputeZ)
    if nargin < 1
        recomputeZ = true;
    end

    filedir = fileparts(which('ibma_on_real_data.m'));
    rootdir = fileparts(fileparts(filedir));

    realDataDir = fullfile(rootdir, 'data', 'real_data');
    resRealDataDir = fullfile(rootdir, 'results', 'real_data');

    if ! isfolder(realDataDir)
        mkdir(realDataDir)
    end
    if ! isfolder(resRealDataDir)
        mkdir(resRealDataDir)
    end

    nSubjects = [25 25 20 20 9 9 9 12 12 12 12 13 32 24 14 14 12 12 16 16 16];
    % spm_studies = [repmat(true, 1, 10) repmat(false, 1, 11)];

    sum_weights = [1 1 1 1 1 1 1 2 2 2 2 1 2 4 4 4 2 2 1 2 1];
    soft_weights =  [repmat(2, 1, 10) repmat(100, 1, 11)];
    fact = sum_weights.*soft_weights;

    % [('pain_01', 1), ('pain_02', 1), ('pain_03', 1), ('pain_04', 1),
    %                ('pain_05', 1), ('pain_06', 1), ('pain_07', 1), ('pain_08', 2),
    %                ('pain_09', 2), ('pain_10', 2), ('pain_11', 2), ('pain_12', 1),
    %                ('pain_13', 2), ('pain_14', 4), ('pain_15', 4), ('pain_16', 4),
    %                ('pain_17', 2), ('pain_18', 2), ('pain_19', 1), ('pain_20', 2),
    %                ('pain_21', 1)]

    nStudies = numel(nSubjects);

    if length(dir(realDataDir))==2
        error('Empty folder, NIDM zips should be downloaded first (see README)');
    end
    
    conFiles = cell(nStudies,1);
    stdConFiles = cell(nStudies,1);
    % Select contrast and standard error maps within NIDM packs
    for k = 1:nStudies
        studyDirs{k,1} = fullfile(realDataDir, ...
            strcat('pain_', num2str(k, '%02d'), '.nidm'));
        conFiles{k,1} = spm_select('FPList', studyDirs{k}, 'Contrast.nii');
        stdConFiles{k,1} = spm_select('FPList', studyDirs{k}, 'ContrastStandardError.nii');
        if isempty(conFiles{k,1})
            conFiles{k,1} = spm_select('FPList', studyDirs{k}, 'Contrast_T001.nii');
            stdConFiles{k,1} = spm_select('FPList', studyDirs{k}, 'ContrastStandardError_T001.nii');
        end
    end

    % Intensity normalization of the contrast and sterr maps (soft + conweights)
    varConFiles_norm = cell(nStudies,1);
    conFiles_norm = cell(nStudies,1);
    for k = 1:nStudies
        study = strcat('pain_', num2str(k, '%02d'));

        % Normalise contrast maps
        con_map_norm = strcat('con_', study, '_norm.nii');
        clear matlabbatch
        matlabbatch{1}.spm.util.imcalc.input = cellstr(conFiles{k});
        matlabbatch{1}.spm.util.imcalc.output = con_map_norm;
        matlabbatch{1}.spm.util.imcalc.outdir = {resRealDataDir};
        matlabbatch{1}.spm.util.imcalc.expression = ['i1/' num2str(fact(k))];
        matlabbatch{1}.spm.util.imcalc.options.dtype = 64;
        spm_jobman('run', matlabbatch);

        conFiles_norm{k,1} = fullfile(resRealDataDir, con_map_norm);

        % Compute contrast variance from standard error + normalise
        varcon_map_norm = strcat('varcon_', study, '_norm.nii');
        clear matlabbatch
        matlabbatch{1}.spm.util.imcalc.input = cellstr(stdConFiles{k});
        matlabbatch{1}.spm.util.imcalc.output = varcon_map_norm;
        matlabbatch{1}.spm.util.imcalc.outdir = {resRealDataDir};
        matlabbatch{1}.spm.util.imcalc.expression = ['(i1/' num2str(fact(k)) ').^2'];
        matlabbatch{1}.spm.util.imcalc.options.dtype = 64;
        spm_jobman('run', matlabbatch);

        varConFiles_norm{k,1} = fullfile(resRealDataDir, varcon_map_norm);
    end
    
    % Convert contrast images to a single 4D nii
    con4dFileName = 'con_allstudies_norm.nii';
    clear matlabbatch
    matlabbatch{1}.spm.util.cat.vols = conFiles_norm;
    matlabbatch{1}.spm.util.cat.name = fullfile(resRealDataDir, con4dFileName);
    matlabbatch{1}.spm.util.cat.dtype = 0; % keep same type as input
    spm_jobman('run', matlabbatch)

    % Remove Nan's (for FSL)
    con4dFile = spm_select('FPList', resRealDataDir, ['^' con4dFileName]);
    con4dImg = nifti(con4dFile);
    con4dImg.dat(find(isnan(con4dImg.dat(:))))=0;

    % Convert contrast variance images to a single 4D nii
    varCon4dFileName =  'varcon_allstudies_norm.nii';
    clear matlabbatch
    matlabbatch{1}.spm.util.cat.vols = varConFiles_norm;
    matlabbatch{1}.spm.util.cat.name = fullfile(resRealDataDir, varCon4dFileName);
    matlabbatch{1}.spm.util.cat.dtype = 0; % keep same type as input
    spm_jobman('run', matlabbatch)

    % Remove Nan's (for FSL)
    varCon4dFile = spm_select('FPList', resRealDataDir, ['^' varCon4dFileName]);
    varCon4dImg = nifti(varCon4dFile);
    varCon4dImg.dat(find(isnan(varCon4dImg.dat(:))))=0;

    z4dFileName = 'z_allstudies.nii';
    
    if recomputeZ

        % Create z-stat
        disp(con4dFile)
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

        zFile = fullfile(resRealDataDir, z4dFileName);
        copyfile(con4dFile, zFile);
        zNifti = nifti(zFile);
        zNifti.dat(:) = NaN;
        zNifti.dat(:,:,:,:) = zData;
    end
    
    zFiles = cellstr(spm_select('ExtFPList', resRealDataDir, z4dFileName, 1:100));

    
    
    copyfile(varCon4dFile, maskFile);
    maskImg = nifti(maskFile);
    maskImg.dat(:,:,:) = all(spm_read_vols(spm_vol(varCon4dFile)),4);

    % Compute mask
    maskFileName = 'mask.nii';
    clear matlabbatch
    matlabbatch{1}.spm.util.imcalc.input = cellstr(varConFiles_norm{k});
    matlabbatch{1}.spm.util.imcalc.output = maskFileName;
    matlabbatch{1}.spm.util.imcalc.outdir = {resRealDataDir};
    matlabbatch{1}.spm.util.imcalc.expression = ['all(i1, 4)'];
    matlabbatch{1}.spm.util.imcalc.options.dtype = 4; % signed short
    spm_jobman('run', matlabbatch);
    maskFile = fullfile(resRealDataDir, maskFileName);

    % --- Compute meta-analysis ---
    % GLM MFX (FLAME 1)
    megaMFXDir = fullfile(resRealDataDir, 'megaMFX');
    fsl_design_dir = fullfile(rootdir, 'src', 'real_data', 'fsl_design');
    mkdir(megaMFXDir);
    if ~exist(fullfile(megaMFXDir, 'stats', 'zstat1.nii.gz'), 'file')

        copyfile(con4dFile, fullfile(megaMFXDir, 'copes.nii'));
        copyfile(varCon4dFile, fullfile(megaMFXDir, 'varcopes.nii'));

        cwd = pwd;
        cd(megaMFXDir)
        
        design = 'design_ones_21st';   
        cmd = ['flameo --cope=' fullfile(megaMFXDir, 'copes.nii') ...
                ' --vc=' fullfile(megaMFXDir, 'varcopes.nii') ...
                ' --ld=stats --mask=' maskFile ...
                ' --dm=' fullfile(fsl_design_dir, [design '.mat']) ...
                ' --cs=' fullfile(fsl_design_dir, [design '.grp']) ...
                ' --tc=' fullfile(fsl_design_dir, [design '.con']) ...
                ' --runmode=flame1'];
        disp(cmd)
        save('cmd.mat', 'cmd')
        system(cmd);
        
        cd(cwd) 
    else
        disp('Mega MFX already computed')
    end

    % GLM FFX (via FSL)
    megaFFXDir = fullfile(resRealDataDir, 'megaFFX');
    mkdir(megaFFXDir)
    if ~exist(fullfile(megaFFXDir, 'stats', 'zstat1.nii.gz'), 'file')
        copyfile(fullfile(megaMFXDir, 'copes.nii'), megaFFXDir)
        copyfile(fullfile(megaMFXDir, 'varcopes.nii'), megaFFXDir)

        cwd = pwd;
        cd(megaFFXDir)

        design = 'design_ones_21st';   
        cmd = ['flameo --cope=' fullfile(megaFFXDir, 'copes.nii') ...
                ' --vc=' fullfile(megaFFXDir, 'varcopes.nii') ...
                ' --ld=stats --mask=' fullfile(path_to, 'mask.nii')...
                ' --dm=' fullfile(fsl_design_dir, [design '.mat']) ...
                ' --cs=' fullfile(fsl_design_dir, [design '.grp']) ...
                ' --tc=' fullfile(fsl_design_dir, [design '.con']) ...
                ' --runmode=fe'];
        disp(cmd)
        save('cmd.mat', 'cmd')
        system(cmd);
        
        cd(cwd) 
    else
        disp('Mega MFX already computed')
    end

    matlabbatch = {};

    % Fisher's
    fisherDir = fullfile(resRealDataDir, 'fishers');
    mkdir(fisherDir);
    matlabbatch{1}.spm.tools.ibma.fishers.dir = {fisherDir};
    matlabbatch{1}.spm.tools.ibma.fishers.zimages = zFiles;

    % Stouffer's
    stoufferDir = fullfile(resRealDataDir, 'stouffers');
    mkdir(stoufferDir);
    matlabbatch{end+1}.spm.tools.ibma.stouffers.dir = {stoufferDir};
    matlabbatch{end}.spm.tools.ibma.stouffers.zimages = zFiles;
    matlabbatch{end}.spm.tools.ibma.stouffers.rfx.RFX_no = 1;

    % Stouffer's MFX
    stoufferMFXDir = fullfile(resRealDataDir, 'stouffersMFX');
    mkdir(stoufferMFXDir);
    matlabbatch{end+1}.spm.tools.ibma.stouffers.dir = {stoufferMFXDir};
    matlabbatch{end}.spm.tools.ibma.stouffers.zimages = zFiles;
    matlabbatch{end}.spm.tools.ibma.stouffers.rfx.RFX_yes = 0;

    % Optimally weighted z
    weightedZDir = fullfile(resRealDataDir, 'weightedZ');
    mkdir(weightedZDir);
    matlabbatch{end+1}.spm.tools.ibma.weightedz.dir = {weightedZDir};
    matlabbatch{end}.spm.tools.ibma.weightedz.zimages = zFiles;
    matlabbatch{end}.spm.tools.ibma.weightedz.nsubjects = nSubjects;

    % Mega-analysis RFX
    megaRfxDir = fullfile(resRealDataDir, 'megaRFX');
    mkdir(megaRfxDir);
    matlabbatch{end+1}.spm.tools.ibma.megarfx.dir = {megaRfxDir};
    matlabbatch{end}.spm.tools.ibma.megarfx.model.one.confiles = conFiles;

    % Permutation on conFiles
    matlabbatch{end+1}.spm.tools.snpm.des.OneSampT.DesignName = 'MultiSub: One Sample T test on diffs/contrasts';
    matlabbatch{end}.spm.tools.snpm.des.OneSampT.DesignFile = 'snpm_bch_ui_OneSampT';
    permutConDir = fullfile(resRealDataDir, 'permutCon');
    mkdir(permutConDir);
    matlabbatch{end}.spm.tools.snpm.des.OneSampT.dir = {permutConDir};
    matlabbatch{end}.spm.tools.snpm.des.OneSampT.P = conFiles;
    matlabbatch{end+1}.spm.tools.snpm.cp.snpmcfg = {fullfile(permutConDir, 'SnPMcfg.mat')};

    % Permutation on zFiles
    matlabbatch{end+1}.spm.tools.snpm.des.OneSampT.DesignName = 'MultiSub: One Sample T test on diffs/contrasts';
    matlabbatch{end}.spm.tools.snpm.des.OneSampT.DesignFile = 'snpm_bch_ui_OneSampT';
    permutZDir = fullfile(resRealDataDir, 'permutZ');
    mkdir(permutZDir);
    matlabbatch{end}.spm.tools.snpm.des.OneSampT.dir = {permutZDir};
    matlabbatch{end}.spm.tools.snpm.des.OneSampT.P = zFiles;
    matlabbatch{end+1}.spm.tools.snpm.cp.snpmcfg = {fullfile(permutZDir, 'SnPMcfg.mat')};

    spm_jobman('run', matlabbatch)

end
