function check_identical_data
    % Export all studies
    pattern = '*nStudy*';
    simuDir = '/Volumes/camille/MBIA_buster/';
    simuDirs = dir(fullfile(simuDir, [pattern]));

    num_simu = numel(simuDirs);
    disp([num2str(num_simu) ' simulations'])

    num_identical = 0;
    for i = 1:num_simu
        go_next_simu = false;
        
        for it_1 = 1:38
            iter_1 = fullfile(simuDir, simuDirs(i).name, sprintf('%04d',it_1), 'data', 'con_st001.nii');    
            for it_2 = (it_1+1):38
                iter_2 = fullfile(simuDir, simuDirs(i).name, sprintf('%04d',it_2), 'data', 'con_st001.nii');

                nifti1 = nifti(iter_1);
                nifti2 = nifti(iter_2);

                if all(nifti1.dat(:) == nifti2.dat(:))
                    disp(['Same data for: ' simuDirs(i).name ...
                          ' between ' num2str(it_1) ' and ' ...
                          num2str(it_2)])
                    num_identical = num_identical + 1;
                    
                    go_next_simu = true;
                    break;
        %         else
        %             disp(['Good data for: ' simuDirs(i).name])
                end
            end
            if go_next_simu
                break;
            end
        end
    end
    
    disp([num2str(num_identical) ' identical'])
end