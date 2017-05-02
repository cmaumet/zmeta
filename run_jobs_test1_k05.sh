for i in {1..5}
do
    name=test1_k05
    qsub -v wth_id=$i,k_id=1,test_id=1,btw_id=1:2,avgn_id=1 -N $name meta_sim.sh
done
