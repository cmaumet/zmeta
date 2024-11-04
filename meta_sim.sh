#!/bin/bash

#OAR -q production 
#OAR -l host=1/gpu=1
#OAR -l walltime=3:00:00
#OAR -p gpu-16GB AND gpu_compute_capability_major>=5
#OAR -O OAR_%jobid%.out
#OAR -E OAR_%jobid%.err 

hostname 

# . /etc/profile

# module add matlab
# module add fsl

# cwd=`pwd`
# cd $HOME
# matlab -nodisplay -r "addpath('$cwd');addpath('$cwd/lib');meta_sim('/storage/wmsmfe/simulations',false,fullfile('$cwd', '..', 'code', 'spm12'), $wth_id, $k_id, $test_id, $btw_id, $avgn_id);quit"

# cd $cwd
