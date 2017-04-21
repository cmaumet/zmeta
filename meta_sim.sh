#!/bin/bash
#$ -S /bin/bash
#$ -l h_rt=04:00:00
#$ -l h_vmem=8G
#$ -t 1:38
#$ -o log/test1_k05_n20_$JOB_NAME.o$JOB_ID.$TASK_ID
#$ -e log/test1_k05_n20_$JOB_NAME.e$JOB_ID.$TASK_ID
#$ -cwd

. /etc/profile

module add matlab
module add fsl

cwd=`pwd`
cd $HOME
matlab -nodisplay -r "addpath('$cwd');addpath('$cwd/lib');meta_sim('/storage/wmsmfe/simulations',false,fullfile('$cwd', '..', 'code', 'spm12'), $wth_id);quit"

cd $cwd
