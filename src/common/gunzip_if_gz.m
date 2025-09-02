% Gunzip files in 'fileName' if they were gzipped
%
% fileName  - string or cell array of string, path to files to gunzip.
% 
% fileName  - string or cell array of string, path to gunzip files.
% wasgz     - boolean or array of boolean, true if file was gz
%_________________________________________________________________________
%  This file is part of AutoMRI12. For copyright details, see copyright.txt
function [fileName, wasgz] = gunzip_if_gz(fileName)
    wasCell = true;
    if ~iscell(fileName)
        fileName = cellstr(fileName);
        wasCell = false;
    end
    
    wazgz = false(size(fileName));
    for i = 1:numel(fileName)
        [~, fileName{i}] = find_file_nii_or_gz(fileName{i});

        wasgz(i) = ~isempty(regexp(fileName{i}, '.*\.gz$'));

        if wasgz(i)
            fileName{i} = gunzip_and_delete(fileName{i});
        end
    end
    
    if ~wasCell
        fileName = fileName{1};
        wasgz = wasgz(1);
    end
end