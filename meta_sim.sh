#!/bin/bash
#$ -S /bin/bash
#$ -l h_rt=04:00:00
#$ -l h_vmem=8G
#$ -t 1:38
#$ -o log/test1_k25_n100_nominal_$JOB_NAME.o$JOB_ID.$TASK_ID
#$ -e log/test1_k25_n100_nominal_$JOB_NAME.e$JOB_ID.$TASK_ID
#$ -cwd

. /etc/profile

module add matlab
module add fsl

matlab -nodisplay -r "meta_sim('/storage/wmsmfe',false,fullfile(pwd, '..', 'code', 'spm12'), $wth_id);quit"

