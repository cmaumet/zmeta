# Image-Based Meta-Analysis based on Z-Statistic

# Project/Paper Title

<Project description>
  
## Table of contents
   * [How to cite?](#how-to-cite)
   * [Contents overview](#contents-overview)
   * [Reproducing figures and tables](#reproducing-figures-and-tables)
      * [Table 1](#table-1)
      * [Fig. 1](#fig-1)
      * [Fig. 2](#fig-2)
   * [Reproducing full analysis](#reproducing-full-analysis)

## How to cite?

See [CITATION](CITATION).

<!--@include:./CITATION.md-->

# Contents overview

<Summarise what's in this repository>

## Reproducing figures and tables

<Instructions on how to use summary/derived data in the `results` directory to create figures and tables>

<Specify precise steps, including any datasets that need to be downloaded and path variables that need to be set>

### Table 1

### Fig. 1

### Fig. 2

## Reproducing full analysis

<Instructions on how to (1) obtain raw data; (2) process it to create summary/derived data in the `results`>

<Specify precise steps, including any datasets that need to be downloaded and path variables that need to be set>



##### Simulations
 1. Run the simulations on buster (cf. [zmeta_buster](https://github.com/cmaumet/zmeta_buster))
 2. Export p-values into csv file in Matlab

 ```
 addpath('~/Projects/Meta-analysis/dev/zmeta/Scripts/')
 addpath('~/Softs/external/spm/spm12/')
 # Replace <pattern> by optional pattern, e.g. 'nStudy25_subNumidentical_varidentical_Betw1_'
 export_full_simulations('/Volumes/camille/IBMA_simu', false, 1000, <pattern>)
 ```
 3. Get the 95% CI and plot results in R

 ```
 source('get_expected_pval_and_equiv_z.R')
 get_expected_pval_and_equiv_z('test*')
 source('multiplot.R')
 source('plot_simulations.R')
 ```
