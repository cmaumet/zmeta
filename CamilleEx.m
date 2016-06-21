function simulations(baseDir, redo)
    if ~exist('redo', 'var')
        redo = false;
    end
    redo

    disp(['This is run ' getenv('SGE_TASK_ID')])
    addpath(fullfile(pwd, '..', 'code', 'spm12'))
    disp(fullfile(pwd, '..', 'code','spm12'))
    addpath(fullfile(pwd, '..', 'code','automri', 'commons', 'lib'))
    addpath(fullfile(pwd, '..', 'code','simu_lib'))

    spm_jobman('initcfg');
    set_fsl_env()
% SIMULATIONS    Perform simulations based on IBMA toolbox. 
%
%   simulations(baseDir)

% Copyright (C) 2014 The University of Warwick
% Id: ibma_test_stouffers.m  IBMA toolbox
% Camille Maumet

    % Number of subject per study
%     nSubjects = [25 400 100 25]; %[10, 15, 20, 25, 30, 10, 15, 20, 25, 30, 10, 15, 20, 25, 30];
%     nStudies = numel(nSubjects);
    nStudiesArray = [50]% 50];%[5 10 25 50];
    AVG_NUM_SUB = 20;
    NUM_SUB_DIFF = 15;
    sigmaSquareArray = AVG_NUM_SUB*[4] %[0.25, 0.5, 1, 2, 4];%How to compute z with var = 0?
    studyVarianceSchemes = {'identical'} %, 'different'}; don't know yet how to deal with uneq var (for FFX!?)
    
    % Between-studies variance (RFX?)
    sigmaBetweenStudiesArray = [1]%  1];
    
    % Number of subjects per studies     
    subjectPerStudiesScheme = {'identical'}%, 'different'};
    
    % Number of studies with software 2 (fraction)
    nStudiesWithSoftware2 = [0 1/5 0.5];
    
    % Correction factor with software 2
    sigmaFactorWithSoftware2 = [1 2 100];
    
    % Study-specific bias due to units mismatch
    unitMismatch = [true] %[false, true];
    
    % Type of analysis: one-sample (1), two-sample(2), two-sample
    % unbalanced (3)
    analysisTypes = [1]% 2 3];
    
    % Size of the simulation image (in 1 direction). Each voxel of the
    % simulation image is a simulation sample.
    nSimuOneDir = 30;%100;
    nSimu = nSimuOneDir^3;
    
    if nargin == 0
        baseDir = '/storage/wmsmfe';
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
    if ~isdir(baseSimulationDir)
        mkdir(baseSimulationDir)
    end
    save(fullfile(baseSimulationDir, 'simuinfo.mat'), 'simuinfo');
     
    % Number of studies per meta-analysis
    for iStudies = 1:numel(nStudiesArray)
        nStudies = nStudiesArray(iStudies);
        
        % One-sample, two-sample, two-sample unbalanced
        for analysisType = analysisTypes
            if analysisType == 1
                analysisPrefix = '';
                numStudyInGroup1 = nStudies;
                numStudyInGroup2 = 0;
            elseif analysisType == 2
                analysisPrefix = 'two_';
                numStudyInGroup1 = nStudies;
                numStudyInGroup2 = nStudies;
            elseif analysisType == 3
                analysisPrefix = 'two_unb_';
                numStudyInGroup1 = nStudies*2*4/5;
                numStudyInGroup2 = nStudies*2/5;
            end

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
                            unitFactorInGroup1 = randi([1 4], 1, numStudyInGroup1)/2.5;%linspace(AVG_NUM_SUB/2,AVG_NUM_SUB*2,nStudies);
                            unitFactorInGroup2 = randi([1 4], 1, numStudyInGroup2)/2.5;
                        else
                            unitFactorInGroup1 = ones(1, numStudyInGroup1);
                            unitFactorInGroup2 = ones(1, numStudyInGroup2);
                        end

                        studiesWithSofwareInGroup1 = ones(numStudyInGroup1, 1);
                        studiesWithSofwareInGroup1(1:numStudyInGroup1*iStudiesWithSoftware2) = 2;

                        if analysisType > 1
                            studiesWithSofwareInGroup2 = ones(numStudyInGroup2, 1);
                            studiesWithSofwareInGroup2(1:numStudyInGroup2*iStudiesWithSoftware2) = 2;
                        end
                        
                        unitFactorInGroup1(studiesWithSofwareInGroup1==2) = unitFactorInGroup1(studiesWithSofwareInGroup1==2).*iSigmaFactorSoftware;
                        
                        if analysisType > 1
                            unitFactorInGroup2(studiesWithSofwareInGroup2==2) = unitFactorInGroup2(studiesWithSofwareInGroup2==2).*iSigmaFactorSoftware;
                        end

                        for iSubPerStudyScheme = 1:numel(subjectPerStudiesScheme)

                %             nSubjects = get_n_subjects_per_studies(nStudies);
                            subjectNumberScheme = subjectPerStudiesScheme{iSubPerStudyScheme};
                            switch subjectNumberScheme
                                case {'identical'}
                                    nSubjectsInGroup1 = ones(1, numStudyInGroup1)*AVG_NUM_SUB;
                                    nSubjectsInGroup2 = ones(1, numStudyInGroup2)*AVG_NUM_SUB;
                                case {'different'}

                                    % Uniformly distributed beween AVG_NUM_SUB-NUM_SUB_DIFF 
                                    % and AVG_NUM_SUB+NUM_SUB_DIFF included, so that 
                                    % mean(nSubjects) = AVG_NUM_SUB
                                    nSubjectsInGroup1 = randi([AVG_NUM_SUB-NUM_SUB_DIFF AVG_NUM_SUB+NUM_SUB_DIFF], 1, numStudyInGroup1);%linspace(AVG_NUM_SUB/2,AVG_NUM_SUB*2,nStudies);
                                    nSubjectsInGroup2 = randi([AVG_NUM_SUB-NUM_SUB_DIFF AVG_NUM_SUB+NUM_SUB_DIFF], 1, numStudyInGroup2);%linspace(AVG_NUM_SUB/2,AVG_NUM_SUB*2,nStudies);
                                otherwise
                                  error('')
                            end
                            disp(nSubjectsInGroup1)
                            disp(nSubjectsInGroup2)

                            % Between-studies variance (RFX?)
                            for iEffects = 1:numel(sigmaBetweenStudiesArray)
                                sigmaBetweenStudies = sigmaBetweenStudiesArray(iEffects);

                                 for iSigmaSquare = 1:numel(sigmaSquareArray)
                                    for iVariance = 1:numel(studyVarianceSchemes)
                                        studyVarianceScheme = studyVarianceSchemes{iVariance};

                                        switch studyVarianceScheme
                                            case {'identical'}
                                                varAlphaInGroup1 = ones(1, numStudyInGroup1);
                                                varAlphaInGroup2 = ones(1, numStudyInGroup2);
                                            case {'different'}
                                                % Generate values from the uniform 
                                                % distribution on the interval [a, b].
                                                a = 1/2;
                                                b = 2;
                                                varAlphaInGroup1 = a + (b-a).*rand(numStudyInGroup1,1);
                                                varAlphaInGroup2 = a + (b-a).*rand(numStudyInGroup2,1);
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
                                        currSimuDirName = [analysisPrefix 'nStudy' num2str(nStudies) '_subNum' subjectNumberScheme '_var' studyVarianceScheme '_Betw' num2str(sigmaBetweenStudies) ...
                                            '_Within' num2str(sigmaSquare/AVG_NUM_SUB) '_nSimuOneDir' num2str(nSimuOneDir), '_unitmis' num2str(iUnitMisMatch) '_numStudySoft'...
                                            num2str(iStudiesWithSoftware2) '_softFactor' num2str(iSigmaFactorSoftware)];
                                        simulationDir = fullfile(baseSimulationDir, currSimuDirName, num2str(str2num(getenv('SGE_TASK_ID')), '%04d'));

                                        disp(simulationDir)
                                        
                                        exist_simu_dir = isdir(simulationDir);

                                        if redo && exist_simu_dir
                                            % Move existing simulation directory
                                            movefile(simulationDir, [simulationDir '_OLD'])
                                            exist_simu_dir = false
                                        end

                                        if ~exist_simu_dir
                                            if ~isdir(fullfile(baseSimulationDir, currSimuDirName))
                                                mkdir(fullfile(baseSimulationDir, currSimuDirName))
                                            end
                                            mkdir(simulationDir);
                                        end
                                        
                                        simu.config.nSubjectsScheme = subjectNumberScheme;
                                        if analysisType > 1
                                            simu.config.nSubjectsInGroup1 = nSubjectsInGroup1;
                                            simu.config.nSubjectsInGroup2 = nSubjectsInGroup2;
                                        else
                                            simu.config.nSubjects = nSubjectsInGroup1;
                                        end
                                        simu.config.studyVarianceScheme = studyVarianceScheme;
                                        
                                        if analysisType > 1
                                            simu.config.nStudiesInGroup1 = numStudyInGroup1;
                                            simu.config.nStudiesInGroup2 = numStudyInGroup2;
                                            simu.config.varAlphaInGroup1 = varAlphaInGroup1;
                                            simu.config.varAlphaInGroup2 = varAlphaInGroup2;
                                        else
                                            simu.config.nStudies = numStudyInGroup1;
                                            simu.config.varAlpha = varAlphaInGroup1;
                                        end
                                        simu.config.sigmaSquare = sigmaSquare;
                                        simu.config.sigmaBetweenStudies = sigmaBetweenStudies;
                                        simu.config.nSimuOneDir = nSimuOneDir;
                                        simu.config.nStudiesWithSoftware2 = iStudiesWithSoftware2;
                                        simu.config.sigmaFactorWithSoftware2 = iSigmaFactorSoftware;
                                        simu.config.unitMismatch = iUnitMisMatch;
                                        simu.config.unitFactorInGroup1 = unitFactorInGroup1;
                                        simu.config.unitFactorInGroup2 = unitFactorInGroup2;
                                        simu.config.analysisType = analysisType;
                                        simu.config.timing = toc;

                                        save(fullfile(simulationDir, 'simu.mat'), 'simu')
                                        
                                        % Simulate data only if simulationDir did not xist
                                        % before (helpful to re-run analysis on same data
                                        dataDir = fullfile(simulationDir, 'data');
                                        fisherDir = fullfile(simulationDir, 'fishers');
                                        stoufferDir = fullfile(simulationDir, 'stouffers');
                                        stoufferMFXDir = fullfile(simulationDir, 'stouffersMFX');
                                        weightedZDir = fullfile(simulationDir, 'weightedZ');
                                        megaRfxDir = fullfile(simulationDir, 'megaRFX');
                                        megaFfxDir = fullfile(simulationDir, 'megaFFX');
                                        megaFfxFslDir = fullfile(simulationDir, 'megaFFX_FSL');
                                        megaMfxDir = fullfile(simulationDir, 'megaMFX');
                                        permutConDir = fullfile(simulationDir, 'permutCon');
                                        permutZDir = fullfile(simulationDir, 'permutZ');

                                        if exist_simu_dir
                                            for iStudy = 1:(numStudyInGroup1+numStudyInGroup2)
                                                [~, conFiles{iStudy}] = find_file_nii_or_gz(fullfile(dataDir, ['con_st' num2str(iStudy, '%03d') '.nii']));
                                                [~, varConFiles{iStudy}] = find_file_nii_or_gz(fullfile(dataDir, ['varcon_st' num2str(iStudy, '%03d') '.nii']));
                                                [~, zFiles{iStudy}] = find_file_nii_or_gz(fullfile(dataDir, ['z_st' num2str(iStudy, '%03d') '.nii']));
                                            end
%                                             load(fullfile(simulationDir, 'simu.mat'))
%                                             fields = fieldnames(simu.config);
%                                             for f = 1:numel(fields)
%                                                 eval([fields{f} ' = ' simu.config.(fields{f})])
%                                             end
                                        else
                                            % Directory to store the simulation data.
                                            mkdir(dataDir);

                                            % --- Simulated data ---
                                            subIdx = 0;

                                            % For each study involved in the current meta-analysis
                                            for iStudy = 1:(numStudyInGroup1+numStudyInGroup2)
                                                
                                                if iStudy <= numStudyInGroup1
                                                    studyIndex = iStudy;
                                                    nSubjects = nSubjectsInGroup1;
                                                    unitFactor = unitFactorInGroup1;
                                                    varAlpha = varAlphaInGroup1;
                                                else
                                                    studyIndex = iStudy-numStudyInGroup1;
                                                    nSubjects = nSubjectsInGroup2;
                                                    unitFactor = unitFactorInGroup2;
                                                    varAlpha = varAlphaInGroup2;
                                                end
                                                % Degrees of freedom of the within-study variance estimate
                                                dof = nSubjects(studyIndex)-1;

                                                % Estimated paramater estimate.
                                                estimatedContrast = normrnd(0, sqrt(sigmaSquare*varAlpha(studyIndex)./nSubjects(studyIndex)+sigmaBetweenStudies), [nSimuOneDir, nSimuOneDir, nSimuOneDir]);

                                                % Estimated variance (from chi square distribution)
                                                estimatedSigmaSquare = chi2rnd(dof, [nSimuOneDir, nSimuOneDir, nSimuOneDir])*sigmaSquare*varAlpha(studyIndex)/dof;
                                                estimatedVarContrast = estimatedSigmaSquare./nSubjects(studyIndex);

                                                % units correction
                                                estimatedContrast = estimatedContrast*unitFactor(studyIndex);
                                                estimatedVarContrast = estimatedVarContrast*(unitFactor(studyIndex)^2);


                    %                             estimatedSigmaSquare = estimatedSigmaSquare./nSubjects(iStudy);

                                                % Write out parameter estimates.      
                                                conFiles{iStudy} = fullfile(dataDir, ['con_st' num2str(iStudy, '%03d') '.nii']);
                                                vol    = struct('fname',  conFiles{iStudy},...
                                                           'dim',    [nSimuOneDir nSimuOneDir nSimuOneDir],...
                                                           'dt',     [spm_type('float32') spm_platform('bigend')],...
                                                           'mat',    eye(4),...
                                                           'pinfo',  [1 0 0]',...
                                                           'descrip','simulation');
                                                vol    = spm_create_vol(vol);
                                                spm_write_vol(vol, estimatedContrast);

                                                % Write out estimated variance of parameter estimates.
                                                varConFiles{iStudy} = fullfile(dataDir, ['varcon_st' num2str(iStudy, '%03d') '.nii']);
                                                vol.fname =  varConFiles{iStudy};
                                                spm_write_vol(vol, estimatedVarContrast);

                                                % Write out corresponding z-values.
                                                zFiles{iStudy} = fullfile(dataDir, ['z_st' num2str(iStudy, '%03d') '.nii']);
                                                vol.fname = zFiles{iStudy};

                                                % Z-transform of T-statistic
                                                zData = norminv(cdf('T', estimatedContrast./sqrt(estimatedVarContrast), nSubjects(studyIndex)-1));
                                                infPos = find(isinf(zData(:)));

                                                zData(infPos) = -norminv(cdf('T', -estimatedContrast(infPos)./sqrt(estimatedVarContrast(infPos)), nSubjects(studyIndex)-1));
                                                spm_write_vol(vol, zData);   
                                                
                                                clear studyIndex;
                                                clear nSubjects;
                                                clear unitFactor;
                                                clear varAlpha;
                                            end
                                            if analysisType == 1
                                                mkdir(fisherDir);
                                                mkdir(stoufferDir);
                                                mkdir(stoufferMFXDir);    
                                                mkdir(weightedZDir);
                                            end
                                            mkdir(megaRfxDir);
%                                             mkdir(megaFfxDir);
                                            mkdir(permutConDir);                            
                                            mkdir(permutZDir);   
                                            mkdir(megaMfxDir);   
                                            mkdir(megaFfxFslDir);
                                        end  

                                        % --- Compute meta-analysis ---
                                        matlabbatch = {};
                                        
                                        if analysisType == 1
                                            % Fisher's
                                            if ~find_file_nii_or_gz(fullfile(fisherDir, 'fishers_ffx_minus_log10_p.nii'))
                                                matlabbatch{1}.spm.tools.ibma.fishers.dir = {fisherDir};
                                                matlabbatch{1}.spm.tools.ibma.fishers.zimages = zFiles;
                                            else
                                                disp('Fisher''s already computed')
                                            end

                                            % Stouffer's
                                            if ~find_file_nii_or_gz(fullfile(stoufferDir, 'stouffers_ffx_minus_log10_p.nii'))
                                                matlabbatch{end+1}.spm.tools.ibma.stouffers.dir = {stoufferDir};
                                                matlabbatch{end}.spm.tools.ibma.stouffers.zimages = zFiles;
                                                matlabbatch{end}.spm.tools.ibma.stouffers.rfx.RFX_no = 1;
                                            else
                                                disp('Stouffer''s already computed')
                                            end

                                            % Stouffer's MFX
                                            if ~find_file_nii_or_gz(fullfile(stoufferMFXDir, 'stouffers_rfx_minus_log10_p.nii'))
                                                matlabbatch{end+1}.spm.tools.ibma.stouffers.dir = {stoufferMFXDir};
                                                matlabbatch{end}.spm.tools.ibma.stouffers.zimages = zFiles;
                                                matlabbatch{end}.spm.tools.ibma.stouffers.rfx.RFX_yes = 0;
                                            else
                                                disp('Stouffer''s MFX already computed')
                                            end

                                            % Optimally weighted z
                                            if ~find_file_nii_or_gz(fullfile(weightedZDir, 'weightedz_ffx_minus_log10_p.nii'))
                                                matlabbatch{end+1}.spm.tools.ibma.weightedz.dir = {weightedZDir};
                                                matlabbatch{end}.spm.tools.ibma.weightedz.zimages = zFiles;
                                                matlabbatch{end}.spm.tools.ibma.weightedz.nsubjects = nSubjectsInGroup1;
                                            else
                                                disp('Weighted Z already computed')
                                            end
                                        end

                                        % Mega-analysis RFX
                                        if ~find_file_nii_or_gz(fullfile(megaRfxDir, 'mega_rfx_minus_log10_p.nii'))
                                            if analysisType == 1
                                                matlabbatch{end+1}.spm.tools.ibma.megarfx.dir = {megaRfxDir};
                                                matlabbatch{end}.spm.tools.ibma.megarfx.confiles = conFiles;
                                            else
                                                matlabbatch{end+1}.spm.stats.factorial_design.dir = {megaRfxDir};
                                                matlabbatch{end}.spm.stats.factorial_design.des.t2.scans1 = conFiles(1:numStudyInGroup1)';
                                                matlabbatch{end}.spm.stats.factorial_design.des.t2.scans2 = conFiles(numStudyInGroup1+(1:numStudyInGroup2))';
                                                matlabbatch{end}.spm.stats.factorial_design.des.t2.variance = 0;
                                                matlabbatch{end+1}.spm.stats.fmri_est.spmmat = {fullfile(megaRfxDir, 'SPM.mat')};
                                                matlabbatch{end+1}.spm.stats.con.spmmat = {fullfile(megaRfxDir, 'SPM.mat')};
                                                matlabbatch{end}.spm.stats.con.consess{1}.tcon.name = 'bewteen group effect';
                                                matlabbatch{end}.spm.stats.con.consess{1}.tcon.convec = [1 -1];
                                                
                                                statFile = fullfile(megaRfxDir, 'spmT_0001.nii');
                                                matlabbatch{end+1}.spm.util.imcalc.input = {statFile};
                                                matlabbatch{end}.spm.util.imcalc.output = 'mega_rfx_minus_log10_p.nii';
                                                matlabbatch{end}.spm.util.imcalc.outdir = {megaRfxDir};
                            
                                                dof = numStudyInGroup1+numStudyInGroup2-2;
                                                matlabbatch{end}.spm.util.imcalc.expression = ['-log10(cdf(''T'',-i1, ' num2str(dof) '))'];
                                                matlabbatch{end}.spm.util.imcalc.options.dmtx = 0;
                                                matlabbatch{end}.spm.util.imcalc.options.dtype = 64;
                                            end
                                        else
                                            disp('Mega RFX already computed')
                                        end

    %                                     % Mega-analysis FFX
    %                                     if ~exist(fullfile(megaFfxDir, 'mega_ffx_ffx_minus_log10_p.nii'), 'file')
    %                                         matlabbatch{end+1}.spm.tools.ibma.megaffx.dir = {megaFfxDir};
    %                                         if length(unique(nSubjects)) == 1
    %                                             matlabbatch{end}.spm.tools.ibma.megaffx.samplesize.equal.nsubjects = unique(nSubjects);
    %                                         else
    %                                             matlabbatch{end}.spm.tools.ibma.megaffx.samplesize.unequal.nsubjects = nSubjects;
    %                                         end
    %                                         matlabbatch{end}.spm.tools.ibma.megaffx.variances.equal = true;
    % 
    %                                         matlabbatch{end}.spm.tools.ibma.megaffx.confiles = conFiles;
    %                                         matlabbatch{end}.spm.tools.ibma.megaffx.varconfiles = varConFiles;
    %                                     else
    %                                         disp('Mega FFX already computed')
    %                                     end
    if true
                                        % Permutation on conFiles
                                        if ~exist(fullfile(permutConDir, 'lP+.img'), 'file')
                                            conFiles = gunzip_if_gz(conFiles);
                                            if analysisType == 1                                                
                                                matlabbatch{end+1}.spm.tools.snpm.des.OneSampT.DesignName = 'MultiSub: One Sample T test on diffs/contrasts';
                                                matlabbatch{end}.spm.tools.snpm.des.OneSampT.DesignFile = 'snpm_bch_ui_OneSampT';
                                                matlabbatch{end}.spm.tools.snpm.des.OneSampT.dir = {permutConDir};
                                                matlabbatch{end}.spm.tools.snpm.des.OneSampT.P = conFiles;
                                                matlabbatch{end+1}.spm.tools.snpm.cp.snpmcfg = {fullfile(permutConDir, 'SnPMcfg.mat')};
                                            else
                                                matlabbatch{end+1}.spm.tools.snpm.des.TwoSampT.dir = {permutConDir};
                                                matlabbatch{end}.spm.tools.snpm.des.TwoSampT.scans1 = conFiles(1:numStudyInGroup1)';
                                                matlabbatch{end}.spm.tools.snpm.des.TwoSampT.scans2 = conFiles(numStudyInGroup1+(1:numStudyInGroup2))';
                                                matlabbatch{end+1}.spm.tools.snpm.cp.snpmcfg = {fullfile(permutConDir, 'SnPMcfg.mat')};
                                            end
                                        else
                                            disp('Permutation on contrast files already computed')
                                        end


                                        % Permutation on zFiles
                                        if ~exist(fullfile(permutZDir, 'lP+.img'), 'file')
                                            zFiles = gunzip_if_gz(zFiles);
                                            if analysisType == 1
                                                matlabbatch{end+1}.spm.tools.snpm.des.OneSampT.DesignName = 'MultiSub: One Sample T test on diffs/contrasts';
                                                matlabbatch{end}.spm.tools.snpm.des.OneSampT.DesignFile = 'snpm_bch_ui_OneSampT';
                                                matlabbatch{end}.spm.tools.snpm.des.OneSampT.dir = {permutZDir};
                                                matlabbatch{end}.spm.tools.snpm.des.OneSampT.P = zFiles;
                                                matlabbatch{end+1}.spm.tools.snpm.cp.snpmcfg = {fullfile(permutZDir, 'SnPMcfg.mat')};
                                            else
                                                matlabbatch{end+1}.spm.tools.snpm.des.TwoSampT.dir = {permutZDir};
                                                matlabbatch{end}.spm.tools.snpm.des.TwoSampT.scans1 = zFiles(1:numStudyInGroup1)';
                                                matlabbatch{end}.spm.tools.snpm.des.TwoSampT.scans2 = zFiles(numStudyInGroup1+(1:numStudyInGroup2))';
                                                matlabbatch{end+1}.spm.tools.snpm.cp.snpmcfg = {fullfile(permutZDir, 'SnPMcfg.mat')};
                                            end
                                        else
                                            disp('Permutation on Z already computed')
                                        end
    end

                                        if ~isempty(matlabbatch)
                                            try
                                                spm_jobman('run', matlabbatch)
                                            catch ME
                                                switch ME.identifier
                                                    case 'matlabbatch:run:jobfailederr'
                                                        warning('One job failed.');
                                                    otherwise
                                                        rethrow(ME)
                                                end
                                            end
                                        end
                                        
                                        if true
                                            % GLM MFX
                                            redomfx = false;
                                            if redomfx || ~find_file_nii_or_gz(fullfile(megaMfxDir,'mega_mfx_minus_log10_p.nii'))
                                                if ~exist('nSubjects', 'var')
                                                    nSubjects = nSubjectsInGroup1;
                                                end
                                                run_fsl_mfx(dataDir, megaMfxDir, analysisType, nSubjects, nStudies)
                                            else
                                                disp('Mega MFX (FSL) already computed')
                                            end
                                        end

                                        % GLM FFX (via FSL)
                                        if ~find_file_nii_or_gz(fullfile(megaFfxFslDir,'mega_ffx_minus_log10_p.nii'))
                                            if ~exist('nSubjects', 'var')
                                                    nSubjects = nSubjectsInGroup1;
                                            end
                                            run_fsl_ffx(dataDir, megaFfxFslDir, analysisType, nSubjects, nStudies)
                                        else
                                            disp('Mega FFX (FSL) already computed')
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
end