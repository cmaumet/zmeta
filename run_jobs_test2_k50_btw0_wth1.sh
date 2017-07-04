name=test2_k50_btw0_wth1
qsub -v wth_id=1,k_id=4,test_id=2,btw_id=1,avgn_id=1 -N $name meta_sim.sh
