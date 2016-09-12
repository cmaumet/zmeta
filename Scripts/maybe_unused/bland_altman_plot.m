function bland_altman_plot(data, ref, colour, factorBeforeRounding, logspace, refasx)
% BLAND_ALTMAN_PLOT Creates a Bland-Altman plot.
%   BLAND_ALTMAN_PLOT(DATA, REF) Plot DATA values against REF (used as
%   refernence).
%
%   bland_altman_plot(data, ref)

% Copyright (C) 2014 The University of Warwick
% Id: bland_altman_plot.m  IBMA toolbox
% Camille Maumet

    if nargin < 4
        factorBeforeRounding = 1;
        if nargin < 3 || isempty(colour)
            colour = 'b';
        end
    end

    if logspace
        data = -log10(data);
        ref = -log10(ref);
        factorBeforeRounding = 1;
    end
    
    boxplotdataX = data-ref;
    
	if ~refasx
        boxplotdataY = round((data*factorBeforeRounding+ref*factorBeforeRounding)/2)/factorBeforeRounding;
    else
        boxplotdataY = round(ref);
    end

%     plot(scalerange, repmat(0, size(scalerange)), 'color', [0.5 0.5 0.5]);
    boxplot(boxplotdataX, boxplotdataY, 'color', colour, 'symbol', '');%, 'whisker', 0);
    
%     if logspace
%         set(gca,'XScale','log');
%     end

end