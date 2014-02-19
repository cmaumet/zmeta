function scatterplot_variances()
    analysisDir = pwd;

    baseRealDirFSL = fullfile(analysisDir, 'real_data_FSL');

    meanWithinVarFile = spm_select('FPList', analysisDir, '^mean_within.nii$');
    betweenVarFile = spm_select('FPList', fullfile(baseRealDirFSL, 'MFX_with readjusting', 'stats'), '^mean_random_effects_var1.nii$');
    maskFile = spm_select('FPList', fullfile(baseRealDirFSL, 'MFX_with readjusting', 'stats'), '^mask.*\.nii$');
    
    maskData = spm_read_vols(spm_vol(maskFile));
    meanWithinVarData = spm_read_vols(spm_vol(meanWithinVarFile));
    meanWithinVarData = meanWithinVarData(maskData(:)>0);
    betweenVarData = spm_read_vols(spm_vol(betweenVarFile));
    betweenVarData = betweenVarData(maskData(:)>0);
    
    factor = 0.001;
    betweenVarSummary = round(betweenVarData*factor)/factor;
    
    betVarBits = unique(betweenVarSummary);
    
    filename = 'realdata_variances.csv';
    fid = fopen(filename, 'w');
    
%     methods{iMethod}, nStudies, sigmaBetweenStudies, sigmaSquare, currMean
    fprintf(fid, 'betweenVariance, withinVariance\n');
    
    for i = 1:numel(betVarBits)
        if mod(betVarBits, 10)==0
            numel(betVarBits) - i
        end
        
        allPositions = find(betweenVarSummary==betVarBits(i));
        randSelection = randi(numel(allPositions), 1, 200);       
        
        for r = randSelection
            fprintf(fid, '%f,%f\n', betweenVarData(allPositions(r)), meanWithinVarData(allPositions(r)));
        end
    end
    fclose(fid);
end