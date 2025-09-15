function [found, filepath] = exist_nii(filepath, uncompress)
    % EXIST_NII  Check if NIfTI image exist (possibly compressed)
    %   EXIST_NII(FILEPATH) returns true if the NIfTI image was found and 
    %       the full path to the image.
    %   EXIST_NII(FILEPATH, true) returns true if the NIfTI image was found 
    %       and the full path to the image and uncompress the image.
    % 
    if nargin < 2
        uncompress = false;
    end
    
    if exist(filepath, 'file')
        found = true;
    elseif exist([filepath '.gz'], 'file')
        found = true;
        if uncompress
            gunzip(filepath);
        else
            filepath = [filepath '.gz'];
        end
    else
        found = false;
        filepath = '';
    end
end