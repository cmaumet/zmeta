function run_fsl_ffx(datadir, wd, analysisType, nSubjects, nStudies)
    cwd = pwd;
    
    if ~isdir(wd)
        mkdir(wd)
    end
    cd(wd)
    
    if analysisType == 1
        design = ['design_ones_' num2str(nStudies, '%02d') 'st'];
    elseif analysisType == 2
        design = ['design_' num2str(nStudies*2, '%03d') 'studies_' num2str(nStudies, '%02d') '_equal'];        
    elseif analysisType == 3
        design = ['design_' num2str(nStudies*2, '%03d') 'studies_' num2str(nStudies*2/5, '%02d') '_equal'];
    end
    prepare_fsl_data(datadir, wd, nSubjects, design)
    
    system(['flameo --cope=cope --vc=varcope ' ...
        '--dvc=dof --mask=mask --ld=stats '...
        '--dm=' design '.mat --cs=' design '.grp --tc=' design '.con '...
        ' --runmode=fe'])
    
    statFile = fullfile(wd, 'stats', 'zstat1.nii.gz');
    statFile = gunzip_if_gz(statFile);
    
    originalStatFile = statFile;
    statFile = fullfile(wd, 'zstat1.nii');
    copy_nii_image(originalStatFile, statFile);
    statistic = spm_read_vols(spm_vol(statFile));
    
    pValueFile = fullfile(spm_file(statFile, 'path'), 'mega_ffx_minus_log10_p.nii');
    copy_nii_image(statFile, pValueFile);
    pValueImg = nifti(pValueFile);
    pValueImg.dat(:) = -log10(normcdf(statistic(:), 'upper'));
    
    cd(cwd)
end