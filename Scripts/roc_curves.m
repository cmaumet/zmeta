function [auc auc10 dice] = roc_curves()
    baseRealDir = fullfile(pwd, 'real_data')

    zStatGt = spm_select('FPList', fullfile(baseRealDir, 'MFX_with readjusting', 'stats'), '^zstat.*\.nii$');
    mask = spm_select('FPList', fullfile(baseRealDir, 'MFX_with readjusting', 'stats'), '^mask.*\.nii$');
        
    zStatGtData = spm_read_vols(spm_vol(zStatGt));
    pGt = -log10(normcdf(-zStatGtData));
    
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
   
    detectionsp0001 = pGt(inMaskPositions) >= 10^(-0.001);
    
    thresh05bonferroni = -norminv(0.05/numel(inMaskPositions));
    detectionsp05Bonferroni = zStatGtData(inMaskPositions) >= thresh05bonferroni;
    
    for iMethod = 1:numel(methods)
        detectionunc001.(methods{iMethod}) = pVal.(methods{iMethod}) >= 10^(-0.001);
        dice.(methods{iMethod}) = 2*sum(detectionunc001.(methods{iMethod})(inMaskPositions)>0 & detectionsp0001>0)./sum((detectionunc001.(methods{iMethod})(inMaskPositions)+ detectionsp0001))
        
        figure(51)
        subplot(3, 3, iMethod)
        vals3d = getfield(pVal, methods{iMethod});
        plot(pGt(inMaskPositions), vals3d(inMaskPositions)-pGt(inMaskPositions), '.', 'markers',2)
        title(methods{iMethod})
        
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
end