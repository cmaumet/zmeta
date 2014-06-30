function export_full_simulations(simuDir)
    simuDirs = find_dirs('^nStudy', simuDir);
    
    
    
    
    
    for i = 1:numel(simuDirs)
        i
        filename = ['simu_all_' mat2str(i) '.csv'];
        fid = fopen(filename, 'w');
        
        fprintf(fid, 'methods, nStudies , Between, Within, nSimu, p \n');
        
        info = regexp(spm_file(simuDirs{i}, 'filename'), ...
            'nStudy(?<nStudy>\d+)_Betw(?<Betw>\d+\.?\d*)_Within(?<Within>\d+\.?\d*)_nSimu(?<nSimu>\d+)','names');
        
        simuDirs{i} = fullfile(simuDir, simuDirs{i});
        
        pVal.fishers = spm_read_vols(spm_vol(spm_select('FPList', fullfile(simuDirs{i}, 'fishers'), '^fishers_ffx_minus_log10_p')));
        mystr = sprintf(['fishers,' mat2str(info.nStudy) ',' mat2str(info.Betw) ',' mat2str(info.Within)  ',' mat2str(info.nSimu) ',%i\n'], pVal.fishers);
        
        pVal.GLMRFX = spm_read_vols(spm_vol(spm_select('FPList', fullfile(simuDirs{i}, 'megaRFX'), '^mega_rfx_minus_log10_p')));
        mystr = [mystr sprintf(['GLMRFX,' mat2str(info.nStudy) ',' mat2str(info.Betw) ',' mat2str(info.Within)  ',' mat2str(info.nSimu) ',%i\n'], pVal.GLMRFX)];
        
        pVal.PermutZ = spm_read_vols(spm_vol(spm_select('FPList', fullfile(simuDirs{i}, 'permutZ'), '^lP\+\.hdr$')));
        mystr = [mystr sprintf(['PermutZ,' mat2str(info.nStudy) ',' mat2str(info.Betw) ',' mat2str(info.Within)  ',' mat2str(info.nSimu) ',%i\n'], pVal.PermutZ)];
        
        pVal.PermutCon = spm_read_vols(spm_vol(spm_select('FPList', fullfile(simuDirs{i}, 'permutCon'), '^lP\+\.hdr$')));
        mystr = [mystr sprintf(['PermutCon,' mat2str(info.nStudy) ',' mat2str(info.Betw) ',' mat2str(info.Within)  ',' mat2str(info.nSimu) ',%i\n'], pVal.PermutCon)];
        
        pVal.GLMFFX = spm_read_vols(spm_vol(spm_select('FPList', fullfile(simuDirs{i}, 'megaFFX'), '^mega_ffx_ffx_minus_log10_p\.nii$')));
        mystr = [mystr sprintf(['GLMFFX,' mat2str(info.nStudy) ',' mat2str(info.Betw) ',' mat2str(info.Within)  ',' mat2str(info.nSimu) ',%i\n'], pVal.GLMFFX)];
        
        pVal.Stouffers = spm_read_vols(spm_vol(spm_select('FPList', fullfile(simuDirs{i}, 'stouffers'), '^stouffers_ffx_minus_log10_p\.nii$')));
        mystr = [mystr sprintf(['Stouffers,' mat2str(info.nStudy) ',' mat2str(info.Betw) ',' mat2str(info.Within)  ',' mat2str(info.nSimu) ',%i\n'], pVal.Stouffers)];
        
        pVal.StouffersMFX = spm_read_vols(spm_vol(spm_select('FPList', fullfile(simuDirs{i}, 'stouffersMFX'), '^stouffers_rfx_minus_log10_p\.nii$')));
        mystr = [mystr sprintf(['StouffersMFX,' mat2str(info.nStudy) ',' mat2str(info.Betw) ',' mat2str(info.Within)  ',' mat2str(info.nSimu) ',%i\n'], pVal.StouffersMFX)];
        
        pVal.WeightedZ = spm_read_vols(spm_vol(spm_select('FPList', fullfile(simuDirs{i}, 'weightedZ'), '^weightedz_ffx_minus_log10_p\.nii$')));
        mystr = [mystr sprintf(['WeightedZ,' mat2str(info.nStudy) ',' mat2str(info.Betw) ',' mat2str(info.Within)  ',' mat2str(info.nSimu) ',%i\n'], pVal.WeightedZ)];
        
        fprintf(fid, '%s', mystr)
        fclose(fid)
    end
    
end