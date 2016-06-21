# Image-Based Meta-Analysis based on Z-Statistic

##### Simulations
 1. Run the simulations on buster (cf. [zmeta_buster](https://github.com/cmaumet/zmeta_buster))
 2. Export p-values into csv file in Matlab

 ```
 export_full_simulations('/Volumes/camille/MBIA_buster', true, 1000)
 ```
 3. Get the 95% CI and plot results in R

 ```
 get_expected_pval_and_equiv_z.R
 plot_simluations()
 ```
