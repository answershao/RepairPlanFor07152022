function [schedule_solution, constant_variables, data_set] = baseline_schedule(project_para, data_set, cycle)
    %baseline_schedule - output Schedule plan

    % used parameters
    num_j = project_para.num_j;
    L = project_para.L;

    % used data_set
    E = data_set.E;

    % new defined
    forward_set = zeros(num_j, num_j, L);

    % forward_set
    for i = 1:L
        forward_set(:, :, i) = cal_forward_set(E(:, :, i), num_j);
    end

    % cpm
    cpm = critical_path_methods(project_para, data_set);

    %% 预设到达时间ad
    ad = zeros(1, L);
    not_max_index = find(cpm.CPM ~= max(cpm.CPM));
    ad(not_max_index) = ceil(cpm.CPM(not_max_index) * 0.1);
    data_set.ad = ad;

    % utilization factor 利用系数
    util_factor = cal_utilization_factor(project_para, data_set, cpm);

    % init local schedule
    local_schedule_plan = local_schedule(project_para, data_set);

    %% constant_variables
    constant_variables.forward_set = forward_set;
    constant_variables.cpm = cpm;
    constant_variables.util_factor = util_factor;

    % global schedule
    [variables_with_time, conflict_acts_info] = global_schedule(project_para, data_set, constant_variables, local_schedule_plan, cycle);

    schedule_solution.variables_with_time = variables_with_time; %所有时刻的活动执行信息
    schedule_solution.conflict_acts_info = conflict_acts_info;

    % schedule_solution.E
    % schedule_solution.Lgs
    % schedule_solution.resource_assignment;
    % schedule_solution.local_start_times = local_schedule_plan.local_start_times;
    % schedule_solution.local_end_times = local_schedule_plan.local_end_times;

end
