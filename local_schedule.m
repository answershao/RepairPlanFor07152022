function [local_schedule_plan] = local_schedule(project_para, data_set)
    % local_schedule - Description

    % proejct_para
    L = project_para.L;
    num_j = project_para.num_j;

    % new defined
    % local_start_times, multi project
    % local_start_time, single project
    local_start_times = zeros(L, num_j);
    local_end_times = zeros(L, num_j);

    for i = 1:L % CPLEX计算
        sprintf('初始局部调度进度:%d / %d', i, L)
        % 有了到达时间应该把调度结果每一行所有元素加上到达时间
        [start_time, end_time] = genetic_alg(project_para, data_set, i);

        local_start_times(i, :) = start_time + 1;
        local_end_times(i, :) = end_time + 1;
    end

    % realitic_start_times = local_start_times - 1;
    % realitic_end_times = local_end_times - 1;
    % original_total_duration = max(realitic_end_times, [], 2); %初始局部调度各项目工期最大值，与全局协调之差*单位延期成本=单项目延期成本
    % local_schedule_plan.original_total_duration = original_total_duration;

    local_schedule_plan.local_start_times = local_start_times;
    local_schedule_plan.local_end_times = local_end_times;
end
