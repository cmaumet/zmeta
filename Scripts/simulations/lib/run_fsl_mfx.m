function run_fsl_mfx(datadir, wd, onesample)
    cwd = pwd;
    
    if ~isdir(wd)
        mkdir(wd)
    end
    cd(wd)
    
    simuinfo = load('../simu.mat');
    nSubjects = simuinfo.simu.config.nSubjects;
    nStudies = simuinfo.simu.config.nStudies;
    if onesample
        design = ['design_ones_' num2str(nStudies, '%02d') 'st'];
    end
    prepare_fsl_data(datadir, wd, nSubjects, design)
    
    system(['flameo --cope=cope --vc=varcope ' ...
        '--dvc=dof --mask=mask --ld=stats '...
        '--dm=' design '.mat --cs=' design '.grp --tc=' design '.con '...
        ' --runmode=flame1'])
    
    cd(cwd)
end