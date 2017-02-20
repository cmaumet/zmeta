function prepare_fsl_data(datadir, wd, nSubjects, design, designs_dir)
    out_file = fullfile(wd, 'zstat1.nii');

    disp(~exist(out_file, 'file'))
    disp('--')
    if ~exist(out_file, 'file')
        cwd = pwd;
        cd(datadir);
        system('fslmerge -t cope.nii.gz `ls | grep "^con_st"`');
        movefile('cope.nii.gz', wd);
        
        system('fslmerge -t varcope.nii.gz `ls | grep "^varcon_st"`');
        movefile('varcope.nii.gz', wd);

        mask_file = fullfile(wd, 'mask.nii');
        copyfile('con_st001.nii', mask_file);
        mask_img = nifti(mask_file);
        mask_img.dat(:) = 1;
        
        dof = nSubjects-1;
        nStudies = numel(dof);        
        for i = 1:nStudies
            dof_file = fullfile(wd, ['dof_st' num2str(i, '%03d') '.nii']);
            copyfile('con_st001.nii', dof_file);
            dof_img = nifti(dof_file);
            dof_img.dat(:) = dof(i);
        end
        cd(wd);
        system('fslmerge -t dof.nii.gz `ls | grep "^dof_st"`');
        for i = 1:nStudies
            dof_file = fullfile(wd, ['dof_st' num2str(i, '%03d') '.nii']);
            delete(dof_file);
        end
 
        copyfile(fullfile(designs_dir, [design '.mat']), [design '.mat']);
        copyfile(fullfile(designs_dir, [design '.grp']), [design '.grp']);
        copyfile(fullfile(designs_dir, [design '.con']), [design '.con']);

        % Delete previously halted results
        stat_dir = fullfile(wd, 'stats');
        if isdir(stat_dir)
            rmdir(stat_dir,'s')
        end

        cd(cwd);
    end
end
