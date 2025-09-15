#!/bin/bash
set -x

#OAR -q production 
#OAR -l host=1/core=1
#OAR -l walltime=2:00:00
#OAR -O OAR_%jobid%.out
#OAR -E OAR_%jobid%.err 
#OAR -n meta_sim

echo $OAR_ARRAY_INDEX,$OAR_ARRAY_ID,$1,$2,$3,$4,$5,$6 >> /home/$USER/logs/jobids.csv
echo "params " $1 " " $2 " " $3 " " $4  " " $5 " " $6

cwd=`pwd`
cd $HOME/code/zmeta_buster

tempfile=$(mktemp)

cat > $tempfile <<EOF
addpath(pwd);
addpath(fullfile(pwd, 'lib'));
pkg load statistics

meta_sim(false,fullfile(pwd, '..', 'spm12-r7771'), task_id=$1, within_id=$2, k_id=$3, test_id=$4, btw_id=$5, avgn_id=$6)
EOF

cat $tempfile

export PATH=/home/cmaumet/fsl/share/fsl/bin:$PATH
# Launch Octave 9.2
guix time-machine -C ~/.config/guix/channels_octave_9.2.0.scm -- shell octave -- octave $tempfile

rm $tempfile

cd $cwd

