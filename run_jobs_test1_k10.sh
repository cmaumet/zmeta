for i in {1..5}
do
    name=test1_k10
    qsub -v wth_id=$i,k_id=2,test_id=1,btw_id=1:2,avgn_id=1 -N $name meta_sim.sh
done
