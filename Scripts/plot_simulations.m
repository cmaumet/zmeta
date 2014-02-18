function found = plot_simulations(simuDir)
    if nargin == 0
        simuDir = fullfile(pwd, 'simulations');
    end
    
    load(fullfile(simuDir, 'simuinfo.mat'));
    
    nStudiesArray = simuinfo.config.nStudies; %[5, 10, 25, 50];
    sigmaSquareArray = simuinfo.config.sigmaSquare;
    sigmaBetweenStudiesArray = simuinfo.config.sigmaBetweenStudies;
       
    nSimuOneDir = simuinfo.config.nSimuOneDir;
    
    filename = 'simu.csv';
    fid = fopen(filename, 'w');
    
%     methods{iMethod}, nStudies, sigmaBetweenStudies, sigmaSquare, currMean
    fprintf(fid, 'methods, nStudies , RFX, sigmasSquare, mean, rep, isFirstRepeat, stderror\n');

    
    found = false;
    for iStudies = 1:numel(nStudiesArray)
        nStudies = nStudiesArray(iStudies);
        for sigmaBetweenStudies = sigmaBetweenStudiesArray
            
            startSigma = 1+(sigmaBetweenStudies==0);
            
            for iSigmaSquare = startSigma:numel(sigmaSquareArray)
                sigmaSquare = sigmaSquareArray(iSigmaSquare);
            
                currSimuDirName = ['nStudy' num2str(nStudies) '_Betw' num2str(sigmaBetweenStudies) ...
                    '_Within' num2str(sigmaSquare) '_nSimu' num2str(nSimuOneDir) 'thrice'];
                simulationDir = fullfile(pwd, 'simulations', currSimuDirName);
                
                try
                    currentMeta = load(fullfile(simulationDir, 'simu.mat'));
                    
                    methods = setdiff(fieldnames(currentMeta.simu), 'config');
                    
                    % Set names (instead of abbv)
                    methNames = methods;
                    methNames = strrep(methNames, 'fishers', 'Fisher''s');
                    methNames = strrep(methNames, 'megaFfx', 'GLM FFX');
                    methNames = strrep(methNames, 'megaRfx', 'GLM RFX');
                    methNames = strrep(methNames, 'permutCon', 'Contrast Perm.');
                    methNames = strrep(methNames, 'permutZ', 'Z Perm.');
                    methNames = strrep(methNames, 'stouffers', 'Stouffer''s');
                    methNames = strrep(methNames, 'stouffersMFX', 'Stouffer''s MFX');
                    methNames = strrep(methNames, 'weightedZ', 'Weighted Z');
                    
                    nMethods = numel(methods);

                    for iMethod = 1:nMethods
                        currMean = getfield(currentMeta, 'simu', methods{iMethod}, 'mean');
                        
                        currRepeats = getfield(currentMeta, 'simu', methods{iMethod}, 'repeats');
                        currStdError = getfield(currentMeta, 'simu', methods{iMethod}, 'stderror');
                        
                        for iRepeat = 1:numel(currRepeats)
% 
%                             if sigmaBetweenStudies == 0
%                                 rfxText = 'Fixed-effects';
%                             elseif sigmaBetweenStudies == 1
%                                 rfxText = 'Random-effects';
%                             else
%                                 error();
%                             end
                            
    %                         A = [nStudies, sigmaBetweenStudies, sigmaSquare, iMethod, currMean];
    %                         dlmwrite(filename, A, '-append', 'precision', '%.6f', 'delimiter', ',');
                            fprintf(fid, '%s ,%.0f, %f, %f, %f, %f, %.0f, %f \n', methNames{iMethod}, nStudies, ...
                                sigmaBetweenStudies, sigmaSquare, currMean, currRepeats(iRepeat), (iRepeat==1), currStdError);
                        end
                         
                         found = true;
                    end
                catch
                    % For now, ignore missing files
                    disp(['not found: ' currSimuDirName ])
                end

            end
        end
    end
    fclose(fid);
    
end