setenv('JOB_ID','1');
setenv('QUEUE', 'local');
setenv('HOSTNAME', 'local');

for r = 1:38
    setenv('SGE_TASK_ID', num2str(r));
    for wth = 1:5 %- varying only uses the 3 first within study var setting
        meta_sim('/Volumes/camille/IBMA_simu/',false,fileparts(which('spm')), wth)
    end
end