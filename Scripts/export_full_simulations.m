function export_full_simulations(simuDir)
    simuDirs = find_dirs('^nStudy', simuDir);
    
    for i = 1:numel(simuDirs)
        i
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
        pVal.fishers = spm_read_vols(spm_vol(fisherFile));
        if any(isinf(pVal.fishers(:)))
            error('infinite pvals')
        end
        
%         if any(isinf(pVal.fishers(:)))
%             % Get the probability
%             copy_nii_image(fisherFile, add_suffix_to_file_name(fisherFile, '_ORIGINAL'));
%             statFile = spm_select('FPList', fullfile(simuDirs{i}, 'fishers'), '^fishers_ffx_statistic');
%             
%             matlabbatch{1}.spm.util.imcalc.input = {statFile};
%             matlabbatch{1}.spm.util.imcalc.output = ['fishers_ffx_minus_log10_p.nii'];
%             matlabbatch{1}.spm.util.imcalc.outdir = {spm_file(statFile, 'path')};
%             nStudies = regexp(simuDirs{i}, 'nStudy(\d+)', 'tokens');
%             nStudies = nStudies{1}{1}
%             
%             matlabbatch{1}.spm.util.imcalc.expression = ['-log10(cdf(''chi2'',i1, 2*' num2str(nStudies) ', ''upper''))'];
%             matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
%             matlabbatch{1}.spm.util.imcalc.options.dtype = 64;
%             spm_jobman('run', matlabbatch)
% 
%             fisherFile = spm_select('FPList', spm_file(statFile, 'path'), '^fishers_ffx_minus_log10_p\.nii$');
%             pVal.fishers = spm_read_vols(spm_vol(fisherFile));
%             if any(isinf(pVal.fishers(:)))
%                 error('infinite pvals')
%             end
%         end
        mystr = print_pvalues('', 'fishers', pVal.fishers, info);
        
        pVal.GLMRFX = spm_read_vols(spm_vol(spm_select('FPList', fullfile(simuDirs{i}, 'megaRFX'), '^mega_rfx_minus_log10_p')));
        mystr = print_pvalues(mystr, 'GLMRFX', pVal.GLMRFX, info);
        
        pVal.PermutZ = spm_read_vols(spm_vol(spm_select('FPList', fullfile(simuDirs{i}, 'permutZ'), '^lP\+\.hdr$')));
        mystr = print_pvalues(mystr, 'PermutZ', pVal.PermutZ, info);
        
        pVal.PermutCon = spm_read_vols(spm_vol(spm_select('FPList', fullfile(simuDirs{i}, 'permutCon'), '^lP\+\.hdr$')));
        mystr = print_pvalues(mystr, 'PermutCon', pVal.PermutCon, info);
        
        pVal.GLMFFX = spm_read_vols(spm_vol(spm_select('FPList', fullfile(simuDirs{i}, 'megaFFX'), '^mega_ffx_ffx_minus_log10_p\.nii$')));
        mystr = print_pvalues(mystr, 'GLMFFX', pVal.GLMFFX, info);        
        
        pVal.Stouffers = spm_read_vols(spm_vol(spm_select('FPList', fullfile(simuDirs{i}, 'stouffers'), '^stouffers_ffx_minus_log10_p\.nii$')));
        mystr = print_pvalues(mystr, 'Stouffers', pVal.Stouffers, info);                
        
        pVal.StouffersMFX = spm_read_vols(spm_vol(spm_select('FPList', fullfile(simuDirs{i}, 'stouffersMFX'), '^stouffers_rfx_minus_log10_p\.nii$')));
        mystr = print_pvalues(mystr, 'StouffersMFX', pVal.StouffersMFX, info);                
        
        pVal.WeightedZ = spm_read_vols(spm_vol(spm_select('FPList', fullfile(simuDirs{i}, 'weightedZ'), '^weightedz_ffx_minus_log10_p\.nii$')));
        mystr = print_pvalues(mystr, 'WeightedZ', pVal.WeightedZ, info);                        
        
        fprintf(fid, '%s', mystr);
        fclose(fid);
    end
    
end

function mystr = print_pvalues(mystr, methodName, minuslog10pvalues, info)
    minuslog10pvalues = minuslog10pvalues(:);

    check_pvalues(methodName, minuslog10pvalues)
    pvalues = 10.^(-minuslog10pvalues);
    [~, ~, pvalues_rank] = unique(pvalues);
    expected_p = pvalues_rank./(info.nSimuOneDir^3);
    
    % Downsampling    
    digits=2;
    roundedlog10p = round(minuslog10pvalues*10^digits)/(10^digits);
    [~, uniquePositions] = unique(roundedlog10p);
    
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