#!/bin/bash

#OAR -q production 
#OAR -l host=1/gpu=1
#OAR -l walltime=3:00:00
#OAR -p gpu-16GB AND gpu_compute_capability_major>=5
#OAR -O OAR_%jobid%.out
#OAR -E OAR_%jobid%.err 
#OAR -n meta_sim

echo $OAR_ARRAY_INDEX,$OAR_ARRAY_ID,$1,$2,$3,$4,$5,$6 >> /home/$USER/logs/jobids.csv

export LM_LICENSE_FILE=1731@licence.irisa.fr

module load matlab/R2022a

cwd=`pwd`
cd $HOME

matlab -nodisplay -r "addpath('$cwd');addpath('$cwd/lib');meta_sim('/home/cmaumet/simus',false,fullfile('$cwd', '..', 'spm12'), $2, $3, $4, $5, $6, $7);quit"

cd $cwd
