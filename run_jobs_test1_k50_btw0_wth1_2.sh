for i in {1..2}
do
    name=test1_k50_btw0
    qsub -v wth_id=$i,k_id=4,test_id=1,btw_id=1,avgn_id=1 -N $name meta_sim.sh
done
