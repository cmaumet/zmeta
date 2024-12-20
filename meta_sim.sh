#!/bin/bash

#OAR -q production 
#OAR -l host=1/core=1
#OAR -l walltime=1:00:00
#OAR -p gpu-16GB AND gpu_compute_capability_major>=5
#OAR -O OAR_%jobid%.out
#OAR -E OAR_%jobid%.err 
#OAR -n meta_sim

echo $OAR_ARRAY_INDEX,$OAR_ARRAY_ID,$1,$2,$3,$4,$5,$6 >> /home/$USER/logs/jobids.csv

source ~/.bashrc

cwd=`pwd`
cd $HOME

cat > octave_cmd.sh <<EOF
addpath(pwd);
addpath(fullfile(pwd, 'lib');
pkg load statistics

meta_sim('/home/cmaumet/simus',true,fullfile(pwd, '..', 'spm12'), $1, $2, $3, $4, $5, $6);quit"
EOF

octave octave_cmd.sh

cd $cwd
