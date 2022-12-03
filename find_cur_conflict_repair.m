function [cur_conflict] = find_cur_conflict_repair(data_set, iter_variables, cur_need_global_activity, lft) %褰撳墠鏃跺埢鍐茬獊娲诲姩鍒楄〃

    E = data_set.E;
    GlobalSourceRequest = data_set.GlobalSourceRequest;

    iter_d = iter_variables.d;

    LFT = zeros(1, length(cur_need_global_activity));

    for x = 1:length(cur_need_global_activity)
        program = cur_need_global_activity{1, x}(1, 1);
        activity = cur_need_global_activity{1, x}(1, 2);
        LFT(x) = lft(program, activity); %最晚开始时间
    end

    [D, pos] = sort(-LFT, 'descend'); %最晚开始时间降序排序

    cur_conflict = cell(1, length(cur_need_global_activity)); %排序后的冲突活动顺序

    for y = 1:length(pos)
        cur_conflict{y} = cur_need_global_activity{1, pos(y)};
    end

end
