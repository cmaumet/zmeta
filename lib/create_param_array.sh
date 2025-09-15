# bash create_param_array.sh | split -l 200 - batch_

for iter in {1..38}
do
    for wth_id in {1..5}
    do
        for k_id in {1..4}
        do
            for test_id in {1..3}
            do
                if [ $k_id -lt 3 ]; then
                    echo "$iter $wth_id $k_id $test_id 1:2 1"
                else
                    for btw_id in {1..2}
                    do
                        echo "$iter $wth_id $k_id $test_id $btw_id 1"
                    done
                fi
            done
        done
    done
done