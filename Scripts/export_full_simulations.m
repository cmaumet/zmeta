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
        fisherFile = spm_select('FPList', fullfile(simuDirs{i}, 'fishers'), '^fishers_ffx_minus_log10_p\.nii$');
        pVal.fishers = spm_read_vols(spm_vol(fisherFile));
        if any(isinf(pVal.fishers(:)))
            % Get the probability
            copy_nii_image(fisherFile, add_suffix_to_file_name(fisherFile, '_ORIGINAL'));
            statFile = spm_select('FPList', fullfile(simuDirs{i}, 'fishers'), '^fishers_ffx_statistic');
            
            matlabbatch{1}.spm.util.imcalc.input = {statFile};
            matlabbatch{1}.spm.util.imcalc.output = ['fishers_ffx_minus_log10_p.nii'];
            matlabbatch{1}.spm.util.imcalc.outdir = {spm_file(statFile, 'path')};
            nStudies = regexp(simuDirs{i}, 'nStudy(\d+)', 'tokens');
            nStudies = nStudies{1}{1}
            
            matlabbatch{1}.spm.util.imcalc.expression = ['-log10(cdf(''chi2'',i1, 2*' num2str(nStudies) ', ''upper''))'];
            matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
            matlabbatch{1}.spm.util.imcalc.options.dtype = 64;
            spm_jobman('run', matlabbatch)

            fisherFile = spm_select('FPList', spm_file(statFile, 'path'), '^fishers_ffx_minus_log10_p\.nii$');
            pVal.fishers = spm_read_vols(spm_vol(fisherFile));
            if any(isinf(pVal.fishers(:)))
                error('infinite pvals')
            end
        end
        
        mystr = sprintf(['fishers,' mat2str(info.nStudy) ',' mat2str(info.Betw) ',' mat2str(info.Within)  ',' mat2str(info.nSimu) ',%i\n'], pVal.fishers);
        
        pVal.GLMRFX = spm_read_vols(spm_vol(spm_select('FPList', fullfile(simuDirs{i}, 'megaRFX'), '^mega_rfx_minus_log10_p')));
        if any(isinf(pVal.GLMRFX(:)))
            error('infinite pvals')
        end
        mystr = [mystr sprintf(['GLMRFX,' mat2str(info.nStudy) ',' mat2str(info.Betw) ',' mat2str(info.Within)  ',' mat2str(info.nSimu) ',%i\n'], pVal.GLMRFX)];
        
        pVal.PermutZ = spm_read_vols(spm_vol(spm_select('FPList', fullfile(simuDirs{i}, 'permutZ'), '^lP\+\.hdr$')));
        if any(isinf(pVal.PermutZ(:)))
            error('infinite pvals')
        end
        mystr = [mystr sprintf(['PermutZ,' mat2str(info.nStudy) ',' mat2str(info.Betw) ',' mat2str(info.Within)  ',' mat2str(info.nSimu) ',%i\n'], pVal.PermutZ)];
        
        pVal.PermutCon = spm_read_vols(spm_vol(spm_select('FPList', fullfile(simuDirs{i}, 'permutCon'), '^lP\+\.hdr$')));
        if any(isinf(pVal.PermutCon(:)))
            error('infinite pvals')
        end
        mystr = [mystr sprintf(['PermutCon,' mat2str(info.nStudy) ',' mat2str(info.Betw) ',' mat2str(info.Within)  ',' mat2str(info.nSimu) ',%i\n'], pVal.PermutCon)];
        
        pVal.GLMFFX = spm_read_vols(spm_vol(spm_select('FPList', fullfile(simuDirs{i}, 'megaFFX'), '^mega_ffx_ffx_minus_log10_p\.nii$')));
        if any(isinf(pVal.GLMFFX(:)))
            error('infinite pvals')
        end
        mystr = [mystr sprintf(['GLMFFX,' mat2str(info.nStudy) ',' mat2str(info.Betw) ',' mat2str(info.Within)  ',' mat2str(info.nSimu) ',%i\n'], pVal.GLMFFX)];
        
        pVal.Stouffers = spm_read_vols(spm_vol(spm_select('FPList', fullfile(simuDirs{i}, 'stouffers'), '^stouffers_ffx_minus_log10_p\.nii$')));
        if any(isinf(pVal.Stouffers(:)))
            error('infinite pvals')
        end
        mystr = [mystr sprintf(['Stouffers,' mat2str(info.nStudy) ',' mat2str(info.Betw) ',' mat2str(info.Within)  ',' mat2str(info.nSimu) ',%i\n'], pVal.Stouffers)];
        
        pVal.StouffersMFX = spm_read_vols(spm_vol(spm_select('FPList', fullfile(simuDirs{i}, 'stouffersMFX'), '^stouffers_rfx_minus_log10_p\.nii$')));
        if any(isinf(pVal.StouffersMFX(:)))
            error('infinite pvals')
        end
        mystr = [mystr sprintf(['StouffersMFX,' mat2str(info.nStudy) ',' mat2str(info.Betw) ',' mat2str(info.Within)  ',' mat2str(info.nSimu) ',%i\n'], pVal.StouffersMFX)];
        
        pVal.WeightedZ = spm_read_vols(spm_vol(spm_select('FPList', fullfile(simuDirs{i}, 'weightedZ'), '^weightedz_ffx_minus_log10_p\.nii$')));
        if any(isinf(pVal.WeightedZ(:)))
            error('infinite pvals')
        end
        mystr = [mystr sprintf(['WeightedZ,' mat2str(info.nStudy) ',' mat2str(info.Betw) ',' mat2str(info.Within)  ',' mat2str(info.nSimu) ',%i\n'], pVal.WeightedZ)];
        
        fprintf(fid, '%s', mystr)
        fclose(fid)
    end
    
end