function export_full_simulations(simuDir)
    simuDirs = find_dirs('^nStudy', simuDir);
    
    for i = 1:numel(simuDirs)
        disp(['Exporting ' simuDirs{i}])
        filename = ['simu_all_' mat2str(i) '.csv'];
        fid = fopen(fullfile(pwd, filename), 'w');
        
        fprintf(fid, 'methods, nStudies, Between, Within, numSubjectScheme, varScheme, nSimu, minuslog10P, P, rankP, expectedP \n');
        
%         info = regexp(spm_file(simuDirs{i}, 'filename'), ...
%             'nStudy(?<nStudy>\d+)_Betw(?<Betw>\d+\.?\d*)_Within(?<Within>\d+\.?\d*)_nSimu(?<nSimu>\d+)','names');
        try
            info = load(fullfile(simuDir,simuDirs{i}, 'simu.mat'));
            info = info.simu.config;
        catch
            warning(['Skipped' simuDirs{i}])
            continue;
        end
        
        simuDirs{i} = fullfile(simuDir, simuDirs{i});
        
        methods(1) = struct( 'name', 'fishers', ...
                        'pValueFile', 'fishers_ffx_minus_log10_p.nii',...
                        'statFile', 'fishers_ffx_statistic.nii');
        methods(2) = struct( 'name', 'megaRFX', ...
                        'pValueFile', 'mega_rfx_minus_log10_p.nii',...
                        'statFile', 'spmT_0001.nii');
        methods(3) = struct( 'name', 'permutZ', ...
                        'pValueFile', 'lP+.hdr',...
                        'statFile', 'snpmT+.hdr');
        methods(4) = struct( 'name', 'permutCon', ...
                        'pValueFile', 'lP+.hdr',...
                        'statFile', 'snpmT+.hdr');
        methods(5) = struct( 'name', 'megaFFX', ...
                        'pValueFile', 'mega_ffx_ffx_minus_log10_p.nii',...
                        'statFile', 'mega_ffx_statistic.nii');                    
        methods(6) = struct( 'name', 'stouffers', ...
                        'pValueFile', 'stouffers_ffx_minus_log10_p.nii',...
                        'statFile', 'stouffers_ffx_statistic.nii');                      
        methods(7) = struct( 'name', 'stouffersMFX', ...
                        'pValueFile', 'stouffers_rfx_minus_log10_p.nii',...
                        'statFile', 'spmT_0001.nii');                      
        methods(8) = struct( 'name', 'weightedZ', ...
                        'pValueFile', 'weightedz_ffx_minus_log10_p.nii',...
                        'statFile', 'weightedz_ffx_statistic.nii');                      
        mystr = '';
        for m = 1:numel(methods)
            methodDir = fullfile(simuDirs{i}, methods(m).name);
            pValueFile = spm_select('FPList', methodDir, ...
                ['^' regexptranslate('escape', methods(m).pValueFile) '$']);
            pValues = spm_read_vols(spm_vol(pValueFile));
            statFile = spm_select('FPList', methodDir, ...
                ['^' regexptranslate('escape', methods(m).statFile) '$']);
            statistic = spm_read_vols(spm_vol(statFile));
            mystr = print_pvalues(mystr, methods(m).name, pValues, statistic(:), info);
        end
                    
%         fisherFile = spm_select('FPList', fullfile(simuDirs{i}, 'fishers'), '^fishers_ffx_minus_log10_p\.nii$');
% %         statVal.fishers = spm_read_vols(spm_vol(spm_select('FPList', fullfile(simuDirs{i}, 'fishers'), '^fishers_ffx_statistic.nii$')));
%         pVal.fishers = spm_read_vols(spm_vol(fisherFile));
%         mystr = print_pvalues('', 'fishers', pVal.fishers, info);
%         
%         pVal.GLMRFX = spm_read_vols(spm_vol(spm_select('FPList', fullfile(simuDirs{i}, 'megaRFX'), '^mega_rfx_minus_log10_p.nii$')));
% %         statVal.GLMRFX = spm_read_vols(spm_vol(spm_select('FPList', fullfile(simuDirs{i}, 'megaRFX'), '^spmT_0001.nii$')));
%         
%         mystr = print_pvalues(mystr, 'GLMRFX', pVal.GLMRFX, info);
%         
%         pVal.PermutZ = spm_read_vols(spm_vol(spm_select('FPList', fullfile(simuDirs{i}, 'permutZ'), '^lP\+\.hdr$')));
% %         statVal.PermutZ = spm_read_vols(spm_vol(spm_select('FPList', fullfile(simuDirs{i}, 'permutZ'), '^snpmT\+\.hdr$')));
%         mystr = print_pvalues(mystr, 'PermutZ', pVal.PermutZ, info);
%         
%         pVal.PermutCon = spm_read_vols(spm_vol(spm_select('FPList', fullfile(simuDirs{i}, 'permutCon'), '^lP\+\.hdr$')));
% %         statVal.PermutCon = spm_read_vols(spm_vol(spm_select('FPList', fullfile(simuDirs{i}, 'permutCon'), '^snpmT\+\.hdr$')));
%         mystr = print_pvalues(mystr, 'PermutCon', pVal.PermutCon, info);
%         
%         pVal.GLMFFX = spm_read_vols(spm_vol(spm_select('FPList', fullfile(simuDirs{i}, 'megaFFX'), '^mega_ffx_ffx_minus_log10_p\.nii$')));
% %         statVal.GLMFFX = spm_read_vols(spm_vol(spm_select('FPList', fullfile(simuDirs{i}, 'megaFFX'), '^mega_ffx_statistic\.nii$')));
%         mystr = print_pvalues(mystr, 'GLMFFX', pVal.GLMFFX, info);        
%         
%         pVal.Stouffers = spm_read_vols(spm_vol(spm_select('FPList', fullfile(simuDirs{i}, 'stouffers'), '^stouffers_ffx_minus_log10_p\.nii$')));
% %         statVal.Stouffers = spm_read_vols(spm_vol(spm_select('FPList', fullfile(simuDirs{i}, 'stouffers'), '^stouffers_ffx_statistic\.nii$')));
%         mystr = print_pvalues(mystr, 'Stouffers', pVal.Stouffers, info);                
%         
%         pVal.StouffersMFX = spm_read_vols(spm_vol(spm_select('FPList', fullfile(simuDirs{i}, 'stouffersMFX'), '^stouffers_rfx_minus_log10_p\.nii$')));
% %         statVal.StouffersMFX = spm_read_vols(spm_vol(spm_select('FPList', fullfile(simuDirs{i}, 'stouffersMFX'), '^spmT_0001\.nii$')));
%         mystr = print_pvalues(mystr, 'StouffersMFX', pVal.StouffersMFX, info);                
%         
%         pVal.WeightedZ = spm_read_vols(spm_vol(spm_select('FPList', fullfile(simuDirs{i}, 'weightedZ'), '^weightedz_ffx_minus_log10_p\.nii$')));
% %         statVal.WeightedZ = spm_read_vols(spm_vol(spm_select('FPList', fullfile(simuDirs{i}, 'weightedZ'), '^weightedz_ffx_statistic\.nii$')));        
%         mystr = print_pvalues(mystr, 'WeightedZ', pVal.WeightedZ, info);                        
        
        fprintf(fid, '%s', mystr);
        fclose(fid);
    end
    
end

function mystr = print_pvalues(mystr, methodName, minuslog10pvalues, statValue, info)
    minuslog10pvalues = minuslog10pvalues(:);

    check_pvalues(methodName, minuslog10pvalues)
    pvalues = 10.^(-minuslog10pvalues);
    
    % All of this is needed instead of using just rank produced by 'order'
    % function because we need to deal with duplicate values and take
    % max(rank)
    % Need to be done on -statValue rather than pvalues to avoid scale effect
    % that should not be present in expected pvalues
    orderByValue = -statValue(:); %pvalues(:); %-statValues(:);
    [~, ~, statValuesIdx] = unique(orderByValue(:));
    uniqueStatValuesRank = cumsum(accumarray(statValuesIdx, ones(size(orderByValue(:)))));
    pvalues_rank = uniqueStatValuesRank(statValuesIdx);
    
    expected_p = pvalues_rank./(info.nSimuOneDir^3);
    
    % Downsampling    
    digits=2;
    roundedlog10expectedp = round(-log10(expected_p)*10^digits)/(10^digits);
    [~, uniquePositions] = unique(roundedlog10expectedp);
    
    minuslog10pvalues = minuslog10pvalues(uniquePositions);
    pvalues = pvalues(uniquePositions);
    pvalues_rank = pvalues_rank(uniquePositions);
    expected_p = expected_p(uniquePositions);
    
    data_to_export = num2cell([minuslog10pvalues, pvalues, pvalues_rank expected_p], 2);

    mystr = [mystr sprintf([methodName ',' mat2str(info.nStudies) ',' ...
                mat2str(info.sigmaBetweenStudies) ',' mat2str(info.sigmaSquare) ...
            ',' info.nSubjectsScheme ...
            ',' info.studyVarianceScheme ...
            ',' mat2str(info.nSimuOneDir^3) ',%i,%i,%i,%i\n'], ...
          data_to_export{:} )];
end

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