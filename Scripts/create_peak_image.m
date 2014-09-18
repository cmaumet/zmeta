% This function was used to create a figure for Neuroimformatics 2014
% talk. The figure is a sparse brain image representing data volume used 
% in coordinate-based meta-analysis
function create_peak_image(niftiBase, bgBase, TabDat, xSPM)
    niftiBase = nifti(niftiBase);
    numPeaks = numel(TabDat.dat(:,end));
    
    if ~isempty(bgBase)
        bg = nifti(bgBase);
        niftiBase.dat.scl_slope = 1;
        create(niftiBase)
        niftiBase.dat(:) = 100;
        niftiBase.dat(find(~isnan(bg.dat(:))))=80;
        
        image = niftiBase.dat(:,:,:);
        
        bwall = niftiBase.dat(:,:,:);
        for d = 1:3
            bw=edge( reshape(image, size(image,1), [] ) , 'canny');
            bw=reshape(bw,size(image));
            
            bwall = bw+bwall;
        end
        niftiBase.dat(:,:,:) = bwall;
    end
    
%     peaksparse = niftiBase.dat(:,:,:);
    peaksparse = niftiBase.dat(:,:,:);
    
    for i = 1:numPeaks
        peakpos = find(ismember(xSPM.XYZmm',TabDat.dat{i,end}', 'rows'));
        peakcoord = xSPM.XYZ(:,peakpos);
        
        % This is just for display (does not take into account LR)?
        for xinc = 0:1
            for yinc = 0:1
                for zinc = 0:1
                    peaksparse(peakcoord(1)+xinc, peakcoord(2)+yinc, peakcoord(3)+zinc) = 1/TabDat.dat{i,end-3};
                end
            end
        end
        
        
        
        
    end
    niftiBase.dat(:,:,:) = peaksparse;
end