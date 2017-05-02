for i in {1..5}
do
    name=test1_k25_btw1_n100
    qsub -v wth_id=$i,k_id=3,test_id=1,btw_id=2,avgn_id=2 -N $name meta_sim.sh
done
