for i in {1..3}
do
    name=test3_k50_btw1_wth1_3
    qsub -v wth_id=$i,k_id=4,test_id=3,btw_id=2,avgn_id=1 -N $name meta_sim.sh
done
