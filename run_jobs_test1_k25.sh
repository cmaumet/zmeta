for i in {1..2}
do
    name=test1_k25
    qsub -v wth_id=$i,k_id=3,test_id=1,btw_id=1:2,avgn_id=1 -N $name meta_sim.sh
done
