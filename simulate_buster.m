setenv('JOB_ID','1');
setenv('QUEUE', 'local');
setenv('HOSTNAME', 'local');

for r = 1:38
    setenv('SGE_TASK_ID', num2str(r));
    for wth = 1 %:5 - varying only uses the first within study var setting
        meta_sim('/Users/cmaumet/Desktop/sim_buster/',false,fileparts(which('spm')), wth)
    end
end