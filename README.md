# zmeta_buster
Code to be used on buster to run the zmeta simulations

##### Buster
###### Installation
```
cd /storage/wmsmfe/
git clone git@github.com:cmaumet/zmeta_buster.git
```

###### Start the simulations
```
cd /storage/wmsmfe/zmeta_buster
qsub meta_sim.sh 
```

###### Check status
```
qstat
```

###### Kill a job
```
$ qstat
job-ID  prior   name       user         state submit/start at     queue                          slots ja-task-ID 
-----------------------------------------------------------------------------------------------------------------
 296698 0.56000 CamilleEx. wmsmfe       Eqw   06/20/2016 10:51:23                                    1 1-38:1
$ qdel 296698
```

###### Find non-empty error logs (replace `<job_id>`)
```
find log -type f -name "*CamilleEx.sh.e<job_id>*" -not -empty -ls
```

###### Delete empty simulations directories
```
find ../simulations -empty -type d -delete
```

###### Count number of iterations done for each simulation folder
```
find ../simulations/ -mindepth 1 -maxdepth 1 -type d | xargs -I folder sh -c 'find folder -mindepth 1 -maxdepth 1 -type d | wc -l'
```

##### Locally
###### Copy the data back
Replace `<pattern>` by an optional pattern, e.g. `nStudy25_`.
```
rsync -avzhe ssh --remove-source-files wmsmfe@buster.stats.warwick.ac.uk:/storage/wmsmfe/simulations/<pattern>* /Volumes/camille/MBIA_buster/
```
