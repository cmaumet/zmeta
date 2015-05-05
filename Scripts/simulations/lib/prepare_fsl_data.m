function prepare_fsl_data(datadir, wd, nSubjects, design)
    if ~exist(fullfile(wd, 'dof.nii.gz'), 'file')
        cwd = pwd;
        cd(datadir)
        system('fslmerge -t cope.nii.gz `ls | grep "^con_st"`')
        movefile('cope.nii.gz', wd)
        
        system('fslmerge -t varcope.nii.gz `ls | grep "^varcon_st"`')
        movefile('varcope.nii.gz', wd)

        mask_file = fullfile(wd, 'mask.nii');
        copyfile('con_st001.nii', mask_file)
        mask_img = nifti(mask_file);
        mask_img.dat(:) = 1;
        
        dof = nSubjects-1;
        nStudies = numel(dof);        
        for i = 1:nStudies
            dof_file = fullfile(wd, ['dof_st' num2str(i, '%03d') '.nii']);
            copyfile('con_st001.nii', dof_file)
            dof_img = nifti(dof_file);
            dof_img.dat(:) = dof(i);
        end
        cd(wd)
        system('fslmerge -t dof.nii.gz `ls | grep "^dof_st"`')
        for i = 1:nStudies
            dof_file = fullfile(wd, ['dof_st' num2str(i, '%03d') '.nii']);
            delete(dof_file);
        end
        
        copyfile(fullfile(cwd, ['../../../../fsl_design/' design '.mat']), [design '.mat'])
        copyfile(fullfile(cwd, ['../../../../fsl_design/' design '.grp']), [design '.grp'])
        copyfile(fullfile(cwd, ['../../../../fsl_design/' design '.con']), [design '.con'])

        cd(cwd)
    end
end