function check_identical_data
    % Export all studies
    pattern = '*nStudy*';
    simuDir = '/Volumes/camille/MBIA_buster/';
    simuDirs = dir(fullfile(simuDir, [pattern]));

    num_simu = numel(simuDirs);
    disp([num2str(num_simu) ' simulations'])

    for i = 1:num_simu
        iter_1 = fullfile(simuDir, simuDirs(i).name, '0001', 'data', 'con_st001.nii');
        iter_2 = fullfile(simuDir, simuDirs(i).name, '0002', 'data', 'con_st001.nii');

        nifti1 = nifti(iter_1);
        nifti2 = nifti(iter_2);

        if all(nifti1.dat(:) == nifti2.dat(:))
            disp(['Same data for: ' simuDirs(i).name])
%         else
%             disp(['Good data for: ' simuDirs(i).name])
        end
    end
end