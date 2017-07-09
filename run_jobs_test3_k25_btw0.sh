for i in {1..5}
do
    name=test3_k25_btw0
    qsub -v wth_id=$i,k_id=3,test_id=3,btw_id=1,avgn_id=1 -N $name meta_sim.sh
done
