function meta_sim(baseDir, redo)
    % META_SIM  Simulate meta-analyses results under the null
    %   META_SIM(BASEDIR, REDO) Create simulation results in a 
    %       'simulations' folder under BASEDIR. Overwrite existing
    %       simulations only if REDO is 'true'.
    % 
    if ~exist('redo', 'var')
        redo = false;
    end
    
    % ----- Simulation parameters --------
    avg_n = 20; % Average number of subjects per group
    diff_n = 15;

    ks = [25]% 50];%[5 10 25 50];
    wth_sigmas = avg_n*[0.25 0.5 1 2 4];%How to compute z with var = 0?
    wth_sigma_sames = [true] %, 'diff'}; don't know yet how to deal with uneq var (for FFX!?)

    % Between-studies variance (RFX?)
    btw_sigmas = [1]%  1];

    % Number of subjects per studies     
    same_ns = [true]%[ true false];

    % Proportion of studies with software 2 (fraction)
    soft_props = [0 1/5 0.5];

    % Correction factor with software 2
    soft_factors = [1 2 100];

    % Study-specific bias due to units mismatch
    units = [false, true];

    % Type of analysis: one-sample (1), two-sample(2), two-sample
    % unbalanced (3)
    analysis_types = [1]% [1 2 3];

    % Size of the simulation image (in 1 direction). Each voxel of the
    % simulation image is a simulation sample.
    iter_onedir = 30;%100;
    nSimu = iter_onedir^3;

    % Number of subject per study
    %     nSubjects = [25 400 100 25]; %[10, 15, 20, 25, 30, 10, 15, 20, 25, 30, 10, 15, 20, 25, 30];
    %     nStudies = numel(nSubjects);
    % -------------------------------------------
    
    % Retreive information about current job on the cluster    
    task_id = getenv('SGE_TASK_ID');
    job_id = getenv('JOB_ID');
    queue = getenv('QUEUE');
    host = getenv('HOSTNAME');

    disp(['This is run ' task_id])
    disp(['This is job ' job_id])
    
    % SPM is required to write-out NIfTI images    
    addpath(fullfile(pwd, '..', 'code', 'spm12'))
    addpath(fullfile(pwd, '..', 'code','automri', 'commons', 'lib'))
    addpath(fullfile(pwd, 'lib'))

    % SPM and FSL initialisations    
    spm_jobman('initcfg');
    set_fsl_env()
    
    % Initialise random number generator using the task id
    cluster_task_id = str2num(task_id);
    rng(cluster_task_id);
       
    allsimu_dir = fullfile(baseDir, 'simulations');
    if ~isdir(allsimu_dir)
        mkdir(allsimu_dir)
    end
     
    % Number of studies per meta-analysis
    for k = ks
        
        % One-sample, two-sample, two-sample unbalanced
        for analysis_type = analysis_types
            if analysis_type == 1
                analysisPrefix = '';
                k_group1 = k;
                k_group2 = 0;
            elseif analysis_type == 2
                analysisPrefix = 'two_';
                k_group1 = k;
                k_group2 = k;
            elseif analysis_type == 3
                analysisPrefix = 'two_unb_';
                k_group1 = k*2*4/5;
                k_group2 = k*2/5;
            end

            % Cross-studies unit mismatch
            for unit_mis = units

                % Cross-software unit mismatch
                for soft_factor = soft_factors
                    
                    % Proportion of studies analysed with software 2                    
                    for soft_prop = soft_props
                        if (unit_mis && soft_prop~=0) || ...
                           (unit_mis && soft_factor~=1) || ...
                           (~unit_mis && soft_prop==0 && soft_factor~=1) || ...
                           (soft_factor==1 && soft_prop~=0) 
                            warning(['Ignore: mismatch=' num2str(unit_mis) ...
                                ' , studies with software 2=' num2str(soft_prop) ...
                                ', factor software=' num2str(soft_factor) ...                            
                                ])
                            continue;
                        end

                        if unit_mis
                            % Uniformly distributed beween 0.4 and 1.6 
                            % included, so that mean(unitFactor) = 1 and 
                            % 1.6/0.4=4
                            factor_group1 = randi([1 4], 1, k_group1)/2.5;%linspace(avg_n/2,avg_n*2,k);
                            factor_group2 = randi([1 4], 1, k_group2)/2.5;
                        else
                            factor_group1 = ones(1, k_group1);
                            factor_group2 = ones(1, k_group2);
                        end

                        group1_soft = ones(k_group1, 1);
                        group1_soft(1:k_group1*soft_prop) = 2;

                        if analysis_type > 1
                            group2_soft = ones(k_group2, 1);
                            group2_soft(1:k_group2*soft_prop) = 2;
                        end
                        
                        factor_group1(group1_soft==2) = factor_group1(group1_soft==2).*soft_factor;
                        if analysis_type > 1
                            factor_group2(group2_soft==2) = factor_group2(group2_soft==2).*soft_factor;
                        end

                        for same_n = same_ns

                            if same_n
                                group1_n = ones(1, k_group1)*avg_n;
                                group2_n = ones(1, k_group2)*avg_n;
                            else

                                % Uniformly distributed beween avg_n-diff_n 
                                % and avg_n+diff_n included, so that 
                                % mean(nsub) = avg_n
                                group1_n = randi([avg_n-diff_n avg_n+diff_n], 1, k_group1);%linspace(avg_n/2,avg_n*2,k);
                                group2_n = randi([avg_n-diff_n avg_n+diff_n], 1, k_group2);%linspace(avg_n/2,avg_n*2,k);
                            end
                            disp(group1_n)
                            disp(group2_n)

                            % Between-studies variance
                            for btw_sigma = btw_sigmas

                                 % Within-study variance (ignoring sample
                                 % size)
                                 for sigma_sq = wth_sigmas
                                    for wth_sigma_same = wth_sigma_sames

                                        if wth_sigma_same
                                            group1_wth_sigma_a = ones(1, k_group1);
                                            group2_wth_sigma_a = ones(1, k_group2);
                                        else
                                            % Generate values from the uniform 
                                            % distribution on the interval [a, b].
                                            a = 1/2;
                                            b = 2;
                                            group1_wth_sigma_a = a + (b-a).*rand(k_group1,1);
                                            group2_wth_sigma_a = a + (b-a).*rand(k_group2,1);
                                        end

                                        % Directory to store the simulation data and results.
                                        simu_name = [analysisPrefix 'k' num2str(k) '_btw' num2str(btw_sigma) ...
                                            '_wth' num2str(sigma_sq), '_unit' num2str(unit_mis) '_otherSoft'...
                                            num2str(soft_prop) '_' num2str(soft_factor)];
                                        simu_dir = fullfile(allsimu_dir, simu_name, num2str(cluster_task_id, '%04d'));
                                        disp(simu_dir)
                                        
                                        exist_simu_dir = isdir(simu_dir);

                                        if redo && exist_simu_dir
                                            % Move existing simulation directory
                                            movefile(simu_dir, [simu_dir '_OLD'])
                                            exist_simu_dir = false;
                                        end

                                        if ~exist_simu_dir
                                            if ~isdir(fullfile(allsimu_dir, simu_name))
                                                mkdir(fullfile(allsimu_dir, simu_name))
                                            end
                                            mkdir(simu_dir);
                                        end
                                        
                                        simu.config.same_n = same_n;
                                        if analysis_type > 1
                                            simu.config.group1_n = group1_n;
                                            simu.config.group2_n = group2_n;
                                        else
                                            simu.config.nsub = group1_n;
                                        end
                                        simu.config.wth_sigma_same = wth_sigma_same;
                                        
                                        if analysis_type > 1
                                            simu.config.k_group1 = k_group1;
                                            simu.config.k_group2 = k_group2;
                                            simu.config.group1_wth_sigma_a = group1_wth_sigma_a;
                                            simu.config.group2_wth_sigma_a = group2_wth_sigma_a;
                                        else
                                            simu.config.k = k_group1;
                                            simu.config.wth_sigma_a = group1_wth_sigma_a;
                                        end
                                        simu.config.sigma_sq = sigma_sq;
                                        simu.config.btw_sigma = btw_sigma;
                                        simu.config.iter_onedir = iter_onedir;
                                        simu.config.soft_prop = soft_prop;
                                        simu.config.soft_factor = soft_factor;
                                        simu.config.unit_mis = unit_mis;
                                        simu.config.factor_group1 = factor_group1;
                                        simu.config.factor_group2 = factor_group2;
                                        simu.config.analysis_type = analysis_type;

                                        simucfg_file = fullfile( ...
                                            simu_dir, 'simu.mat');
                                        disp(simucfg_file)

                                        if exist(simucfg_file, 'file')
                                            pre_simu = load(simucfg_file);
                                            pre_simu = pre_simu.simu;
                                            if isfield(pre_simu.config, 'timing')
                                                pre_simu.config = ...
                                                    rmfield(pre_simu.config,'timing');
                                            end

                                            if ~isequaln(simu.config, pre_simu.config)
                                                disp(simu.config)
                                                disp(pre_simu.config)
                                                disp(simu_dir)
                                                error('Different simulations config in the same folder')
                                            end 
                                            simu.sge = prev_simu.sge;
                                        end

                                        if isfield(simu, 'sge')
                                            simu.sge(end+1).job_id = job_id;
                                        else
                                            simu.sge(1).job_id = job_id;
                                        end
                                        
                                        simu.sge(end).task_id = task_id;
                                        simu.sge(end).queue = queue;
                                        simu.sge(end).host = host;
                                        
                                        save(simucfg_file, 'simu')
                                        
                                        % Simulate data only if simu_dir did not xist
                                        % before (helpful to re-run analysis on same data
                                        data_dir = fullfile(simu_dir, 'data');
                                        fisher_dir = fullfile(simu_dir, 'fishers');
                                        stouffer_dir = fullfile(simu_dir, 'stouffers');
                                        stoufferMFX_dir = fullfile(simu_dir, 'stouffersMFX');
                                        weightedZ_dir = fullfile(simu_dir, 'weightedZ');
                                        megaRFX_dir = fullfile(simu_dir, 'megaRFX');
                                        megaFFX_dir = fullfile(simu_dir, 'megaFFX');
                                        megaFFXFSL_dir = fullfile(simu_dir, 'megaFFX_FSL');
                                        megaMFX_dir = fullfile(simu_dir, 'megaMFX');
                                        permutcon_dir = fullfile(simu_dir, 'permutCon');
                                        permutz_dir = fullfile(simu_dir, 'permutZ');

                                        last_data = fullfile(data_dir, ['varcon_st' num2str((k_group1+k_group2), '%03d') '.nii']);
                                        exist_data = exist(last_data, 'file');

                                        if exist_data
                                            for iStudy = 1:(k_group1+k_group2)
                                                [~, conFiles{iStudy}] = find_file_nii_or_gz(fullfile(data_dir, ['con_st' num2str(iStudy, '%03d') '.nii']));
                                                [~, varConFiles{iStudy}] = find_file_nii_or_gz(fullfile(data_dir, ['varcon_st' num2str(iStudy, '%03d') '.nii']));
                                                [~, zFiles{iStudy}] = find_file_nii_or_gz(fullfile(data_dir, ['z_st' num2str(iStudy, '%03d') '.nii']));
                                            end
%                                             load(fullfile(simu_dir, 'simu.mat'))
%                                             fields = fieldnames(simu.config);
%                                             for f = 1:numel(fields)
%                                                 eval([fields{f} ' = ' simu.config.(fields{f})])
%                                             end
                                        else
                                            % Directory to store the simulation data.
                                            mkdir(data_dir);

                                            % --- Simulated data ---
                                            subIdx = 0;

                                            % Generate simulated data
                                            [con_files, varcon_files, z_files] = simulate_data(simu.config);

                                            if analysis_type == 1
                                                mkdir(fisher_dir);
                                                mkdir(stouffer_dir);
                                                mkdir(stoufferMFX_dir);    
                                                mkdir(weightedZ_dir);
                                            end
                                            mkdir(megaRFX_dir);
%                                             mkdir(megaFFX_dir);
                                            mkdir(permutcon_dir);                            
                                            mkdir(permutz_dir);   
                                            mkdir(megaMFX_dir);   
                                            mkdir(megaFFXFSL_dir);
                                        end  

                                        % --- Compute meta-analysis ---
                                        matlabbatch = {};
                                        
                                        if analysis_type == 1
                                            % Fisher's
                                            if ~find_file_nii_or_gz(fullfile(fisher_dir, 'fishers_ffx_minus_log10_p.nii'))
                                                matlabbatch{1}.spm.tools.ibma.fishers.dir = {fisher_dir};
                                                matlabbatch{1}.spm.tools.ibma.fishers.zimages = zFiles;
                                            else
                                                disp('Fisher''s already computed')
                                            end

                                            % Stouffer's
                                            if ~find_file_nii_or_gz(fullfile(stouffer_dir, 'stouffers_ffx_minus_log10_p.nii'))
                                                matlabbatch{end+1}.spm.tools.ibma.stouffers.dir = {stouffer_dir};
                                                matlabbatch{end}.spm.tools.ibma.stouffers.zimages = zFiles;
                                                matlabbatch{end}.spm.tools.ibma.stouffers.rfx.RFX_no = 1;
                                            else
                                                disp('Stouffer''s already computed')
                                            end

                                            % Stouffer's MFX
                                            if ~find_file_nii_or_gz(fullfile(stoufferMFX_dir, 'stouffers_rfx_minus_log10_p.nii'))
                                                matlabbatch{end+1}.spm.tools.ibma.stouffers.dir = {stoufferMFX_dir};
                                                matlabbatch{end}.spm.tools.ibma.stouffers.zimages = zFiles;
                                                matlabbatch{end}.spm.tools.ibma.stouffers.rfx.RFX_yes = 0;
                                            else
                                                disp('Stouffer''s MFX already computed')
                                            end

                                            % Optimally weighted z
                                            if ~find_file_nii_or_gz(fullfile(weightedZ_dir, 'weightedz_ffx_minus_log10_p.nii'))
                                                matlabbatch{end+1}.spm.tools.ibma.weightedz.dir = {weightedZ_dir};
                                                matlabbatch{end}.spm.tools.ibma.weightedz.zimages = zFiles;
                                                matlabbatch{end}.spm.tools.ibma.weightedz.nsub = group1_n;
                                            else
                                                disp('Weighted Z already computed')
                                            end
                                        end

                                        % Mega-analysis RFX
                                        if ~find_file_nii_or_gz(fullfile(megaRFX_dir, 'mega_rfx_minus_log10_p.nii'))
                                            if analysis_type == 1
                                                matlabbatch{end+1}.spm.tools.ibma.megarfx.dir = {megaRFX_dir};
                                                matlabbatch{end}.spm.tools.ibma.megarfx.confiles = conFiles;
                                            else
                                                matlabbatch{end+1}.spm.stats.factorial_design.dir = {megaRFX_dir};
                                                matlabbatch{end}.spm.stats.factorial_design.des.t2.scans1 = conFiles(1:k_group1)';
                                                matlabbatch{end}.spm.stats.factorial_design.des.t2.scans2 = conFiles(k_group1+(1:k_group2))';
                                                matlabbatch{end}.spm.stats.factorial_design.des.t2.variance = 0;
                                                matlabbatch{end+1}.spm.stats.fmri_est.spmmat = {fullfile(megaRFX_dir, 'SPM.mat')};
                                                matlabbatch{end+1}.spm.stats.con.spmmat = {fullfile(megaRFX_dir, 'SPM.mat')};
                                                matlabbatch{end}.spm.stats.con.consess{1}.tcon.name = 'bewteen group effect';
                                                matlabbatch{end}.spm.stats.con.consess{1}.tcon.convec = [1 -1];
                                                
                                                statFile = fullfile(megaRFX_dir, 'spmT_0001.nii');
                                                matlabbatch{end+1}.spm.util.imcalc.input = {statFile};
                                                matlabbatch{end}.spm.util.imcalc.output = 'mega_rfx_minus_log10_p.nii';
                                                matlabbatch{end}.spm.util.imcalc.outdir = {megaRFX_dir};
                            
                                                dof = k_group1+k_group2-2;
                                                matlabbatch{end}.spm.util.imcalc.expression = ['-log10(cdf(''T'',-i1, ' num2str(dof) '))'];
                                                matlabbatch{end}.spm.util.imcalc.options.dmtx = 0;
                                                matlabbatch{end}.spm.util.imcalc.options.dtype = 64;
                                            end
                                        else
                                            disp('Mega RFX already computed')
                                        end

    %                                     % Mega-analysis FFX
    %                                     if ~exist(fullfile(megaFFX_dir, 'mega_ffx_ffx_minus_log10_p.nii'), 'file')
    %                                         matlabbatch{end+1}.spm.tools.ibma.megaffx.dir = {megaFFX_dir};
    %                                         if length(unique(nsub)) == 1
    %                                             matlabbatch{end}.spm.tools.ibma.megaffx.samplesize.equal.nsub = unique(nsub);
    %                                         else
    %                                             matlabbatch{end}.spm.tools.ibma.megaffx.samplesize.unequal.nsub = nsub;
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
                                        if ~exist(fullfile(permutcon_dir, 'lP+.img'), 'file')
                                            conFiles = gunzip_if_gz(conFiles);
                                            if analysis_type == 1                                                
                                                matlabbatch{end+1}.spm.tools.snpm.des.OneSampT.DesignName = 'MultiSub: One Sample T test on diffs/contrasts';
                                                matlabbatch{end}.spm.tools.snpm.des.OneSampT.DesignFile = 'snpm_bch_ui_OneSampT';
                                                matlabbatch{end}.spm.tools.snpm.des.OneSampT.dir = {permutcon_dir};
                                                matlabbatch{end}.spm.tools.snpm.des.OneSampT.P = conFiles;
                                                matlabbatch{end+1}.spm.tools.snpm.cp.snpmcfg = {fullfile(permutcon_dir, 'SnPMcfg.mat')};
                                            else
                                                matlabbatch{end+1}.spm.tools.snpm.des.TwoSampT.dir = {permutcon_dir};
                                                matlabbatch{end}.spm.tools.snpm.des.TwoSampT.scans1 = conFiles(1:k_group1)';
                                                matlabbatch{end}.spm.tools.snpm.des.TwoSampT.scans2 = conFiles(k_group1+(1:k_group2))';
                                                matlabbatch{end+1}.spm.tools.snpm.cp.snpmcfg = {fullfile(permutcon_dir, 'SnPMcfg.mat')};
                                            end
                                        else
                                            disp('Permutation on contrast files already computed')
                                        end


                                        % Permutation on zFiles
                                        if ~exist(fullfile(permutz_dir, 'lP+.img'), 'file')
                                            zFiles = gunzip_if_gz(zFiles);
                                            if analysis_type == 1
                                                matlabbatch{end+1}.spm.tools.snpm.des.OneSampT.DesignName = 'MultiSub: One Sample T test on diffs/contrasts';
                                                matlabbatch{end}.spm.tools.snpm.des.OneSampT.DesignFile = 'snpm_bch_ui_OneSampT';
                                                matlabbatch{end}.spm.tools.snpm.des.OneSampT.dir = {permutz_dir};
                                                matlabbatch{end}.spm.tools.snpm.des.OneSampT.P = zFiles;
                                                matlabbatch{end+1}.spm.tools.snpm.cp.snpmcfg = {fullfile(permutz_dir, 'SnPMcfg.mat')};
                                            else
                                                matlabbatch{end+1}.spm.tools.snpm.des.TwoSampT.dir = {permutz_dir};
                                                matlabbatch{end}.spm.tools.snpm.des.TwoSampT.scans1 = zFiles(1:k_group1)';
                                                matlabbatch{end}.spm.tools.snpm.des.TwoSampT.scans2 = zFiles(k_group1+(1:k_group2))';
                                                matlabbatch{end+1}.spm.tools.snpm.cp.snpmcfg = {fullfile(permutz_dir, 'SnPMcfg.mat')};
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
                                            if redomfx || ~find_file_nii_or_gz(fullfile(megaMFX_dir,'mega_mfx_minus_log10_p.nii'))
                                                if ~exist('nsub', 'var')
                                                    nsub = group1_n;
                                                end
                                                run_fsl_mfx(data_dir, megaMFX_dir, analysis_type, nsub, k)
                                            else
                                                disp('Mega MFX (FSL) already computed')
                                            end
                                        end

                                        % GLM FFX (via FSL)
                                        if ~find_file_nii_or_gz(fullfile(megaFFXFSL_dir,'mega_ffx_minus_log10_p.nii'))
                                            if ~exist('nsub', 'var')
                                                    nsub = group1_n;
                                            end
                                            run_fsl_ffx(data_dir, megaFFXFSL_dir, analysis_type, nsub, k)
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

function [con_files, varcon_files, z_files] = simulate_data(config)
    num_studies = k_group1+k_group2;
    con_files = cell(num_studies, 1);
    varcon_files = cell(num_studies, 1);
    z_files = cell(num_studies, 1);

    for study_idx = 1:num_studies
        if study_idx <= k_group1
            % Group 1
            studyIndex = study_idx;
            nsub = config.group1_n;
            unitFactor = config.factor_group1;
            wth_sigma_a = config.group1_wth_sigma_a;
        else
            % Group 2
            studyIndex = study_idx-config.k_group1;
            nsub = config.group2_n;
            unitFactor = config.factor_group2;
            wth_sigma_a = config.group2_wth_sigma_a;
        end
        
        % Degrees of freedom of the within-study variance estimate
        dof = nsub(studyIndex)-1;

        % Estimated paramater estimate.
        estimatedContrast = normrnd(0, sqrt(sigma_sq*wth_sigma_a(studyIndex)./nsub(studyIndex)+btw_sigma), [iter_onedir, iter_onedir, iter_onedir]);

        % Estimated contrast variance (from chi square distribution)
        estimatedSigmaSquare = chi2rnd(dof, [iter_onedir, iter_onedir, iter_onedir])*sigma_sq*wth_sigma_a(studyIndex)/dof;
        estimatedVarContrast = estimatedSigmaSquare./nsub(studyIndex);

        % units correction
        estimatedContrast = estimatedContrast*unitFactor(studyIndex);
        estimatedVarContrast = estimatedVarContrast*(unitFactor(studyIndex)^2);

        % Write out parameter estimates.      
        con_files{study_idx} = fullfile(data_dir, ['con_st' num2str(study_idx, '%03d') '.nii']);
        vol    = struct('fname',  conFiles{study_idx},...
                   'dim',    [iter_onedir iter_onedir iter_onedir],...
                   'dt',     [spm_type('float32') spm_platform('bigend')],...
                   'mat',    eye(4),...
                   'pinfo',  [1 0 0]',...
                   'descrip','simulation');
        vol    = spm_create_vol(vol);
        spm_write_vol(vol, estimatedContrast);

        % Write out estimated variance of parameter estimates.
        varcon_files{study_idx} = fullfile(data_dir, ['varcon_st' num2str(study_idx, '%03d') '.nii']);
        vol.fname =  varConFiles{study_idx};
        spm_write_vol(vol, estimatedVarContrast);

        % Write out corresponding z-values.
        z_files{study_idx} = fullfile(data_dir, ['z_st' num2str(study_idx, '%03d') '.nii']);
        vol.fname = zFiles{study_idx};

        % Z-transform of T-statistic
        zData = norminv(cdf('T', estimatedContrast./sqrt(estimatedVarContrast), nsub(studyIndex)-1));
        infPos = find(isinf(zData(:)));

        zData(infPos) = -norminv(cdf('T', -estimatedContrast(infPos)./sqrt(estimatedVarContrast(infPos)), nsub(studyIndex)-1));
        spm_write_vol(vol, zData);   
    end 
end