data_dir = '/Volumes/camille/pain_database';
out_dir = '/Volumes/camille/pain_spm/data';

export_dir = fullfile(out_dir, 'export');
if ~isdir(export_dir)
    mkdir(export_dir)
end

d = dir(data_dir);
isub = [d(:).isdir]; %# returns logical vector
studies = {d(isub).name}';
studies(ismember(studies,{'.','..'})) = [];

for st = 1:10    
    switch studies{st}
        case {'chantal_001', 'chantal_002', 'chantal_003', 'chantal_004'}
            cope_num = '1';
        case {'debbie_001', 'debbie_002', 'debbie_003', 'giannet_001', ...
               'giannet_002', 'giannet_003', 'giannet_004'}
            cope_num = '6';
        otherwise
            error(['Study ' studies{st} ' unknown']);
    end
    
    study_dir = fullfile(data_dir, studies{st}, 'gFeat', ...
        'flm_05mm.gfeat', ['cope' num2str(cope_num) '.feat']);
    disp(study_dir)
    disp(isdir(study_dir))
    
    out_study_dir = fullfile(out_dir, studies{st});
    if ~isdir(out_study_dir)
        mkdir(out_study_dir)
    end
    
    % Work with "filtered_func_data" rather than original copes because
    % already in standardised space    
    original_copes = fullfile(study_dir, 'filtered_func_data.nii.gz');
    copes = fullfile(out_study_dir, ['copes' cope_num '.nii.gz']);
    copyfile(original_copes, copes);    
    
    gunzip(copes)
    delete(copes)
    copes = strrep(copes, '.gz', '');

    % SPM-like scaling
    copes_scaled = fullfile(out_study_dir, ['copes' cope_num '_sc.nii']);
    copyfile(copes, copes_scaled);
    copes_scaled_img = nifti(copes_scaled);
    copes_scaled_img.dat(:) = copes_scaled_img.dat(:)/100*2.5;

    % One-sample t-test
    stat_dir = fullfile(out_study_dir, 'stat');
    if ~isdir(stat_dir)
        mkdir(stat_dir)
    end    
    
    clear matlabbatch;
    matlabbatch{1}.spm.stats.factorial_design.dir = {stat_dir};
    matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = ...
        cellstr(spm_select('ExtFPList', out_study_dir, ...
        ['^' ...
        regexptranslate('escape', spm_file(copes_scaled, 'filename')) ...
        '$']));
    matlabbatch{2}.spm.stats.fmri_est.spmmat = {fullfile(stat_dir, 'SPM.mat')};
    matlabbatch{3}.spm.stats.con.spmmat = {fullfile(stat_dir, 'SPM.mat')};
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'Group: pain';
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = 1;
    matlabbatch{4}.spm.stats.results.spmmat = {fullfile(stat_dir, 'SPM.mat')};
    matlabbatch{4}.spm.stats.results.conspec.contrasts = 1;    
    matlabbatch{4}.spm.stats.results.conspec.threshdesc = 'none';
    % FSL's default threshold, just for testing...     
    matlabbatch{4}.spm.stats.results.conspec.thresh = 0.01;
    switch studies{st}
        case {'chantal_001'}
            FWEc = 446;
        case {'chantal_002'}
            FWEc = 1470;            
        case {'chantal_003'}
            FWEc = 1408;
        case {'chantal_004'}
            FWEc = 566;            
        case {'debbie_001'}
            FWEc = 2966;
        case {'debbie_002'}
            FWEc = 32788;            
        case {'debbie_003'}
            FWEc = 566;                        
        case {'giannet_001'}
            FWEc = 533;            
        case {'giannet_002'}
            FWEc = 545;                        
        case {'giannet_003'}
            FWEc = 804;                                    
        otherwise
            error(['Study ' studies{st} ' unknown']);
    end
    matlabbatch{4}.spm.stats.results.conspec.extent = FWEc;
    % Export as NIDM-Results    
    matlabbatch{4}.spm.stats.results.print = 'nidm';
    matlabbatch{4}.spm.stats.results.write.tspm.basename = 'thresh_FWEc05';

    spm_jobman('run', matlabbatch)
    
    nidm_dir = fullfile(stat_dir, 'nidm_001');
    movefile(nidm_dir, fullfile(export_dir, [studies{st} '_nidm_001']))
   
end