for i in {1..5}
do
    name=test2_k25_btw1
    qsub -v wth_id=$i,k_id=3,test_id=2,btw_id=2,avgn_id=1 -N $name meta_sim.sh
done
