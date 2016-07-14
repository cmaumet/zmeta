function meta_sim(base_dir, redo, path_to_spm)
    % META_SIM  Simulate meta-analyses results under the null
    %   META_SIM(base_dir, REDO) Create simulation results in a 
    %       'simulations' folder under base_dir. Overwrite existing
    %       simulations only if REDO is 'true'.
    % 
    if ~exist('redo', 'var')
        redo = false;
    end
    
    % SPM is required to write-out NIfTI images    
    if isempty(which('spm'))
        addpath(path_to_spm)
    end
    addpath(fullfile(pwd, 'lib'))    
    
    script_dir = fileparts(mfilename('fullpath'));
    fsl_designs_dir = fullfile(script_dir, 'fsl_designs');
    
    % ----- Simulation parameters --------
    avg_n = 20; % Average number of subjects per group
    diff_n = 15;

    settings.ks = [25];% 50];%[5 10 25 50];
    settings.wth_sigmas = avg_n*[0.25 0.5 1 2 4];%How to compute z with var = 0?
    settings.wth_sigma_sames = [true]; %, 'diff'}; don't know yet how to deal with uneq var (for FFX!?)

    % Between-studies variance (RFX?)
    settings.btw_sigmas = [1];%  1];

    % Number of subjects per studies     
    settings.same_ns = [true];%[ true false];

    % Proportion of studies with software 2 (fraction)
    settings.soft_props = [1/5 0.5];

    % Correction factor with software 2
    settings.soft_factors = [2 100];

    % Study-specific bias due to units mismatch
    settings.unit_mismatches = {'nominal', 'data_sc', 'con_sc'};

    % Type of analysis: one-sample (1), two-sample(2), two-sample
    % unbalanced (3)
    settings.analysis_types = [1, 2, 3];% [1 2 3];

    % Size of the simulation image (in 1 direction). Each voxel of the
    % simulation image is a simulation sample.
    settings.iter_onedir = 30;%100;
    settings.nsimu = settings.iter_onedir^3;

    % Number of subject per study
    %     nSubjects = [25 400 100 25]; %[10, 15, 20, 25, 30, 10, 15, 20, 25, 30, 10, 15, 20, 25, 30];
    %     nStudies = numel(nSubjects);
    
    settings.nperm = 20;
    
    display_settings(settings)
    
    % -------------------------------------------
    
    % Retreive information about current job on the cluster    
    task_id_str = getenv('SGE_TASK_ID');
    job_id = getenv('JOB_ID');
    queue = getenv('QUEUE');
    host = getenv('HOSTNAME');

    if isempty(task_id_str) && isempty(job_id) && isempty(queue) ...
            && isempty(host)
        disp('This simulation is run locally')
        cluster = false;
        rng_seed = 'default';
    else
        cluster = true;
        task_id = str2num(task_id_str);
        rng_seed = task_id;
        disp('This simulation is run on a cluster')
        disp(['This is run ' task_id_str])
        disp(['This is job ' job_id])
    end

    % SPM and FSL initialisations    
    spm_jobman('initcfg');
    set_fsl_env()
    
    % Initialise random number generator using the task id
    rng(rng_seed);
       
    allsimu_dir = fullfile(base_dir, 'simulations');
    if ~isdir(allsimu_dir)
        mkdir(allsimu_dir)
    end
     
    % Number of studies per meta-analysis
    for k = settings.ks
        
        % One-sample, two-sample, two-sample unbalanced
        for analysis_type = settings.analysis_types
            if analysis_type == 1
                analysisPrefix = 'test1_';
                k_group1 = k;
                k_group2 = 0;
            elseif analysis_type == 2
                analysisPrefix = 'test2_';
                k_group1 = k;
                k_group2 = k;
            elseif analysis_type == 3
                analysisPrefix = 'test3_';
                k_group1 = k*2*4/5;
                k_group2 = k*2/5;
            end

            % Cross-studies unit mismatch
            for unit_mis = settings.unit_mismatches
                unit_mis = unit_mis{1};
                
                options = struct();
                switch unit_mis
                    case {'nominal'}
                        options(1).none = 1;
                    case {'data_sc'}
                        i = 1;
                        for factor = settings.soft_factors
                            for prop = settings.soft_props
                                options(i).factor = factor;
                                options(i).prop = prop;
                                i = i + 1;
                            end
                        end
                    case {'con_sc'}
                        options(1).none = 1;
                    otherwise
                        error('Unknow unit mismatch')
                end

                % Options specific to the different unit mismatch options
                for opt = 1:numel(options)
                    switch unit_mis
                        case {'nominal'}
                            factor_group1 = ones(1, k_group1);
                            factor_group2 = ones(1, k_group2);
                            
                            soft_prop = 0;
                            soft_factor = 1;
                            
                            opt_str = '';
                            
                        case {'data_sc'}
                            factor_group1 = ones(1, k_group1);
                            factor_group2 = ones(1, k_group2);
                                                       
                            soft_prop = options(opt).prop;
                            soft_factor = options(opt).factor;
                            
                            opt_str = ['_soft' ...
                                       num2str(soft_prop*100, '%02.0f') ...
                                       '_' num2str(soft_factor, '%03.0f')];
                            
                        case {'con_sc'}
                            % Uniformly distributed beween 0.4 and 1.6 
                            % included, so that mean(unitFactor) = 1 and 
                            % 1.6/0.4=4
                            factor_group1 = randi([1 4], 1, k_group1)/2.5;%linspace(avg_n/2,avg_n*2,k);
                            factor_group2 = randi([1 4], 1, k_group2)/2.5;
                            
                            soft_prop = 0;
                            soft_factor = 1;
                            
                            opt_str = '';

                        otherwise
                            error('Unknow unit mismatch')
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

                    for same_n = settings.same_ns

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

                        % Between-studies variance
                        for btw_sigma = settings.btw_sigmas

                             % Within-study variance (ignoring sample
                             % size)
                             for sigma_sq = settings.wth_sigmas
                                for wth_sigma_same = settings.wth_sigma_sames

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
                                        '_wth' num2str(sigma_sq, '%02.0f'), opt_str, '_', num2str(unit_mis)];
                                    simu_dir = fullfile(allsimu_dir, simu_name);
                                    if cluster
                                        simu_dir = fullfile(simu_dir, num2str(task_id, '%04d'));
                                    end

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
                                        simu.config.n = group1_n + group2_n;
                                    else
                                        simu.config.group1_n = group1_n;
                                        simu.config.n = group1_n;
                                    end
                                    simu.config.wth_sigma_same = wth_sigma_same;

                                    if analysis_type > 1
                                        simu.config.k_group1 = k_group1;
                                        simu.config.k_group2 = k_group2;
                                        simu.config.k = k_group1 + k_group2;
                                        simu.config.group1_wth_sigma_a = group1_wth_sigma_a;
                                        simu.config.group2_wth_sigma_a = group2_wth_sigma_a;
                                    else
                                        simu.config.k = k_group1;
                                        simu.config.k_group1 = k_group1;
                                        simu.config.wth_sigma_a = group1_wth_sigma_a;
                                        simu.config.group1_wth_sigma_a = group1_wth_sigma_a;
                                    end
                                    simu.config.sigma_sq = sigma_sq;
                                    simu.config.btw_sigma = btw_sigma;
                                    simu.config.iter_onedir = settings.iter_onedir;
                                    simu.config.soft_prop = soft_prop;
                                    simu.config.soft_factor = soft_factor;
                                    simu.config.unit_mis = unit_mis;
                                    simu.config.factor_group1 = factor_group1;
                                    simu.config.factor_group2 = factor_group2;
                                    simu.config.analysis_type = analysis_type;

                                    simucfg_file = fullfile( ...
                                        simu_dir, 'simu.mat');
                                    
                                    simu.config = orderfields(simu.config);

                                    if exist(simucfg_file, 'file')
                                        prev_simu = load(simucfg_file);
                                        prev_simu = orderfields(prev_simu.simu);
                                        if isfield(prev_simu.config, 'timing')
                                            prev_simu.config = ...
                                                rmfield(prev_simu.config,'timing');
                                        end

                                        if ~isequaln(simu.config, prev_simu.config)
                                            disp(simu.config)
                                            disp('---')
                                            disp(prev_simu.config)
                                            disp('---')
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

                                    simu.sge(end).task_id_str = task_id_str;
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
                                        con_files = cell(k,1);
                                        varcon_files = cell(k,1);
                                        z_files = cell(k,1);
                                        for iStudy = 1:(k_group1+k_group2)
                                            [~, con_files{iStudy}] = exist_nii(fullfile(data_dir, ['con_st' num2str(iStudy, '%03d') '.nii']), true);
                                            [~, varcon_files{iStudy}] = exist_nii(fullfile(data_dir, ['varcon_st' num2str(iStudy, '%03d') '.nii']), true);
                                            [~, z_files{iStudy}] = exist_nii(fullfile(data_dir, ['z_st' num2str(iStudy, '%03d') '.nii']), true);
                                        end
                                    else
                                        % Directory to store the simulation data.
                                        if ~isdir(data_dir)
                                            mkdir(data_dir);
                                        end

                                        % --- Simulated data ---
                                        % Generate simulated data
                                        [con_files, varcon_files, z_files] = simulate_data(simu.config, data_dir);

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

                                    if analysis_type == 1
                                        % Fisher's
                                        run_fishers(fisher_dir, z_files)

                                        % FFX Stouffer's
                                        run_stouffers(stouffer_dir, z_files, false)

                                        % Stouffer's MFX
                                        run_stouffers(stouffer_dir, z_files, true)

                                        % Optimally weighted z
                                        run_weighted_z(weightedZ_dir, z_files, group1_n)
                                    end


                                    if analysis_type == 1
                                        % Mega-analysis RFX
                                        run_mega_rfx(megaRFX_dir, con_files)

                                        % Permutation on con_files
                                        run_permut_con(permutcon_dir, settings.nperm, con_files)

                                        % Permutation on z_files
                                        run_permut_z(permutz_dir, settings.nperm, z_files)
                                    else
                                        % Mega-analysis RFX
                                        run_mega_rfx(megaRFX_dir, con_files(1:k_group1)', con_files(k_group1+(1:k_group2))')

                                        % Permutation on con_files
                                        run_permut_con(permutcon_dir, settings.nperm, con_files(1:k_group1)', con_files(k_group1+(1:k_group2))')

                                        % Permutation on z_files
                                        run_permut_z(permutz_dir, settings.nperm, z_files(1:k_group1)', z_files(k_group1+(1:k_group2))')
                                    end

                                    % GLM MFX
                                    run_mega_mfx(data_dir, megaMFX_dir, analysis_type, simu.config.n, k, fsl_designs_dir)

                                    % GLM FFX (via FSL)
                                    run_mega_ffx(data_dir, megaFFXFSL_dir, analysis_type, simu.config.n, k, fsl_designs_dir)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

function [con_files, varcon_files, z_files] = simulate_data(config, data_dir)
    num_studies = config.k;
    con_files = cell(num_studies, 1);
    varcon_files = cell(num_studies, 1);
    z_files = cell(num_studies, 1);

    for study_idx = 1:num_studies
        if study_idx <= config.k_group1
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
        dof = config.n(studyIndex)-1;

        % Estimated paramater estimate.
        estimatedContrast = normrnd(0, sqrt(config.sigma_sq*wth_sigma_a(studyIndex)./config.n(studyIndex)+config.btw_sigma), [config.iter_onedir, config.iter_onedir, config.iter_onedir]);

        % Estimated contrast variance (from chi square distribution)
        estimatedSigmaSquare = chi2rnd(dof, [config.iter_onedir, config.iter_onedir, config.iter_onedir])*config.sigma_sq*wth_sigma_a(studyIndex)/dof;
        estimatedVarContrast = estimatedSigmaSquare./config.n(studyIndex);

        % units correction
        estimatedContrast = estimatedContrast*unitFactor(studyIndex);
        estimatedVarContrast = estimatedVarContrast*(unitFactor(studyIndex)^2);

        % Write out parameter estimates.      
        con_files{study_idx} = fullfile(data_dir, ['con_st' num2str(study_idx, '%03d') '.nii']);
        vol    = struct('fname',  con_files{study_idx},...
                   'dim',    [config.iter_onedir config.iter_onedir config.iter_onedir],...
                   'dt',     [spm_type('float32') spm_platform('bigend')],...
                   'mat',    eye(4),...
                   'pinfo',  [1 0 0]',...
                   'descrip','simulation');
        vol    = spm_create_vol(vol);
        spm_write_vol(vol, estimatedContrast);

        % Write out estimated variance of parameter estimates.
        varcon_files{study_idx} = fullfile(data_dir, ['varcon_st' num2str(study_idx, '%03d') '.nii']);
        vol.fname =  varcon_files{study_idx};
        spm_write_vol(vol, estimatedVarContrast);

        % Write out corresponding z-values.
        z_files{study_idx} = fullfile(data_dir, ['z_st' num2str(study_idx, '%03d') '.nii']);
        vol.fname = z_files{study_idx};

        % Z-transform of T-statistic
        zData = norminv(cdf('T', estimatedContrast./sqrt(estimatedVarContrast), nsub(studyIndex)-1));
        infPos = find(isinf(zData(:)));

        zData(infPos) = -norminv(cdf('T', -estimatedContrast(infPos)./sqrt(estimatedVarContrast(infPos)), nsub(studyIndex)-1));
        spm_write_vol(vol, zData);   
    end 
end