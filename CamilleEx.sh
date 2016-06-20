#!/bin/bash
#$ -S /bin/bash
#$ -l h_rt=00:30:00
#$ -l h_vmem=4G
#$ -t 1:3
#$ -o log/betw1_$JOB_NAME.o$JOB_ID.$TASK_ID
#$ -e log/betw1_$JOB_NAME.e$JOB_ID.$TASK_ID
#$ -cwd

. /etc/profile

module add matlab
module add fsl

# matlab -nodisplay -nojvm -r CamilleEx
matlab -nojvm -nodisplay -r "CamilleEx('/storage/wmsmfe',false);quit"
#matlab -nodisplay -nojvm -r pwd

