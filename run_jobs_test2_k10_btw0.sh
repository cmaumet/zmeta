for i in {1..5}
do
    name=test2_k10_btw0
    qsub -v wth_id=$i,k_id=2,test_id=2,btw_id=1,avgn_id=1 -N $name meta_sim.sh
done
