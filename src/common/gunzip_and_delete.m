% Gunzip files in 'gzFileNames' and delete gz.nii files.
%
% gzFileNames  - string or cell array of string, path to files to gunzip.
%
% gunzipFiles  - string or cell array of string, path to gunzip files.
%_________________________________________________________________________
%  This file is part of AutoMRI12. For copyright details, see copyright.txt
function gunzipFiles = gunzip_and_delete(gzFileNames)
    cellAtBeg = true;
    if ~iscell(gzFileNames)
        gzFileNames = cellstr(gzFileNames);
        cellAtBeg = false;
    end

    [~, gzFileNames] = find_file_nii_or_gz(gzFileNames);
    error_if_not_exist(gzFileNames);
    
    gunzipFiles = cell(size(gzFileNames));
    % Gzip nii files
    for i = 1:numel(gzFileNames)
        if strcmp(gzFileNames{i}(end-3:end),'.nii')
            gunzipFiles{i} = gzFileNames{i};
        else
            outFileName = add_suffix_to_file_name(gzFileNames{i}, '', '.nii');
            copiedImg = add_prefix_to_file_name(gzFileNames{i}, 'temp_');
            copy_nii_image(gzFileNames{i}, copiedImg)

            copiedNiiImg = gunzip(copiedImg);
            delete(copiedImg);
            move_nii_image(copiedNiiImg{1}, outFileName);
            delete(gzFileNames{i});

            gunzipFiles{i} = outFileName; 
        end
    end

    
    if ~cellAtBeg
        gunzipFiles = gunzipFiles{1};
    end
end