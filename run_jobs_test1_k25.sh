for i in {1..5}
do
	name=test1_k25
    qsub -v wth_id=$i,k_id=25,test_id=1,btw_id=1:2 -N $name test${test_id}_k${k_id}_n20_ meta_sim.sh
done