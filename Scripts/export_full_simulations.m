% Compute xx from the simulation results
%   simuDir: full path to the directory storing the simulations
%   redo: if true, overwrite previous export (default: false)
%   downs_tot: Number of points to keep after downsampling
function export_full_simulations(simuDir, redo, pattern, split_in, downs_to)
    if nargin < 2
        redo = false;
    end
    if nargin < 3
        % Export all studies
        pattern = '^(two_|two_unb_|)nStudy';
    end    
    if nargin < 4
        % Do not split
        split_in = 1;
    end
    if nargin < 5
        % Downsample to xx points
        downs_to = 1000;
    end    
    
    if split_in == 1
        downs_tot = downs_to;
    elseif split_in == 10
        downs_tot = 10;
    else
        downs_tot = downs_to/(split_in*10);
    end

    donws_pos = [];
    
%     simuDirs = find_dirs(, simuDir);
    simuDirs = dir(fullfile(simuDir, [pattern '*']));

    % p-value and stat file names for each method
    one_sample_only_methods(1) = struct( 'name', 'fishers', ...
                    'pValueFile', 'fishers_ffx_minus_log10_p.nii',...
                    'statFile', 'fishers_ffx_statistic.nii');
    other_methods(1) = struct( 'name', 'megaRFX', ...
                    'pValueFile', 'mega_rfx_minus_log10_p.nii',...
                    'statFile', 'spmT_0001.nii');
    other_methods(2) = struct( 'name', 'permutZ', ...
                    'pValueFile', 'lP+.img',...
                    'statFile', 'snpmT+.hdr');
    other_methods(3) = struct( 'name', 'permutCon', ...
                    'pValueFile', 'lP+.img',...
                    'statFile', 'snpmT+.img');
%             methods(5) = struct( 'name', 'megaFFX', ...
%                             'pValueFile', 'mega_ffx_ffx_minus_log10_p.nii',...
%                             'statFile', 'mega_ffx_statistic.nii');                    
    one_sample_only_methods(2) = struct( 'name', 'stouffers', ...
                    'pValueFile', 'stouffers_ffx_minus_log10_p.nii',...
                    'statFile', 'stouffers_ffx_statistic.nii');                      
    one_sample_only_methods(3) = struct( 'name', 'stouffersMFX', ...
                    'pValueFile', 'stouffers_rfx_minus_log10_p.nii',...
                    'statFile', 'spmT_0001.nii');                      
    one_sample_only_methods(4) = struct( 'name', 'weightedZ', ...
                    'pValueFile', 'weightedz_ffx_minus_log10_p.nii',...
                    'statFile', 'weightedz_ffx_statistic.nii');                      
    other_methods(4) = struct( 'name', 'megaMFX', ...
                    'pValueFile', 'mega_mfx_minus_log10_p.nii',...
                    'statFile', 'zstat1.nii');                      
    other_methods(5) = struct( 'name', 'megaFFX_FSL', ...
                    'pValueFile', 'mega_ffx_minus_log10_p.nii',...
                    'statFile', 'zstat1.nii');             
%     other_methods(6) = struct( 'name', 'megaMFX2', ...
%                     'pValueFile', 'mega_mfx_minus_log10_p.nii',...
%                     'statFile', 'zstat1.nii');       
                
    all_methods = [one_sample_only_methods other_methods];
    
%     saveSimuCsvDir = fullfile(simuDir, 'csv_tom');
    num_simu = numel(simuDirs);
    disp([num2str(num_simu) ' simulations']);
    
    for s = numel(simuDirs):-1:1
        skip = false;
        
        iter_dirs = dir(fullfile(simuDir, simuDirs(s).name, '0*'));
        
        num_iter = numel(iter_dirs);
        
        if split_in == 10
            csv_suffix = '_wrep';
        elseif split_in == 1
            csv_suffix = '';
        else
            csv_suffix = ['_wrep_' num2str(split_in)];
        end
        if downs_tot ~= 1000
            csv_suffix = [csv_suffix '_' num2str(downs_tot)];
        end
            
        filename = ['simu' csv_suffix '.csv';];
        
        main_simu_dir = fullfile(simuDir, simuDirs(s).name);
        simu_file = fullfile(main_simu_dir, filename);
        
        if redo || ~exist(simu_file, 'file')
            mystr = '';            
            fid = fopen(simu_file, 'w');
            fprintf(fid, ['methods, glm, nStudies, nSubjects, Between, Within, '...
                'nSubjectsSame, withinVariation, unitMism, soft2, soft2Factor, ' ... 
                'nSimu, minuslog10P, P, rankP, '...
                'expectedP \n']);
                ...'unitMismatch, nSimu, minuslog10P, P, rankP, '...     

            % Read info from first analysis to check if one-sample
            first_simu_dir = fullfile(main_simu_dir, iter_dirs(1).name);
            first_simu_mat_file = fullfile(first_simu_dir, 'simu.mat');
            first_info = load(first_simu_mat_file);
            first_info = first_info.simu.config;
           
            if first_info.analysis_type ~= 1
                methods = other_methods;
            else
                methods = all_methods;
            end            
            
            % For each method we combine all iterations
            for m = 1:numel(methods)  
                statistic = [];
                pvalues = [];
                
                for it = 1:num_iter   
                    this_simu_dir = fullfile(main_simu_dir, iter_dirs(it).name);         

            %         info = regexp(spm_file(this_simu_dir, 'filename'), ...
            %             'nStudy(?<nStudy>\d+)_Betw(?<Betw>\d+\.?\d*)_Within(?<Within>\d+\.?\d*)_nSimu(?<nSimu>\d+)','names');
                    try
                        simu_mat_file = fullfile(this_simu_dir, 'simu.mat');
                        info = load(simu_mat_file);
                        info = info.simu.config;
                    catch
                        warning(['Skipped' this_simu_dir])
                        if exist(simu_file, 'file')
                            delete(simu_file)
                        end
                        continue;
                    end             
                    methodDir = fullfile(this_simu_dir, methods(m).name);

                    if isdir(methodDir)
                        pValueFile = spm_select('FPList', methodDir, ...
                            ['^' regexptranslate('escape', methods(m).pValueFile) '(\.gz)?$']);
                        if isempty(pValueFile)
                            warning(['pValueFile not found for ' methodDir])
                            skip = true;
                            if exist(simu_file, 'file')
                                delete(simu_file)
                            end
                            continue;
                        end

                        iter_pval = spm_read_vols(spm_vol(pValueFile));

                        pvalues = [pvalues iter_pval(:)];
                    else
                        warning(['Missing ' methods(m).name ...
                                     ' for ' this_simu_dir])
                    end
                end
                if skip
                    continue;
                end
                
                disp([num2str(num_simu-s+1, '%03d') ...
                     '.' methods(m).name ' Exporting ' main_simu_dir])
                % Combine all iterations of this method for this simulation
                
                sample_size = numel(pvalues(:));
                if exist('prev_sample_size', 'var') && ...
                        sample_size ~= prev_sample_size
                    if sample_size < prev_sample_size
                        warning(['Incomplete simulation: ' simu_file])
                    else
                        warning('Different sample size for this simulation');
                    end
                    delete(simu_file)
                    continue;
                else
                    prev_sample_size = sample_size;
                end
                
                % Split in equal folds
                bin_size = sample_size/split_in;
                
                % We want to keep the same downsampling for all simulations
                % and methods
                if isempty(donws_pos)
                    if downs_tot > bin_size
                        error(['can''t downsize to ' num2str(downs_tot) ...
                            '(bin_size is ' ...
                            num2str(bin_size) ')'])
                    end
                    % downsample in log-space so that we keep more values 
                    % corresponding to smaller ranks/p-values                    
                    donws_pos = unique(round(...
                        logspace(0,log10(bin_size), downs_tot)));
                end
                
                start = 1;
                for spl = 1:split_in
                    ending = start + bin_size -1; 
                    mystr = print_pvalues(mystr, methods(m).name, ...
                        pvalues(start:ending), info, donws_pos);
                    start = ending + 1;
                end
            end
            
            % A single file combining all iterations for this simulation
            fprintf(fid, '%s', mystr);
            fclose(fid);
            disp(['Written ' main_simu_dir])            
        end
    end
    
end

function mystr = print_pvalues(mystr, methodName, minuslog10pvalues, ...
    info, donws_pos)

    minuslog10pvalues = minuslog10pvalues(:);

    % Return an error if null of infinite p-value is found
    check_pvalues(methodName, minuslog10pvalues)
    
    % Get p-values from -log10(p-values)
    pvalues = 10.^(-minuslog10pvalues);

    % Sorted p-values
    pvalues = sort(pvalues);
    
    sample_size = numel(pvalues);
      
    expected_p = [(1:sample_size)./sample_size]';
    pvalues_rank = [(1:sample_size)]';
     
    % Downsampling pvalues_rank so that we keep more precision for smaller
    % p-values
       
    downs_pvalues_rank = pvalues_rank(donws_pos);
    downs_expected_p = expected_p(donws_pos);
    downs_pvalues = pvalues(donws_pos);
    
    downs_minuslog10pvalues = -log10(downs_pvalues);
       
    data_to_export = num2cell([downs_minuslog10pvalues, downs_pvalues, downs_pvalues_rank, downs_expected_p], 2);
%     data_to_export = num2cell([minuslog10pvalues, pvalues, pvalues_rank expected_p], 2);
     
    if info.wth_sigma_variation == 1
        within = info.sigma_sq;
    else
        % For one-sample analyses, there is no 'group2_wth_sigma_a' field
        if ~isfield(info, 'group2_wth_sigma_a')
            info.group2_wth_sigma_a = [];
        end
        within = mean(repmat(info.sigma_sq, 1, info.k).*[...
            info.group1_wth_sigma_a, info.group2_wth_sigma_a]);
    end
    
    if ~isfield(info, 'n')
        info.n = [info.group1_n, info.group2_n];
    end
    n = mean(info.n);

    mystr = [mystr sprintf([methodName ...
            ',' mat2str(info.analysis_type) ...
            ',' mat2str(info.k) ...
            ',' num2str(n) ...
            ',' mat2str(info.btw_sigma) ',' mat2str(within) ...
            ',' num2str(info.same_n) ...
            ',' num2str(info.wth_sigma_variation) ...
            ',' info.unit_mis ...
            ',' mat2str(info.soft_prop) ...
            ',' mat2str(info.soft_factor) ...
            ',' mat2str(sample_size) ...
            ',%i,%i,%i,%i\n'], ...            
            data_to_export{:} )];
%             ',' mat2str(info.nSimuOneDir^3) ',%i,%i,%i,%i,%i\n'], ...
          
      
    if isempty(mystr)
        error('empty mystr')
    end
end

% Return an error if null of infinite p-value is found
function check_pvalues(methodName, pvalues)
    pvalues = 10.^(-pvalues);
    errmsg = '';
    if any(isinf(pvalues(:)))
       errmsg = 'infinite p-value';
    end
    if any(pvalues(:)==0)
        errmsg = 'Null p-value';
    end
%     if any(pvalues(:)==1) && ~strcmp(methodName, 'PermutZ') ...
%             && ~strcmp(methodName, 'PermutCon') ...
%             && ~strcmp(methodName, 'fishers') ...
%             && ~strcmp(methodName, 'GLMFFX')
%             % fishers, GLMFFX: 1 - 10^-18 = 1...            
%             % perm: ok to have 1             
%         errmsg = 'P-value equal to 1';
%     end
    if ~isempty(errmsg)
        error([methodName ': ' errmsg])
    end
end