function [cur_need_global_activity] = find_cur_need_global_activity(iter_variables, NeedGlobal, time, allocated_set )
    local_start_times = iter_variables.local_start_times;

    % 寻找L2
    st = zeros(1, length(NeedGlobal));

    for x = 1:length(NeedGlobal) %遍历NeedGlobal中每个数组
        i = NeedGlobal{1, x}(1, 1); %取出NeedGlobal中第x个数组的行作为项目数，
        j = NeedGlobal{1, x}(1, 2); %取出NeedGlobal中第x个数组的列作为活动数，
        % st(x)= local_start_times(i,j);%找到这些活动的开始时间
        if isempty(allocated_set)
            st(x) = local_start_times(i, j); %找到这些活动的开始时间
        else
            count = 0;
            m = 1;

            while m <= length(allocated_set)
                xx = ([i, j] == allocated_set{1, m});

                if xx(1) == 1 && xx(2) == 1
                    break
                else
                    count = count + 1;
                    m = m + 1;
                end

                if count == length(allocated_set)
                    st(x) = local_start_times(i, j); %找到这些活动的开始时间
                end

            end

        end

    end

    if ismember(time, st)
        [m, n] = find(st == time); %找到time 值对应的st中的位置
        cur_need_global_activity = cell(1, length(n));

        for y = 1:length(n)
            cur_need_global_activity{1, y} = NeedGlobal{1, n(1, y)};
        end

    else
        cur_need_global_activity = [];
    end

end
