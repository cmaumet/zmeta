function run_fsl_mfx(datadir, wd, onesample, nSubjects, nStudies)
    cwd = pwd;
    
    if ~isdir(wd)
        mkdir(wd)
    end
    cd(wd)
    
    if onesample
        design = ['design_ones_' num2str(nStudies, '%02d') 'st'];
    end
    prepare_fsl_data(datadir, wd, nSubjects, design)
    
    system(['flameo --cope=cope --vc=varcope ' ...
        '--dvc=dof --mask=mask --ld=stats '...
        '--dm=' design '.mat --cs=' design '.grp --tc=' design '.con '...
        ' --runmode=flame1'])
    
    statFile = fullfile(wd, 'stats', 'zstat1.nii.gz');
    statFile = gunzip_if_gz(statFile);
    
    originalStatFile = statFile;
    statFile = fullfile(wd, 'zstat1.nii');
    copy_nii_image(originalStatFile, statFile);
    statistic = spm_read_vols(spm_vol(statFile));
    
    pValueFile = fullfile(spm_file(statFile, 'path'), 'mega_mfx_minus_log10_p.nii');
    copy_nii_image(statFile, pValueFile);
    pValueImg = nifti(pValueFile);
    pValueImg.dat(:) = -log10(normcdf(statistic(:), 'upper'));
    
    cd(cwd)
end