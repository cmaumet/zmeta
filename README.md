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

### Fig xx ROC curve for real data
From a Terminal:
```console
$ cd figures/real_data
$ R
```
Then in the R console, Fig.3 can be generated with:
```R
> source("real_data.R")
```

## Reproducing full analysis

<Instructions on how to (1) obtain raw data; (2) process it to create summary/derived data in the `results`>

<Specify precise steps, including any datasets that need to be downloaded and path variables that need to be set>
### Simulations

#### Install
 - Set the path to output folder in config_path ==> script should be updated !!
 - change the command to launch octave (as per your OAR cluster) in both run_sim and run_export scripts
 - install spm for Octave

#### Run
```console
cd src/simus
run_simulation.sh 
```

- need to run though all the sets of parameters in files within paramarrays folder

Useful commands see (in another file)
check job running 
oarstat | grep cmaumet
how to check for any error in an OAR file and how to retreive parameters from those in order to reset new jobs

#### Export results
```console
cd src/simus
run_export.sh 
```



### Real data
#### Download the data
```console
mkdir data/raw
mkdir data/raw/real_data
cd data/raw/real_data/
for i in {01..21}; do  mkdir "pain_$i.nidm"; cd "pain_$i.nidm"; curl --ssl-no-revoke -L "https://neurovault.org/collections/1425/pain_$i.nidm.zip" -o "pain_$i.nidm.zip"; unzip "pain_$i.nidm.zip"; gunzip *.gz; cd ..; done
mkdir GT
cd GT
curl -L "https://neurosynth.org/api/images/402/download/" -o pain_gt.nii.gz ; gunzip *.gz;
cd ../../../..
```

#### Run analysis
```console
cd src/real_data
```
```
> octave
> addpath('<PATH_TO_SPM>')
> pkg load statistics
> ibma_on_real_data
```

Compute the true positive rates
```console
cd src/real_data
python compute_TPR.py 
```


##### Simulations
```console
cd src/simus
```
For each parameter file found in parameterarrays (can create a custom using create_param_array), update `run_simulations.sh` to point to the parameter array file.
```console
./run_simulations.sh
```

Check if some runs have errors
cat `grep -l OAR_*.err -e error`

Retreive the corresponding parameter sets and rerun :
cat `grep -l OAR_*.err -e error` | grep params | tr "' " " " | tr "+ echo params " " " | tr -s " " > paramtorerun

 2. Export p-values into csv file in Matlab

 ```
./run_export.sh
 ```
