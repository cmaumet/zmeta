% Test existence of file(s)
%
% filePath              - string or cell array of string, file(s) to check.
% ignoreIfEmpty         - boolean, true if empty cells must be ignored.
%
% existOrNot            - vector of boolean
% indexFilesDoNotExist  - vector of index
%_________________________________________________________________________
%  This file is part of AutoMRI12. For copyright details, see copyright.txt
function [existOrNot, indexFilesDoNotExist] = exist_file(filePath, ignoreIfEmpty)
    % --- Default values ---
    ignoreIfEmpty = default_value_if_empty_parameter('ignoreIfEmpty', false);
    
    % --- Outputs ---
    indexFilesDoNotExist = [];
    
    if ~iscell(filePath)
        if ignoreIfEmpty && isempty(filePath)
            existOrNot = true;
        else
            existOrNot = spm_existfile(filePath);%exist(filePath, 'file') == 2;
            indexFilesDoNotExist = 1;
        end
    else
        existOrNot = [];
        for i = 1:size(filePath,1)
            for j = 1:size(filePath,2)
                if ignoreIfEmpty && isempty(filePath{i,j})
                    existOrNot = [existOrNot true];
                else
                    [pth, name, ext, ~] = spm_fileparts(filePath{i,j});
                    toTest = fullfile(pth, [name, ext]);
                    
                    currExist = spm_existfile(toTest);
                    existOrNot = [existOrNot currExist];
                    if ~currExist
                        indexFilesDoNotExist = [indexFilesDoNotExist sub2ind(size(filePath), i, j)];
                    end
                end
            end
        end
        if size(filePath,1)==0 && size(filePath,2)==0
            existOrNot = false;
        end
    end
end