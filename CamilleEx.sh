#!/bin/bash
#$ -S /bin/bash
#$ -l h_rt=2:00:00
#$ -l h_vmem=4G
#$ -t 1:38
#$ -o log/betw1_$JOB_NAME.o$JOB_ID.$TASK_ID
#$ -e log/betw1_$JOB_NAME.e$JOB_ID.$TASK_ID
#$ -cwd
#$ -l h=!exec6
#$ -pe matlab 1


. /etc/profile

module add matlab
module add fsl

# matlab -nodisplay -nojvm -r CamilleEx
matlab -nojvm -nodisplay -r "maxNumCompThreads=4;CamilleEx('/storage/wmsmfe',false);quit"
#matlab -nodisplay -nojvm -r pwd

