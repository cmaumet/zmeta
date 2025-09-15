#!/bin/bash
set -x

#OAR -q production 
#OAR -l host=1/core=1
#OAR -l walltime=2:00:00
#OAR -O OAR_%jobid%.out
#OAR -E OAR_%jobid%.err 
#OAR -n run_export

echo "params " $1 

cwd=`pwd`
cd $HOME/code/zmeta

tempfile=$(mktemp)

cat > $tempfile <<EOF
addpath(pwd);
addpath(fullfile(pwd, 'lib'));

export_sim(fullfile(pwd, '..', '..', '..', 'spm12-r7771'), $1)
EOF

cat $tempfile

export PATH=/home/cmaumet/fsl/share/fsl/bin:$PATH
guix shell octave -- octave $tempfile

# rm $tempfile

cd $cwd

