function [auc auc10 dice] = roc_curves(analysisDir)
    if nargin < 1
        analysisDir = pwd;
    end

    baseRealDir = fullfile(analysisDir, 'real_data');
    baseRealDirFSL = fullfile(analysisDir, 'real_data_FSL');

    zStatGt = spm_select('FPList', fullfile(baseRealDirFSL, 'MFX_with readjusting', 'stats'), '^zstat.*\.nii$');
    mask = spm_select('FPList', fullfile(baseRealDirFSL, 'MFX_with readjusting', 'stats'), '^mask.*\.nii$');
        
    zStatGtData = spm_read_vols(spm_vol(zStatGt));
    logPGt = -log10(normcdf(-zStatGtData));
    
    maskData = spm_read_vols(spm_vol(mask));
    inMaskPositions = find(maskData(:)>0);
    
    pVal.fishers = spm_read_vols(spm_vol(spm_select('FPList', fullfile(baseRealDir, 'fishers'), '^fishers_ffx_minus_log10_p')));
    pVal.GLMRFX = spm_read_vols(spm_vol(spm_select('FPList', fullfile(baseRealDir, 'megaRFX'), '^mega_rfx_minus_log10_p')));
    pVal.PermutZ = spm_read_vols(spm_vol(spm_select('FPList', fullfile(baseRealDir, 'permutZ'), '^lP\+\.hdr$')));
    pVal.PermutCon = spm_read_vols(spm_vol(spm_select('FPList', fullfile(baseRealDir, 'permutCon'), '^lP\+\.hdr$')));
    pVal.GLMFFX = spm_read_vols(spm_vol(spm_select('FPList', fullfile(baseRealDir, 'megaFFX'), '^mega_ffx_ffx_minus_log10_p\.nii$')));
    pVal.Stouffers = spm_read_vols(spm_vol(spm_select('FPList', fullfile(baseRealDir, 'stouffers'), '^stouffers_ffx_minus_log10_p\.nii$')));
    pVal.StouffersMFX = spm_read_vols(spm_vol(spm_select('FPList', fullfile(baseRealDir, 'stouffersMFX'), '^stouffers_rfx_minus_log10_p\.nii$')));
    pVal.WeightedZ = spm_read_vols(spm_vol(spm_select('FPList', fullfile(baseRealDir, 'weightedZ'), '^weightedz_ffx_minus_log10_p\.nii$')));
    	
    methods = fieldnames(pVal);
   
    detectionsp0001 = logPGt(inMaskPositions) >= 10^(-0.001);
    
    thresh05bonferroni = -norminv(0.05/numel(inMaskPositions));
    detectionsp05Bonferroni = zStatGtData(inMaskPositions) >= thresh05bonferroni;
       
    filename = 'realdata.csv';
    fid = fopen(filename, 'w');
    
%     methods{iMethod}, nStudies, sigmaBetweenStudies, sigmaSquare, currMean
    fprintf(fid, 'methods, mean, zGT, zValue, isFirstRepeat, stderror\n');
    
    factor = 1;
    
    zGt = -norminv(10.^(-logPGt(inMaskPositions)));
    transfoZGt = round(zGt*factor)/factor;
    
    uniqueZvalueGt = unique(transfoZGt);
    
    for iMethod = 2:numel(methods)
        iMethod
        detectionunc001.(methods{iMethod}) = pVal.(methods{iMethod}) >= 10^(-0.001);
        dice.(methods{iMethod}) = 2*sum(detectionunc001.(methods{iMethod})(inMaskPositions)>0 & detectionsp0001>0)./sum((detectionunc001.(methods{iMethod})(inMaskPositions)+ detectionsp0001))
        
        figure(51)
        subplot(3, 3, iMethod)
        logPVal3d = getfield(pVal, methods{iMethod});
%         plot(logPGt(inMaskPositions), logPVal3d(inMaskPositions)-logPGt(inMaskPositions), '.', 'markers',2)
        numBoxPlots = 50;
        bland_altman_plot(10.^(-logPVal3d(inMaskPositions)), 10.^(-logPGt(inMaskPositions)), '', numBoxPlots, true, true)
        title(methods{iMethod})
        
        toPrint = '';
        
        data = logPVal3d(inMaskPositions);
        
        
        zData = -norminv(10.^(-data));
        for i = 1:numel(uniqueZvalueGt);
            if mod(i, 5)==0
                i
            end
            
            
           reps = zData(find(transfoZGt == uniqueZvalueGt(i)));
           
           % Exclude proba=1 (can happen in permutation) cause a pb to compute
           % z-stat and is clearly not that interesting...
           reps = reps(find(~isinf(reps(:))));
            
%             reps = 10.^(-reps);
            
            meanReps = mean(reps);
            stdReps = std(reps);
                      
            randSelection = randi(numel(reps), 1, 200);
            for r = randSelection
                if isnan(reps(r)) | isinf(reps(r))
                    aa=1
                end
                fprintf(fid, '%s ,%f, %f, %f, %.0f, %f \n', methods{iMethod}, ...
                                    meanReps, uniqueZvalueGt(i), reps(r), (r==randSelection(1)), stdReps);
            end
        end
        
        
        % Inmask voxels only
        currentP = pVal.(methods{iMethod});
        pVal.(methods{iMethod}) = 10.^(-currentP(inMaskPositions));
        
        TPR.(methods{iMethod})(1) = 0;
        FPR.(methods{iMethod})(1) = 0;
        
        idx = 2;
        for i = [0 logspace(-30, 0, 100)]
            TPR.(methods{iMethod})(idx) = sum(pVal.(methods{iMethod})<=i & ...
                (detectionsp0001>0))./sum(detectionsp0001>0);
            FPR.(methods{iMethod})(idx) = sum(pVal.(methods{iMethod})<=i & ...
                detectionsp0001==0)./sum(detectionsp0001==0);

            idx = idx + 1;
        end
        auc.(methods{iMethod}) = AUC(TPR.(methods{iMethod}), FPR.(methods{iMethod}), 0, 1)
        auc10.(methods{iMethod}) = AUC(TPR.(methods{iMethod}), FPR.(methods{iMethod}), 0, 0.1)
%         figure(52)
%         hold on;plot(FPR.(methods{iMethod}), TPR.(methods{iMethod}), 'r-', 'linewidth', 2)
    end
    
    fclose(fid);
end