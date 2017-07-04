for i in {2..3}
do
    name=test2_k50_btw0_wth2_3
    qsub -v wth_id=$i,k_id=4,test_id=2,btw_id=1,avgn_id=1 -N $name meta_sim.sh
done
