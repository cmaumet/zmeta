function run_fsl_mfx(datadir, wd, analysisType, nSubjects, nStudies, ...
        designs_dir)
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
    prepare_fsl_data(datadir, wd, nSubjects, design, designs_dir)
    
    system(['flameo --cope=cope --vc=varcope ' ...
        '--dvc=dof --mask=mask --ld=stats '...
        '--dm=' design '.mat --cs=' design '.grp --tc=' design '.con '...
        ' --runmode=flame1'])
    
    stat_file = fullfile(wd, 'stats', 'zstat1.nii.gz');
%     stat_file = gunzip_if_gz(stat_file);
    gunzip(stat_file)
    stat_file = strrep(stat_file, '.gz', '');
    
    originalstat_file = stat_file;
    stat_file = fullfile(wd, 'zstat1.nii');
    copyfile(originalstat_file, stat_file);
    statistic = spm_read_vols(spm_vol(stat_file));
    
    pValueFile = fullfile(spm_file(stat_file, 'path'), 'mega_mfx_minus_log10_p.nii');
    copyfile(stat_file, pValueFile);
    pValueImg = nifti(pValueFile);
    pValueImg.dat(:) = -log10(normcdf(statistic(:), 'upper'));
    
    cd(cwd)
end