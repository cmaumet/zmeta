#!/bin/bash
#$ -S /bin/bash
#$ -l h_rt=10:00:00
#$ -l h_vmem=4G
#$ -t 1:100
#$ -cwd
#$ -o $HOME/logs
#$ -e $HOME/logs
#$ -l h=!exec6
#$ -pe threaded 4


. /etc/profile

module add matlab
module add fsl

# matlab -nodisplay -nojvm -r CamilleEx
matlab -nojvm -nodisplay -r "maxNumCompThreads=4;my_matlab_program;quit"
#matlab -nodisplay -nojvm -r pwd

