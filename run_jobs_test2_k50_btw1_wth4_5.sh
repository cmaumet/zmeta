for i in {4..5}
do
    name=test2_k50_btw1_wth4_5
    qsub -v wth_id=$i,k_id=4,test_id=2,btw_id=2,avgn_id=1 -N $name meta_sim.sh
done
