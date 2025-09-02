% Check if files in 'fileNames' exist and if they are in nifti or gzip nifti format.
%
% fileNames             - cell array of string, path to files.
%
% existOrNot            - vector of boolean, true if corresponding file in
%                         'fileNames' exist.
% fileNames             - cell array of string, path to files in nifti or 
%                         gzip nifti format (if file does not exist, nifti 
%                         format).
%_________________________________________________________________________
%  This file is part of AutoMRI12. For copyright details, see copyright.txt
function [existOrNot, fileNames] = find_file_nii_or_gz(fileNames)
    cellAtBeg = true;
    if ~iscell(fileNames)
        cellAtBeg = false;
        fileNames = cellstr(fileNames);
    end

    % Remove gz extension if needed
    fileNames = strrep(fileNames, '.gz', '');

    % Look for .nii files first
    existOrNot = exist_file(fileNames);
    
    if ~all(existOrNot)
        % Look for .nii.gz files
        for i = 1:numel(fileNames)
            gzFileName = [fileNames{i}, '.gz'];
            if exist_file(gzFileName)
                if ~existOrNot(i) %ismember(i, indexFilesDoNotExist)
                    fileNames{i} = gzFileName;
                    existOrNot(i) = true;
                else
                    error('find_file_nii_or_gz:niiFileAndniigzFileFound', ...
                        ['Error: file ', fileNames{i}, ' exist both as .nii and .nii.gz']);
                    % Should not occur anymore (if nii file is found,
                    % nii.gz is not looked for)
                end
            end
        end
    end
%     if isempty(indexFilesDoNotExist)
%         existOrNot = true;
%     end
    
    if ~cellAtBeg
        fileNames = fileNames{1};
    end
end