# bash create_param_array.sh | split -l 200 - batch_

for iter in {1..38}
do
    for wth_id in {1..5}
    do
        for test_id in {1..3}
        do
            for btw_id in {1..2}
            do
                echo "$iter $wth_id 3 $test_id $btw_id 2"
            done
        done
    done
done