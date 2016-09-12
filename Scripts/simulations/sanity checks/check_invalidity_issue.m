% This file was created when within=5 was producing invalid estimates.
% This script produces a q-q plot per iteration. This was useful to spot
% that all iterations had the very same qqplot (i.e. after checking were
% based on the exact same data)

nrows = 6;
ncols = 7;

figure()
for i = 1:38
    clear ml10p;
    folder = ['/Volumes/camille/MBIA_buster/nStudy25_subNumidentical_varidentical_Betw1_Within0.25_nSimuOneDir30_unitmis0_numStudySoft0_softFactor1' '/00' sprintf('%02d',i)];
    filename = fullfile(folder, '/megaMFX/mega_mfx_minus_log10_p.nii');
    ml10p=nifti(filename);
    disp(filename)
    subplot(nrows,ncols,i);
    loglog((1:27000)./(27000), sort(10.^(-ml10p.dat(:))), 'o')
end