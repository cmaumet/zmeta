for i in {4..5}
do
    name=test3_k50_btw0_wth4_5
    qsub -v wth_id=$i,k_id=4,test_id=3,btw_id=1,avgn_id=1 -N $name meta_sim.sh
done
