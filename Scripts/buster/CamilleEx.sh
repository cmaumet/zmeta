#!/bin/bash
#$ -S /bin/bash
#$ -l h_rt=00:30:00
#$ -l h_vmem=4G
#$ -t 1:100
#$ -cwd
#$ -o $HOME/logs
#$ -e $HOME/logs
#$ -l h=!exec6


. /etc/profile

module add matlab
module add fsl

matlab -nodisplay -nojvm -r CamilleEx
#matlab -nodisplay -nojvm -r pwd

