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
    study_dir = fullfile(data_dir, studies{st}, 'iFeat', '05mm');
    
    d = dir(study_dir);
    isub = [d(:).isdir]; %# returns logical vector
    subjects = {d(isub).name}';
    subjects(ismember(subjects,{'.','..'})) = [];
    
    out_study_dir = fullfile(out_dir, studies{st});
    if ~isdir(out_study_dir)
        mkdir(out_study_dir)
    end
    
    subject_copes = cell(numel(subjects),1);
    for sub = 1:numel(subjects)
        subject_dir = fullfile(study_dir, subjects{sub});      
        switch studies{st}
           case {'chantal_001', 'chantal_002', 'chantal_003', 'chantal_004'}
              cope_num = '1';
           case {'debbie_001', 'debbie_002', 'debbie_003', 'giannet_001', ...
                   'giannet_002', 'giannet_003', 'giannet_004'}
              cope_num = '6';
           otherwise
              error(['Study ' studies{st} ' unknown']);
        end
        
%         original_subject_cope = fullfile(subject_dir, 'stats', ['cope' cope_num '.nii.gz']);
%         subject_cope = fullfile(out_study_dir, ['sub' num2str(sub, '%02d') '_cope' cope_num '.nii.gz']);
%         copyfile(original_subject_cope, subject_cope);
%         
%         gunzip(subject_cope)
%         delete(subject_cope)
%         subject_cope = strrep(subject_cope, '.gz', '');
%         
%         % SPM-like scaling        
%         clear matlabbatch
        subject_cope_sc = ['sub' num2str(sub, '%02d') '_cope' cope_num '_sc.nii'];
%         matlabbatch{1}.spm.util.imcalc.input = {[subject_cope ',1']};
%         matlabbatch{1}.spm.util.imcalc.output = subject_cope_sc;
%         matlabbatch{1}.spm.util.imcalc.outdir = {out_study_dir};
%         matlabbatch{1}.spm.util.imcalc.expression = 'i1/100*2.5';
%         matlabbatch{1}.spm.util.imcalc.options.dtype = 64;
%         spm_jobman('run', matlabbatch)
        
        subject_copes{sub, 1} = fullfile(out_study_dir, subject_cope_sc);
    end
    
    % One-sample t-test
    stat_dir = fullfile(out_study_dir, 'stat');
    if ~isdir(stat_dir)
        mkdir(stat_dir)
    end    
    
    clear matlabbatch;
    matlabbatch{1}.spm.stats.factorial_design.dir = {stat_dir};
    matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = subject_copes;
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
            FWEc = 94;
        case {'chantal_002'}
            FWEc = 231;            
        case {'chantal_003'}
            FWEc = 80;
        case {'chantal_004'}
            FWEc = 107;            
        case {'debbie_001'}
            FWEc = 66;
        case {'debbie_002'}
            FWEc = 60;            
        case {'debbie_003'}
            FWEc = 97;                        
        case {'giannet_001'}
            FWEc = 80;            
        case {'giannet_002'}
            FWEc = 81;                        
        case {'giannet_003'}
            FWEc = 69;                                    
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