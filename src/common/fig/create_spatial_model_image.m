% This function was used to create a figure for Credible workshop 2014
% talk. The figure is a brain-wise definition of local, global or
% regularised dependences.
function create_spatial_model_image(bgBase, isGlobal)
    MAX_DIM = 1000000;
    if isGlobal < 1
        if isGlobal == 0.5
            baseFile = 'spatial_model_reg.nii';    
        elseif isGlobal == 0
            baseFile = 'spatial_model_local.nii';
        end
        values = randi(100, MAX_DIM, 1);
    elseif isGlobal == 1
        baseFile = 'spatial_model_global.nii';
        values = repmat(50, MAX_DIM, 1);    
    end
    copy_nii_image(bgBase, baseFile)
    % Avoid messing up with bgBase     
    clear bgBase;

    niftiBase = nifti(baseFile);
    
    % Mask with NaN if not already done    
    bgPositions = find(isnan(niftiBase.dat(:)));  
    if isempty(bgPositions)
        bgPositions = find(niftiBase.dat(:)==0);  
        niftiBase.dat(bgPositions) = NaN;
    end   
    
    nonBgPositions = find(~isnan(niftiBase.dat(:)));  
    
    niftiBase.dat(nonBgPositions) = values(1:numel(nonBgPositions));
    
    maskFile = 'mask.nii';
    copy_nii_image(baseFile, maskFile)
    maskImg = nifti(maskFile);
    maskImg.dat(find(~isnan(maskImg.dat(:))))=1;    
    maskImg.dat(find(isnan(maskImg.dat(:))))=0;
    
    if isGlobal == 0.5
        matlabbatch{1}.spm.spatial.smooth.data = {baseFile};
        matlabbatch{1}.spm.spatial.smooth.fwhm = [8 8 8];
        matlabbatch{1}.spm.spatial.smooth.prefix = 's';
        matlabbatch{1}.spm.spatial.smooth.im = true;

        spm_jobman('run', matlabbatch);
        
        niftiBase = nifti(['s' baseFile]);
    end
       
    figure(1);
    imagesc(niftiBase.dat(:,:,16))
end