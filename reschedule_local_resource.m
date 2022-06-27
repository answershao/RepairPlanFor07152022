function [temp_variables] = reschedule_local_resource(project_para, data_set, temp_variables, time)
    T = project_para.T;
    r = data_set.r;
    temp_R = temp_variables.R; %局部资源可用量
    temp_d = temp_variables.d;
    temp_local_start_times = temp_variables.local_start_times;
    temp_local_end_times = temp_variables.local_end_times;
    [L, num_j] = size(temp_local_end_times);

    %% 更新 所有时间的 temp2_R局部资源可用量
    for t = 1:T
        temp2_R(:, :, :, t) = temp_R;
    end

    for t = 1:time
        [row, col] = find(temp_local_start_times == t);

        for i = 1:length(row)

            for tt = t:t + temp_d(col(i), 1, row(i)) - 1
                temp2_R(:, :, row(i), tt) = temp2_R(:, :, row(i), tt) - r(col(i), :, row(i)); %活动结束时，剩余局部资源可用量 % 已安排完所有当前时间及其之前的活动
            end

        end

    end

    for i = 1:L
        temp = temp_local_start_times(i, :); % 再次确定每一个的活动的顺序，判断开始时间大于当前时间time的活动
        [value, index] = sort(temp); %value 活动的开始时间 %index 活动序号

        for act = 1:length(value)

            if value(act) > time
                t = value(act);

                while t < 1000 % 外循环，大循环
                    count = 0;

                    if temp_d(index(act), 1, i) == 0
                        break
                    end

                    for tt = t:t + temp_d(index(act), 1, i) - 1 % 内循环，工期内循环

                        if (r(index(act), 1, i) <= temp2_R(1, 1, i, tt)) && (r(index(act), 2, i) <= temp2_R(1, 2, i, tt)) && (r(index(act), 3, i) <= temp2_R(1, 3, i, tt)) %分配资源
                            count = count + 1;
                        else
                            break
                        end

                        if count == temp_d(index(act), 1, i) % 判断是否需要分配资源

                            for ttx = t:t + temp_d(index(act), 1, i) - 1
                                temp2_R(:, :, i, ttx) = temp2_R(:, :, i, ttx) - r(index(act), :, i);
                            end

                            temp_local_start_times(i, index(act)) = t;
                            temp_local_end_times(i, index(act)) = t + temp_d(index(act), 1, i);
                            t = 1000;
                        end

                    end

                    t = t + 1;
                end

            end

        end

    end

    temp_variables.local_start_times = temp_local_start_times;
    temp_variables.local_end_times = temp_local_end_times;
end
