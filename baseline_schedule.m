function [schedule_solution] = baseline_schedule(project_para, data_set, cycle)
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

    % utilization factor 利用系数
    util_factor = cal_utilization_factor(project_para, data_set, cpm);

    % init local schedule
    local_schedule_plan = local_schedule(project_para, data_set);

    % global schedule
    [global_schedule_plan, result_saves_all] = global_schedule(project_para, data_set, cpm, forward_set, local_schedule_plan, cycle);

    % schedule_solution = global_schedule_plan;
    % schedule_solution.util_factor = util_factor;
    % schedule_solution.original_total_duration = local_schedule_plan.original_total_duration;
    % schedule_solution.E
    % schedule_solution.Lgs
    % schedule_solution.resource_assignment;
    % schedule_solution.local_start_times = local_schedule_plan.local_start_times;
    % schedule_solution.local_end_times = local_schedule_plan.local_end_times;

end
