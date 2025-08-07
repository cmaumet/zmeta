


% wmFile = '../data/WM_mask_nobg.nii,1';
wmFile = '../data/mask.nii,1'
spm_reslice({fisherFile, wmFile})
wm = spm_read_vols(spm_vol(add_prefix_to_file_name(wmFile, 'r')));

ffxMethods = {'fishers', 'stouffers', 'weightedZ', 'megaFFX'}
for i = 1:numel(ffxMethods)
    ffxFile = ['../data/real_data/', ffxMethods{i},'/', ffxMethods{i},'_ffx_minus_log10_p.nii,1'];
    % z-stat
    ffxData = norminv(10.^(-spm_read_vols(spm_vol(ffxFile))));
    
    figure(33);
    subplot(2,4,i)
    hist(setdiff(ffxData(wm(:)>0), Inf), 50)
    title(ffxMethods{i})
end

megaRFXFile = '../data/real_data/megaRFX/mega_rfx_minus_log10_p.nii,1';
megaRFXData = norminv(10.^(-spm_read_vols(spm_vol(megaRFXFile))));
subplot(2,4,5)
hist(setdiff(megaRFXData(wm(:)>0), Inf), 50)
title('Mega RFX')

permutZFile = '../data/real_data/permutZ/lP+.hdr,1';
permutZData = norminv(10.^(-spm_read_vols(spm_vol(permutZFile))));
subplot(2,4,6)
hist(setdiff(permutZData(wm(:)>0), Inf), 50)
title('Permut Z')

permutConFile = '../data/real_data/permutCon/lP+.hdr,1';
permutConData = norminv(10.^(-spm_read_vols(spm_vol(permutConFile))));
subplot(2,4,7)
hist(setdiff(permutConData(wm(:)>0), Inf), 50)
title('Permut Contrast')

stouffersMFXFile = '../data/real_data/stouffersMFX/stouffers_rfx_minus_log10_p.nii,1';
stouffersMFXData = norminv(10.^(-spm_read_vols(spm_vol(stouffersMFXFile))));
subplot(2,4,8)
hist(setdiff(stouffersMFXData(wm(:)>0), Inf), 50)
title('stouffers RFX')

figure(34)
flameMFXFile = '../data/real_data/FLAME_MFX/flameMFX.nii,1';
flameMFXData = spm_read_vols(spm_vol(flameMFXFile));
hist(setdiff(flameMFXData(wm(:)>0), Inf), 50)
title('Flame MFX')