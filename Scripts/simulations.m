function simulations(baseDir)
% SIMULATIONS    Perform simulations based on IBMA toolbox. 
%
%   simulations(baseDir)

% Copyright (C) 2014 The University of Warwick
% Id: ibma_test_stouffers.m  IBMA toolbox
% Camille Maumet

    % Number of subject per study
%     nSubjects = [25 400 100 25]; %[10, 15, 20, 25, 30, 10, 15, 20, 25, 30, 10, 15, 20, 25, 30];
%     nStudies = numel(nSubjects);
    nStudiesArray = [5, 25, 50];
    sigmaSquareArray = [1/2, 1, 2, 4, 10];%How to compute z with var = 0?
    
    % Between-studies variance (RFX?)
    sigmaBetweenStudiesArray = [1/2, 1, 2, 4, 10]/20;
    
    % Size of the simulation image (in 1 direction). Each voxel of the
    % simulation image is a simulation sample.
    nSimuOneDir = 100;
    nSimu = nSimuOneDir^3;
    
    if nargin == 0
        baseDir = pwd;
    end
    
    simuinfo.config.nSimuOneDir = nSimuOneDir;
    simuinfo.config.nSimu = nSimu;
    simuinfo.config.nStudies = nStudiesArray;
    simuinfo.config.sigmaSquare = sigmaSquareArray;
    simuinfo.config.sigmaBetweenStudies = sigmaBetweenStudiesArray;
    simuinfo.config.nSimuOneDir = nSimuOneDir;
    simuinfo.config.timing = tic;
    
    baseSimulationDir = fullfile(baseDir, 'simulations');
    save(fullfile(baseSimulationDir, 'simuinfo.mat'), 'simuinfo');
    
    % Number of studies in meta-analysis
    for iStudies = 1%:numel(nStudiesArray)
        nStudies = nStudiesArray(iStudies);
        nSubjects = get_n_subjects_per_studies(nStudies);
        
        % Between-studies variance (RFX?)
        for iEffects = numel(sigmaBetweenStudiesArray):-1:1
            sigmaBetweenStudies = sigmaBetweenStudiesArray(iEffects);

            for iSigmaSquare = numel(sigmaSquareArray)%:-1:1
                tic;
                % Common level of (intra-studies) variance (ignoring effect of sample 
                % size).
                sigmaSquare = sigmaSquareArray(iSigmaSquare);

%                 % Study-specific variance (i.e. common study-variance divided by sample
%                 % size).
%                 sigmaSquareStudies = sigmaSquare./nSubjects + sigmaBetweenStudies;



                % Directory to store the simulation data and results.
                currSimuDirName = ['nStudy' num2str(nStudies) '_Betw' num2str(sigmaBetweenStudies) ...
                    '_Within' num2str(sigmaSquare) '_nSimu' num2str(nSimu)];
                simulationDir = fullfile(baseSimulationDir, currSimuDirName);
                mkdir(simulationDir);

                % Directory to store the simulation data.
                dataDir = fullfile(simulationDir, 'data');
                mkdir(dataDir);

                % --- Simulated data ---
                subIdx = 0;
                
                % For each study involved in the current meta-analysis
                for iStudy = 1:nStudies

                    % Degrees of freedom of the within-study variance estimate
                    dof = nSubjects(iStudy)-1;
                    
%                     estimatedSubContrast = NaN.*zeros([nSimuOneDir, nSimuOneDir, nSimuOneDir nSubjects(iStudy)]);
%                     for iSubject = 1:nSubjects(iStudy)
%                         estimatedSubContrast(:,:,:,iSubject) = normrnd(0, sqrt(sigmaSquare), [nSimuOneDir, nSimuOneDir, nSimuOneDir]);
%                     end
                    
%                     % Store for later use to compute FFX variance
%                     estimatedSubAll(:,:,:,subIdx+[1:nSubjects(iStudy)]) = estimatedSubContrast;
%                     subIdx = subIdx + nSubjects(iStudy);
                    
                    % Estimated paramater estimate.
                    estimatedContrast = normrnd(0, sqrt(sigmaSquare./nSubjects(iStudy)+sigmaBetweenStudies), [nSimuOneDir, nSimuOneDir, nSimuOneDir]);
%                     estimatedContrast = mean(estimatedSubContrast, 4);%

                    % Estimated variance (from chi square distribution)
%                     estimatedSigmaSquare = var(estimatedSubContrast, 0, 4);
                    estimatedSigmaSquare = chi2rnd(dof, [nSimuOneDir, nSimuOneDir, nSimuOneDir])*sigmaSquare/dof;
                    estimatedSigmaSquare = estimatedSigmaSquare./nSubjects(iStudy);

                    % Write out parameter estimates.      
                    conFiles{iStudy} = fullfile(dataDir, ['con_st' num2str(iStudy) '.nii']);
                    vol    = struct('fname',  conFiles{iStudy},...
                               'dim',    [nSimuOneDir nSimuOneDir nSimuOneDir],...
                               'dt',     [spm_type('float32') spm_platform('bigend')],...
                               'mat',    eye(4),...
                               'pinfo',  [1 0 0]',...
                               'descrip','simulation');
                    vol    = spm_create_vol(vol);
                    spm_write_vol(vol, estimatedContrast);

                    % Write out estimated variance of parameter estimates.
                    varConFiles{iStudy} = fullfile(dataDir, ['varcon_st' num2str(iStudy) '.nii']);
                    vol.fname =  varConFiles{iStudy};
                    spm_write_vol(vol, estimatedSigmaSquare);

                    % Write out corresponding z-values.
                    zFiles{iStudy} = fullfile(dataDir, ['z_st' num2str(iStudy) '.nii']);
                    vol.fname = zFiles{iStudy};
                    
                    % Z-transform of T-statistic
                    zData = norminv(cdf('T', estimatedContrast./sqrt(estimatedSigmaSquare), nSubjects(iStudy)-1));
                    infPos = find(isinf(zData(:)));
                    
                    zData(infPos) = -norminv(cdf('T', -estimatedContrast(infPos)./sqrt(estimatedSigmaSquare(infPos)), nSubjects(iStudy)-1));
                    spm_write_vol(vol, zData);
                end
                
%                 % Cross-subject cross-studies variance estimation (needed
%                 % for FFX)
%                 vol.fname =  fullfile(dataDir, ['var_ffx.nii']);
%                 estimatedSigmaSquare = var(estimatedSubAll, 0, 4)./sum(nSubjects);
%                 spm_write_vol(vol, estimatedSigmaSquare);
                
                % --- Compute meta-analysis ---
                matlabbatch = {};
                % Fisher's
                fisherDir = fullfile(simulationDir, 'fishers');
                mkdir(fisherDir);
                matlabbatch{1}.spm.tools.ibma.fishers.dir = {fisherDir};
                matlabbatch{1}.spm.tools.ibma.fishers.zimages = zFiles;
                          
                
                % Stouffer's
                stoufferDir = fullfile(simulationDir, 'stouffers');
                mkdir(stoufferDir);
                matlabbatch{end+1}.spm.tools.ibma.stouffers.dir = {stoufferDir};
                matlabbatch{end}.spm.tools.ibma.stouffers.zimages = zFiles;
                matlabbatch{end}.spm.tools.ibma.stouffers.rfx.RFX_no = 1;
                
                % Stouffer's MFX
                stoufferMFXDir = fullfile(simulationDir, 'stouffersMFX');
                mkdir(stoufferMFXDir);
                matlabbatch{end+1}.spm.tools.ibma.stouffers.dir = {stoufferMFXDir};
                matlabbatch{end}.spm.tools.ibma.stouffers.zimages = zFiles;
                matlabbatch{end}.spm.tools.ibma.stouffers.rfx.RFX_yes = 0;

                % Optimally weighted z
                weightedZDir = fullfile(simulationDir, 'weightedZ');
                mkdir(weightedZDir);
                matlabbatch{end+1}.spm.tools.ibma.weightedz.dir = {weightedZDir};
                matlabbatch{end}.spm.tools.ibma.weightedz.zimages = zFiles;
                matlabbatch{end}.spm.tools.ibma.weightedz.nsubjects = nSubjects;

                % Mega-analysis RFX
                megaRfxDir = fullfile(simulationDir, 'megaRFX');
                mkdir(megaRfxDir);
                matlabbatch{end+1}.spm.tools.ibma.megarfx.dir = {megaRfxDir};
                matlabbatch{end}.spm.tools.ibma.megarfx.confiles = conFiles;
                matlabbatch{end}.spm.tools.ibma.megarfx.nsubjects = nSubjects;

                % Mega-analysis FFX
                megaFfxDir = fullfile(simulationDir, 'megaFFX');
                mkdir(megaFfxDir);
                matlabbatch{end+1}.spm.tools.ibma.megaffx.dir = {megaFfxDir};
                matlabbatch{end}.spm.tools.ibma.megaffx.nsubjects = nSubjects;
                matlabbatch{end}.spm.tools.ibma.megaffx.confiles = conFiles;
                matlabbatch{end}.spm.tools.ibma.megaffx.varconfiles = varConFiles;

                % Permutation on conFiles
                matlabbatch{end+1}.spm.tools.snpm.des.OneSampT.DesignName = 'MultiSub: One Sample T test on diffs/contrasts';
                matlabbatch{end}.spm.tools.snpm.des.OneSampT.DesignFile = 'snpm_bch_ui_OneSampT';
                permutConDir = fullfile(simulationDir, 'permutCon');
                mkdir(permutConDir);
                matlabbatch{end}.spm.tools.snpm.des.OneSampT.dir = {permutConDir};
                matlabbatch{end}.spm.tools.snpm.des.OneSampT.P = conFiles;
                matlabbatch{end+1}.spm.tools.snpm.cp.snpmcfg = {fullfile(permutConDir, 'SnPMcfg.mat')};
                
                % Permutation on zFiles
                matlabbatch{end+1}.spm.tools.snpm.des.OneSampT.DesignName = 'MultiSub: One Sample T test on diffs/contrasts';
                matlabbatch{end}.spm.tools.snpm.des.OneSampT.DesignFile = 'snpm_bch_ui_OneSampT';
                permutZDir = fullfile(simulationDir, 'permutZ');
                mkdir(permutZDir);
                matlabbatch{end}.spm.tools.snpm.des.OneSampT.dir = {permutZDir};
                matlabbatch{end}.spm.tools.snpm.des.OneSampT.P = zFiles;
                matlabbatch{end+1}.spm.tools.snpm.cp.snpmcfg = {fullfile(permutZDir, 'SnPMcfg.mat')};
            
                spm_jobman('run', matlabbatch)
                
                probaFishers = spm_read_vols(spm_vol(spm_select('FPList', fisherDir, '.*_minus_log10_p\.nii$')));   
                simu.fishers = get_proba_CI(probaFishers(:), nSimuOneDir);
                
                probaStouffers = spm_read_vols(spm_vol(spm_select('FPList', stoufferDir, '.*_minus_log10_p\.nii$')));   
                simu.stouffers = get_proba_CI(probaStouffers(:), nSimuOneDir);

                probaStouffersMFX = spm_read_vols(spm_vol(spm_select('FPList', stoufferMFXDir, '.*_minus_log10_p\.nii$')));   
                simu.stouffersMFX = get_proba_CI(probaStouffersMFX(:), nSimuOneDir);
                
                probaWeighted = spm_read_vols(spm_vol(spm_select('FPList', weightedZDir, '.*_minus_log10_p\.nii$')));
                simu.weightedZ = get_proba_CI(probaWeighted(:), nSimuOneDir);

                probaMegaFFX = spm_read_vols(spm_vol(spm_select('FPList', megaFfxDir, '.*_minus_log10_p\.nii$')));
                simu.megaFfx = get_proba_CI(probaMegaFFX(:), nSimuOneDir);

                probaMegaRFX = spm_read_vols(spm_vol(spm_select('FPList', megaRfxDir, '.*_minus_log10_p\.nii$')));
                simu.megaRfx = get_proba_CI(probaMegaRFX(:), nSimuOneDir);

                probaPermutCon = spm_read_vols(spm_vol(spm_select('FPList', permutConDir, '.*lP\+\.img$')));
                simu.permutCon = get_proba_CI(probaPermutCon(:), nSimuOneDir);
                
                probaPermutZ = spm_read_vols(spm_vol(spm_select('FPList', permutZDir, '.*lP\+\.img$')));
                simu.permutZ = get_proba_CI(probaPermutZ(:), nSimuOneDir);
                
                simu.config.nSubjects = nSubjects;
                simu.config.nStudies = nStudies;
                simu.config.sigmaSquare = sigmaSquare;
                simu.config.sigmaBetweenStudies = sigmaBetweenStudies;
                simu.config.nSimuOneDir = nSimuOneDir;
                simu.config.timing = toc;
                
                simu.config.timing

                save(fullfile(simulationDir, 'simu.mat'), 'simu')
            end
        end
    end
end

% Compute confidance intervals
function res = get_proba_CI(values, nSimuOneDir)
    if ~all(size(values) == nSimuOneDir)
        values = reshape(values, [nSimuOneDir, nSimuOneDir, nSimuOneDir]);
    end
    
    repeats = sum(sum(values > -log10(0.05), 3), 2)./(nSimuOneDir^2);

    m = mean(repeats);
    s = std(repeats);
    confidenceInterval = [m - 1.96*s; m + 1.96*s];
    
    res.stderror = s;
    res.mean = m;
    res.repeats = repeats;
    res.values = values;
    res.CI = confidenceInterval;
    res.string = ['CI = [' num2str(confidenceInterval(1)), ' ; ' num2str(confidenceInterval(2)) ']' ...
                ' - avg=' num2str(m) ', std_est=' num2str(s)];
end

% Get number of subject per studies (50% between 20 and 25, 25% between 10
% and 20 and 25% between 25 and 35)
function nSubjects = get_n_subjects_per_studies(nStudies)
    nSubjects = [20 25 10 50];
    nPreDefined = 4;
    
    if nStudies < nPreDefined
        nSubjects = nSubjects(1:nStudies);
    elseif nStudies > nPreDefined
        rng(3, 'twister')

        quarter = round((nStudies-nPreDefined)/4);
        half = nStudies - nPreDefined - 2*quarter;
        
        minSmallStudies = 11;
        maxSmallStudies = 20;
        rangeSmallStudies = maxSmallStudies-minSmallStudies+1;
        nSubjectsSmallStudies = randi(rangeSmallStudies,1,quarter) + ...
                                    minSmallStudies -1;
        
        minBigStudies = 26;
        maxBigStudies = 50;
        rangeBigStudies = maxBigStudies-minBigStudies+1;
        nSubjectsBigStudies = randi(rangeBigStudies,1,quarter) +...
                                    minBigStudies -1;
                                
        minMediumStudies = 21;
        maxMediumStudies = 25;
        rangeMediumStudies = maxMediumStudies-minMediumStudies+1;
        nSubjectsMediumStudies = randi(rangeMediumStudies,1,half) +...
                                    minMediumStudies -1;
        
        nSubjects = [ nSubjects ,...
                      nSubjectsMediumStudies, ...
                      nSubjectsSmallStudies, ...
                      nSubjectsBigStudies];
    end
    
end