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
    nStudiesArray = [5 10 25 50];
    AVG_NUM_SUB = 20;
    NUM_SUB_DIFF = 15;
    sigmaSquareArray = [0.25, 0.5, 1, 2, 4]*AVG_NUM_SUB;%How to compute z with var = 0?
    studyVarianceSchemes = {'identical'} %, 'different'}; don't know yet how to deal with uneq var (for FFX!?)
    
    % Between-studies variance (RFX?)
    sigmaBetweenStudiesArray = [0 1];
    
    % Number of subjects per studies     
    subjectPerStudiesScheme = {'identical', 'different'};
    
    % Number of studies with software 2 (fraction)
    nStudiesWithSoftware2 = [0 0.5 4/5];
    
    % Correction factor with software 2
    sigmaFactorWithSoftware2 = [1 2 100];
    
    % Study-specific bias due to units mismatch
    unitMismatch = [false, true];
    
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
    simuinfo.config.average_number_subjects = AVG_NUM_SUB;
    simuinfo.config.average_diff_num_subjects = NUM_SUB_DIFF;
    simuinfo.config.nStudiesWithSoftware2 = nStudiesWithSoftware2;
    simuinfo.config.sigmaFactorWithSoftware2 = sigmaFactorWithSoftware2;
    simuinfo.config.unitMismatch = unitMismatch;
    
    baseSimulationDir = fullfile(baseDir, 'simulations');
    save(fullfile(baseSimulationDir, 'simuinfo.mat'), 'simuinfo');
    
    
    % Number of studies per meta-analysis
    for iStudies = 1:numel(nStudiesArray)
        nStudies = nStudiesArray(iStudies);
        
        % Cross-studies unit mismatch
        for iUnitMisMatch = unitMismatch

            % Cross-software unit mismatch
            for iSigmaFactorSoftware = sigmaFactorWithSoftware2
                for iStudiesWithSoftware2 = nStudiesWithSoftware2
                    if (iUnitMisMatch && iStudiesWithSoftware2~=0) || ...
                       (iUnitMisMatch && iSigmaFactorSoftware~=1) || ...
                       (~iUnitMisMatch && iStudiesWithSoftware2==0 && iSigmaFactorSoftware~=1) || ...
                       (iSigmaFactorSoftware==1 && iStudiesWithSoftware2~=0) 
                        warning(['Ignore: mismatch=' num2str(iUnitMisMatch) ...
                            ' , studies with software 2=' num2str(iStudiesWithSoftware2) ...
                            ', factor software=' num2str(iSigmaFactorSoftware) ...                            
                            ])
                        continue;
                    end
                    
                    if iUnitMisMatch
                        % Uniformly distributed beween 0.4 and 1.6 included, so that 
                        % mean(unitFactor) = 1 and 1.6/0.4=4
                        unitFactor = randi([1 4], 1, nStudies)/2.5;%linspace(AVG_NUM_SUB/2,AVG_NUM_SUB*2,nStudies);
                    else
                        unitFactor = ones(1, nStudies);
                    end
                    
                    studiesWithSofware = ones(nStudies, 1);
                    studiesWithSofware(1:nStudies*iStudiesWithSoftware2) = 2;
                    
                    unitFactor(studiesWithSofware==2) = unitFactor(studiesWithSofware==2).*iSigmaFactorSoftware;

                    for iSubPerStudyScheme = 1:numel(subjectPerStudiesScheme)

            %             nSubjects = get_n_subjects_per_studies(nStudies);
                        subjectNumberScheme = subjectPerStudiesScheme{iSubPerStudyScheme};
                        switch subjectNumberScheme
                            case {'identical'}
                                nSubjects = ones(1, nStudies)*AVG_NUM_SUB;
                            case {'different'}

                                % Uniformly distributed beween AVG_NUM_SUB-NUM_SUB_DIFF 
                                % and AVG_NUM_SUB+NUM_SUB_DIFF included, so that 
                                % mean(nSubjects) = AVG_NUM_SUB
                                nSubjects = randi([AVG_NUM_SUB-NUM_SUB_DIFF AVG_NUM_SUB+NUM_SUB_DIFF], 1, nStudies);%linspace(AVG_NUM_SUB/2,AVG_NUM_SUB*2,nStudies);
                            otherwise
                              error('')
                        end

                        % Between-studies variance (RFX?)
                        for iEffects = 1:numel(sigmaBetweenStudiesArray)
                            sigmaBetweenStudies = sigmaBetweenStudiesArray(iEffects);

                             for iSigmaSquare = 1:numel(sigmaSquareArray)
                                for iVariance = 1:numel(studyVarianceSchemes)
                                    studyVarianceScheme = studyVarianceSchemes{iVariance};

                                    switch studyVarianceScheme
                                        case {'identical'}
                                            varAlpha = ones(1, nStudies);
                                        case {'different'}
                                            % Generate values from the uniform 
                                            % distribution on the interval [a, b].
                                            a = 1/2;
                                            b = 2;
                                            varAlpha = a + (b-a).*rand(nStudies,1);
                                        otherwise
                                          error('')
                                    end

                                    tic;
                                    % Common level of (intra-studies) variance (ignoring effect of sample 
                                    % size).
                                    sigmaSquare = sigmaSquareArray(iSigmaSquare);

                    %                 % Study-specific variance (i.e. common study-variance divided by sample
                    %                 % size).
                    %                 sigmaSquareStudies = sigmaSquare./nSubjects + sigmaBetweenStudies;



                                    % Directory to store the simulation data and results.
                                    currSimuDirName = ['nStudy' num2str(nStudies) '_subNum' subjectNumberScheme '_var' studyVarianceScheme '_Betw' num2str(sigmaBetweenStudies) ...
                                        '_Within' num2str(sigmaSquare/AVG_NUM_SUB) '_nSimuOneDir' num2str(nSimuOneDir), '_unitmis' num2str(iUnitMisMatch) '_numStudySoft'...
                                        num2str(iStudiesWithSoftware2) '_softFactor' num2str(iSigmaFactorSoftware)];
                                    simulationDir = fullfile(baseSimulationDir, currSimuDirName);

                                    disp(simulationDir)

                                    % Simulate data only if simulationDir did not xist
                                    % before (helpful to re-run analysis on same data
                                    dataDir = fullfile(simulationDir, 'data');
                                    fisherDir = fullfile(simulationDir, 'fishers');
                                    stoufferDir = fullfile(simulationDir, 'stouffers');
                                    stoufferMFXDir = fullfile(simulationDir, 'stouffersMFX');
                                    weightedZDir = fullfile(simulationDir, 'weightedZ');
                                    megaRfxDir = fullfile(simulationDir, 'megaRFX');
                                    megaFfxDir = fullfile(simulationDir, 'megaFFX');
                                    permutConDir = fullfile(simulationDir, 'permutCon');
                                    permutZDir = fullfile(simulationDir, 'permutZ');

                                    if isdir(simulationDir)
                                        already_existing = true;
                                        for iStudy = 1:nStudies
                                            conFiles{iStudy} = fullfile(dataDir, ['con_st' num2str(iStudy) '.nii']);
                                            varConFiles{iStudy} = fullfile(dataDir, ['varcon_st' num2str(iStudy) '.nii']);
                                            zFiles{iStudy} = fullfile(dataDir, ['z_st' num2str(iStudy) '.nii']);
                                        end
                                    else
                                        already_existing = false;
                                        mkdir(simulationDir);


                                        % Directory to store the simulation data.
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
                                            estimatedContrast = normrnd(0, sqrt(sigmaSquare*varAlpha(iStudy)./nSubjects(iStudy)+sigmaBetweenStudies), [nSimuOneDir, nSimuOneDir, nSimuOneDir]);
                        %                     estimatedContrast = mean(estimatedSubContrast, 4);%

                                            % Estimated variance (from chi square distribution)
                        %                     estimatedSigmaSquare = var(estimatedSubContrast, 0, 4);
                                            estimatedSigmaSquare = chi2rnd(dof, [nSimuOneDir, nSimuOneDir, nSimuOneDir])*sigmaSquare*varAlpha(iStudy)/dof;
                                            
                                            % units correction
                                            estimatedContrast = estimatedContrast*unitFactor(iStudy);
                                            estimatedSigmaSquare = estimatedSigmaSquare*(unitFactor(iStudy)^2);
                                            
                                            
                %                             estimatedSigmaSquare = estimatedSigmaSquare./nSubjects(iStudy);

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
                                            zData = norminv(cdf('T', estimatedContrast./sqrt(estimatedSigmaSquare./nSubjects(iStudy)), nSubjects(iStudy)-1));
                                            infPos = find(isinf(zData(:)));

                                            zData(infPos) = -norminv(cdf('T', -estimatedContrast(infPos)./sqrt(estimatedSigmaSquare(infPos)./nSubjects(iStudy)), nSubjects(iStudy)-1));
                                            spm_write_vol(vol, zData);                                             
                                        end
                                        mkdir(fisherDir);
                                        mkdir(stoufferDir);
                                        mkdir(stoufferMFXDir);    
                                        mkdir(weightedZDir);
                                        mkdir(megaRfxDir);
                                        mkdir(megaFfxDir);
                                        mkdir(permutConDir);                            
                                        mkdir(permutZDir);   
                                    end  

                                    % --- Compute meta-analysis ---
                                    if ~already_existing
                                        matlabbatch = {};
                                        % Fisher's
                                        matlabbatch{1}.spm.tools.ibma.fishers.dir = {fisherDir};
                                        matlabbatch{1}.spm.tools.ibma.fishers.zimages = zFiles;

                                        % Stouffer's
                                        matlabbatch{end+1}.spm.tools.ibma.stouffers.dir = {stoufferDir};
                                        matlabbatch{end}.spm.tools.ibma.stouffers.zimages = zFiles;
                                        matlabbatch{end}.spm.tools.ibma.stouffers.rfx.RFX_no = 1;

                                        % Stouffer's MFX
                                        matlabbatch{end+1}.spm.tools.ibma.stouffers.dir = {stoufferMFXDir};
                                        matlabbatch{end}.spm.tools.ibma.stouffers.zimages = zFiles;
                                        matlabbatch{end}.spm.tools.ibma.stouffers.rfx.RFX_yes = 0;

                                        % Optimally weighted z
                                        matlabbatch{end+1}.spm.tools.ibma.weightedz.dir = {weightedZDir};
                                        matlabbatch{end}.spm.tools.ibma.weightedz.zimages = zFiles;
                                        matlabbatch{end}.spm.tools.ibma.weightedz.nsubjects = nSubjects;

                                        % Mega-analysis RFX
                                        matlabbatch{end+1}.spm.tools.ibma.megarfx.dir = {megaRfxDir};
                                        matlabbatch{end}.spm.tools.ibma.megarfx.confiles = conFiles;

                                        % Mega-analysis FFX
                                        matlabbatch{end+1}.spm.tools.ibma.megaffx.dir = {megaFfxDir};
                                        if length(unique(nSubjects)) == 1
                                            matlabbatch{end}.spm.tools.ibma.megaffx.samplesize.equal.nsubjects = unique(nSubjects);
                                        else
                                            matlabbatch{end}.spm.tools.ibma.megaffx.samplesize.unequal.nsubjects = nSubjects;
                                        end
                                        matlabbatch{end}.spm.tools.ibma.megaffx.variances.equal = true;

                                        matlabbatch{end}.spm.tools.ibma.megaffx.confiles = conFiles;
                                        matlabbatch{end}.spm.tools.ibma.megaffx.varconfiles = varConFiles;

                                        % Permutation on conFiles
                                        matlabbatch{end+1}.spm.tools.snpm.des.OneSampT.DesignName = 'MultiSub: One Sample T test on diffs/contrasts';
                                        matlabbatch{end}.spm.tools.snpm.des.OneSampT.DesignFile = 'snpm_bch_ui_OneSampT';
                                        matlabbatch{end}.spm.tools.snpm.des.OneSampT.dir = {permutConDir};
                                        matlabbatch{end}.spm.tools.snpm.des.OneSampT.P = conFiles;
                                        matlabbatch{end+1}.spm.tools.snpm.cp.snpmcfg = {fullfile(permutConDir, 'SnPMcfg.mat')};

                                        % Permutation on zFiles
                                        matlabbatch{end+1}.spm.tools.snpm.des.OneSampT.DesignName = 'MultiSub: One Sample T test on diffs/contrasts';
                                        matlabbatch{end}.spm.tools.snpm.des.OneSampT.DesignFile = 'snpm_bch_ui_OneSampT';
                                        matlabbatch{end}.spm.tools.snpm.des.OneSampT.dir = {permutZDir};
                                        matlabbatch{end}.spm.tools.snpm.des.OneSampT.P = zFiles;
                                        matlabbatch{end+1}.spm.tools.snpm.cp.snpmcfg = {fullfile(permutZDir, 'SnPMcfg.mat')};

                                        spm_jobman('run', matlabbatch)

                                        simu.config.nSubjectsScheme = subjectNumberScheme;
                                        simu.config.nSubjects = nSubjects;
                                        simu.config.studyVarianceScheme = studyVarianceScheme;
                                        simu.config.varAlpha = varAlpha;
                                        simu.config.nStudies = nStudies;
                                        simu.config.sigmaSquare = sigmaSquare;
                                        simu.config.sigmaBetweenStudies = sigmaBetweenStudies;
                                        simu.config.nSimuOneDir = nSimuOneDir;
                                        simu.config.nStudiesWithSoftware2 = iStudiesWithSoftware2;
                                        simu.config.sigmaFactorWithSoftware2 = iSigmaFactorSoftware;
                                        simu.config.unitMismatch = iUnitMisMatch;
                                        simu.config.unitFactor = unitFactor;

                                        simu.config.timing = toc;

                                        save(fullfile(simulationDir, 'simu.mat'), 'simu')
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end