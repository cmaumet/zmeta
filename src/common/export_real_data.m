% Compute xx from the simulation results
%   simuDir: full path to the directory storing the simulations
%   redo: if true, overwrite previous export (default: false)
%   downs_tot: Number of points to keep after downsampling
function export_real_data(realDataDir, redo, pattern, split_in, downs_to)
    if nargin < 3
        redo = false;
    end
    if nargin < 4
        % Export all studies
        pattern = 'test';
    end    
    if nargin < 5
        % Do not split
        split_in = 1;
    end
    if nargin < 6
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
                    'pValueFile', fullfile('stats', 'mega_mfx_minus_log10_p.nii'),...
                    'statFile', 'zstat1.nii');                      
    other_methods(5) = struct( 'name', 'megaFFX', ...
                    'pValueFile', 'mega_ffx_minus_log10_p.nii',...
                    'statFile', 'zstat1.nii');             
%     other_methods(6) = struct( 'name', 'megaMFX2', ...
%                     'pValueFile', 'mega_mfx_minus_log10_p.nii',...
%                     'statFile', 'zstat1.nii');       
                
    all_methods = [one_sample_only_methods other_methods];


    disp(' Exporting ')
    
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
        
    filename = ['real' csv_suffix '.csv';];
    
    csv_file = fullfile(realDataDir, filename)
    
    % if redo || ~exist(csv_file, 'file')
        mystr = '';            
        fid = fopen(csv_file, 'w');
        fprintf(fid, ['methods, minuslog10P, P, rankP, expectedP, stat \n']);     
   
        methods = all_methods;
        
        % For each method we combine all iterations
        for m = 1:numel(methods)  
            statistic = [];
            real_pvalues = [];

            disp(['    ... ' methods(m).name ])
               
            methodDir = fullfile(realDataDir, methods(m).name);

            if isfolder(methodDir)
                regpval = ['^' regexptranslate('escape', methods(m).pValueFile) '(\.gz)?$'];
                pValueFile = spm_select('FPList', methodDir, regpval);
                if isempty(pValueFile)

                    stat_file = fullfile(methodDir, 'stats', methods(m).statFile);
                    gunzip(stat_file);
                    stat_file = strrep(stat_file, '.gz', '');
                    
                    statistic = spm_read_vols(spm_vol(stat_file));
                    
                    copyfile(stat_file, pValueFile);
                    pValueImg = nifti(pValueFile);
                    pValueImg.dat(:) = -log10(normcdf(statistic(:), 'upper'));
                end

                real_pvalues = spm_read_vols(spm_vol(pValueFile));
            else
                this_warn = ["\tMissing " methods(m).name];
                error(this_warn);
            end
        
            % Combine all iterations of this method for this simulation
            sample_size = numel(real_pvalues(:));
        
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
                    real_pvalues(start:ending), donws_pos);
                start = ending + 1;
            end
        end
        
        % A single file combining real data info
        fprintf(fid, '%s', mystr);
        fclose(fid);
        disp(['--> written in ' filename])    
    % else
    %     disp('--> already done ')
    % end
    
end

function mystr = print_pvalues(mystr, methodName, minuslog10pvalues, donws_pos)

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
     
    mystr = [mystr sprintf([methodName ...
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
       errmsg = 'err: infinite p-value';
    end
    if any(pvalues(:)==0)
        errmsg = 'err: Null p-value';
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
        disp([methodName ': ' errmsg])
    end
end
