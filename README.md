# Image-Based Meta-Analysis based on Z-Statistic

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
