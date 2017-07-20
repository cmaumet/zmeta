% Test whether run was killed before completion
%   simuDir: full path to the directory storing the simulations
function detect_interupted(simuDir)
    simuDirs = dir(fullfile(simuDir, ['test*']));

    num_simu = numel(simuDirs);
    disp([num2str(num_simu) ' simulations']);
    
    for s = numel(simuDirs):-1:1
        main_simu_dir = fullfile(simuDir, simuDirs(s).name);
        
         % Read info from first analysis to check if one-sample
        first_simu_dir = fullfile(main_simu_dir, '0001');
        first_simu_mat_file = fullfile(first_simu_dir, 'simu.mat');
        
        if ~exist(first_simu_mat_file, 'file')
            warning([first_simu_dir ' was interupted before completion.'])
        end
            
    end

end