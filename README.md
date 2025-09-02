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

To cite this repository, please cite the corresponding manuscript:

"Minimal Data Needed for Valid & Accurate Image-Based fMRI Meta-Analysis" Camille Maumet, Thomas E. Nichols. doi:  bioRxiv; doi: [10.1101/048249](https://doi.org/10.1101/048249)
# Contents overview

<Summarise what's in this repository>

## Reproducing figures and tables

<Instructions on how to use summary/derived data in the `results` directory to create figures and tables>

<Specify precise steps, including any datasets that need to be downloaded and path variables that need to be set>

### Fig. 1, 2 and S1
From a Terminal:
```console
$ cd figures/small_samples
$ R
```

Then in the R console, Fig.1 can be generated with:
```R
> source("plot_small_sample.R"); plot_small_sample(1)
```

Fig.2 can be generated with:
```R
> source("plot_heteroscedasticity.R"); plot_heteroscedasticity(1)
```

Fig.S1. with:
```R
> source("plot_heterogeneity.R"); plot_heterogeneity(1)
```

### Fig. 3
From a Terminal:
```console
$ cd figures/units_mismatch
$ R
```

Then in the R console, Fig.3 can be generated with:
```R
> source("plot_simulations.R"); plot_simulation(1)
```

## Reproducing full analysis

<Instructions on how to (1) obtain raw data; (2) process it to create summary/derived data in the `results`>

<Specify precise steps, including any datasets that need to be downloaded and path variables that need to be set>
### Real data
Download the data

mkdir data/read_data
cd data/real_data

for i in {01..21}; do  mkdir "pain_$i.nidm"; cd "pain_$i.nidm"; curl --ssl-no-revoke -L "https://neurovault.org/collections/1425/pain_$i.nidm.zip" -o "pain_$i.nidm.zip"; unzip "pain_$i.nidm.zip"; cd ..; done


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
