function export_full_simulations(simuDir)
    simuDirs = find_dirs('^nStudy5_subNum-extreme_large', simuDir);
    
    for i = 1:numel(simuDirs)
        disp(['Exporting ' simuDirs{i}])
        filename = ['simu_all_' mat2str(i) '.csv'];
        fid = fopen(fullfile(pwd, filename), 'w');
        
        fprintf(fid, 'methods, nStudies, Between, Within, numSubjectScheme, nSimu, minuslog10P, P, rankP, expectedP \n');
        
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
        fisherFile = spm_select('FPList', fullfile(simuDirs{i}, 'fishers'), '^fishers_ffx_minus_log10_p\.nii$');
%         statVal.fishers = spm_read_vols(spm_vol(spm_select('FPList', fullfile(simuDirs{i}, 'fishers'), '^fishers_ffx_statistic.nii$')));
        pVal.fishers = spm_read_vols(spm_vol(fisherFile));
        mystr = print_pvalues('', 'fishers', pVal.fishers, info);
        
        pVal.GLMRFX = spm_read_vols(spm_vol(spm_select('FPList', fullfile(simuDirs{i}, 'megaRFX'), '^mega_rfx_minus_log10_p.nii$')));
%         statVal.GLMRFX = spm_read_vols(spm_vol(spm_select('FPList', fullfile(simuDirs{i}, 'megaRFX'), '^spmT_0001.nii$')));
        
        mystr = print_pvalues(mystr, 'GLMRFX', pVal.GLMRFX, info);
        
        pVal.PermutZ = spm_read_vols(spm_vol(spm_select('FPList', fullfile(simuDirs{i}, 'permutZ'), '^lP\+\.hdr$')));
%         statVal.PermutZ = spm_read_vols(spm_vol(spm_select('FPList', fullfile(simuDirs{i}, 'permutZ'), '^snpmT\+\.hdr$')));
        mystr = print_pvalues(mystr, 'PermutZ', pVal.PermutZ, info);
        
        pVal.PermutCon = spm_read_vols(spm_vol(spm_select('FPList', fullfile(simuDirs{i}, 'permutCon'), '^lP\+\.hdr$')));
%         statVal.PermutCon = spm_read_vols(spm_vol(spm_select('FPList', fullfile(simuDirs{i}, 'permutCon'), '^snpmT\+\.hdr$')));
        mystr = print_pvalues(mystr, 'PermutCon', pVal.PermutCon, info);
        
        pVal.GLMFFX = spm_read_vols(spm_vol(spm_select('FPList', fullfile(simuDirs{i}, 'megaFFX'), '^mega_ffx_ffx_minus_log10_p\.nii$')));
%         statVal.GLMFFX = spm_read_vols(spm_vol(spm_select('FPList', fullfile(simuDirs{i}, 'megaFFX'), '^mega_ffx_statistic\.nii$')));
        mystr = print_pvalues(mystr, 'GLMFFX', pVal.GLMFFX, info);        
        
        pVal.Stouffers = spm_read_vols(spm_vol(spm_select('FPList', fullfile(simuDirs{i}, 'stouffers'), '^stouffers_ffx_minus_log10_p\.nii$')));
%         statVal.Stouffers = spm_read_vols(spm_vol(spm_select('FPList', fullfile(simuDirs{i}, 'stouffers'), '^stouffers_ffx_statistic\.nii$')));
        mystr = print_pvalues(mystr, 'Stouffers', pVal.Stouffers, info);                
        
        pVal.StouffersMFX = spm_read_vols(spm_vol(spm_select('FPList', fullfile(simuDirs{i}, 'stouffersMFX'), '^stouffers_rfx_minus_log10_p\.nii$')));
%         statVal.StouffersMFX = spm_read_vols(spm_vol(spm_select('FPList', fullfile(simuDirs{i}, 'stouffersMFX'), '^spmT_0001\.nii$')));
        mystr = print_pvalues(mystr, 'StouffersMFX', pVal.StouffersMFX, info);                
        
        pVal.WeightedZ = spm_read_vols(spm_vol(spm_select('FPList', fullfile(simuDirs{i}, 'weightedZ'), '^weightedz_ffx_minus_log10_p\.nii$')));
%         statVal.WeightedZ = spm_read_vols(spm_vol(spm_select('FPList', fullfile(simuDirs{i}, 'weightedZ'), '^weightedz_ffx_statistic\.nii$')));        
        mystr = print_pvalues(mystr, 'WeightedZ', pVal.WeightedZ, info);                        
        
        fprintf(fid, '%s', mystr);
        fclose(fid);
    end
    
end

function mystr = print_pvalues(mystr, methodName, minuslog10pvalues, info)
    minuslog10pvalues = minuslog10pvalues(:);

    check_pvalues(methodName, minuslog10pvalues)
    pvalues = 10.^(-minuslog10pvalues);
    
    % All of this is needed instead of using just rank produced by 'order'
    % function because we need to deal with duplicate values and take
    % max(rank)
    % Need to be done on -statValue rather than pvalues to avoid scale effect
    % that should not be present in expected pvalues
    orderByValue = pvalues(:); %-statValues(:);
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
            ',' mat2str(info.nSubjectsScheme) ...
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