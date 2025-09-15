function run_fsl_mfx(datadir, wd, analysisType, nSubjects, nStudies, ...
        designs_dir, flame_type)

    pValueFile = fullfile(wd, 'mega_mfx_minus_log10_p.nii');

    if ~exist_nii(pValueFile)
        disp('--> Computing FSL MFX...')

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

        if flame_type == 1
            flame_mod = 'flame1';
        elseif flame_type == 2
            flame_mod = 'flame12';
        else
            error(['Unknown flame type ' num2str(flame_mod)]);
        end
        
        cmd = ['flameo --cope=cope --vc=varcope ' ...
            '--dvc=dof --mask=mask --ld=stats '...
            '--dm=' design '.mat --cs=' design '.grp --tc=' design '.con '...
            ' --runmode=' flame_mod];
        disp(cmd)
        
        save('cmd.mat', 'cmd')
        system(cmd);
        
        stat_file = fullfile(wd, 'stats', 'zstat1.nii.gz');
    %     stat_file = gunzip_if_gz(stat_file);
        gunzip(stat_file);
        stat_file = strrep(stat_file, '.gz', '');
        
        originalstat_file = stat_file;
        stat_file = fullfile(wd, 'zstat1.nii');
        copyfile(originalstat_file, stat_file);
        statistic = spm_read_vols(spm_vol(stat_file));
        
        copyfile(stat_file, pValueFile);
        pValueImg = nifti(pValueFile);
        pValueImg.dat(:) = -log10(normcdf(statistic(:), 'upper'));
        
        cd(cwd)
    else
        disp('--> FSL MFX already computed')
    end
end