# zmeta_buster
Code to be used on buster to run the zmeta simulations

##### Buster
###### Start the simulations
```
cd /storage/wmsmfe/zmeta_buster
qsub CamilleEx.sh 
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

##### Locally
###### Copy the data back
```
rsync -avzhe ssh --remove-source-files wmsmfe@buster.stats.warwick.ac.uk:/storage/wmsmfe/simulations/two_unb_nStudy25* /Volumes/camille/MBIA_buster/
```
