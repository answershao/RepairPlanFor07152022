function [temp_variables, conflict_acts_info] = waitfor_othertime_schedule(project_para, data_set, iter_variables, conflict_acts_info, timeoff, forward_set, need_global_activity, cpm, alpha, cycle, time)
    global max_iteration
    L = project_para.L;
    ad = data_set.ad;
    CPM = cpm.CPM;
    temp_variables = iter_variables;
    %5.3.1  确定当前时刻需要全局资源的冲突活动列表  cur_need_global_activity
    cur_need_global_activity = find_cur_need_global_activity(iter_variables, need_global_activity, time, iter_variables.allocated_set); % 当前时刻需要全局资源的活动

    % 根据cur_need_global_activity确定冲突活动顺序列表-冲突活动排列机制

    if ~isempty(cur_need_global_activity)

        iterations = factorial(length(cur_need_global_activity)); %冲突活动个数的阶乘-基于冲突活动全排列机制
        L3 = cell(min(iterations, max_iteration), length(cur_need_global_activity));

        for p = 1:size(L3, 1)
            rand('seed', (p) * cycle);
            L3(p, :) = cur_need_global_activity(randperm(length(cur_need_global_activity))); %L3-冲突活动的全排列顺序；L5-冲突项目的全排列顺序
        end

        results = {}; all_order_temp_variables = {}; all_order_objective = zeros(size(L3, 1), 1);

        for u = 1:size(L3, 1) % 每个顺序下的冲突活动列表  20
            sprintf('当前顺序:%d / %d', u, size(L3, 1))
            L6 = L3(u, :);
            [temp_variables, conflict_act_info] = waitfor_othertime_allocate_resource(data_set, iter_variables, timeoff, L6, time);
            %%  局部更新update_clpex_option (优先关系约束及资源约束进行局部更新）
            %6.1  通过紧前活动的最大完成时间--确定未安排活动开始时间
            temp_variables = reschedule_local_time(temp_variables, forward_set, time);
            %6.2  确定未安排活动满足资源约束
            temp_variables = reschedule_local_resource(project_para, data_set, temp_variables, time);

            %把所有顺序u的统计在一起
            results {u} = conflict_act_info;
            all_order_temp_variables{u} = temp_variables;

            finally_start_times = temp_variables.local_start_times - 1;
            finally_end_times = temp_variables.local_end_times - 1;
            makespan = max(finally_end_times, [], 2);
            APD = sum(makespan - ad' - CPM') / L;

            %          objective_act = abs(APD - iter_variables.objective);
            %         objective_start_time = sum(sum(abs(finally_start_times - (iter_variables.local_start_times - 1)))) / L; %修复目标值f1：与活动有关
            %         all_order_objective(u)  =  alpha * objective_act + (1 - alpha) * objective_start_time;

            objective_act = APD + sum(sum(abs(finally_start_times - (iter_variables.local_start_times - 1)))) / L; %修复目标值f1：与活动有关
            objective_staff = sum(abs(temp_variables.resource_worktime - iter_variables.resource_worktime)) / project_para.people; %修复目标值f2：资源工作时间之和偏差，找iter_variables.resource_worktime？
            all_order_objective(u) = alpha * objective_act + (1 - alpha) * objective_staff;

        end

        pos = find(all_order_objective == min(all_order_objective)); % 判断哪一个顺序目标值最小
        conflict_act_info = results{pos};
        temp_variables = all_order_temp_variables{pos};
        %6.3  传递
        iter_variables = temp_variables;
        conflict_acts_info{time} = conflict_act_info;
    end % 结束当前时刻资源分配及局部更新

    %
    % temp_variables = iter_variables;
    % %5.3.1  确定当前时刻需要全局资源的冲突活动列表  cur_need_global_activity
    % cur_need_global_activity = find_cur_need_global_activity(iter_variables, need_global_activity, time, iter_variables.allocated_set); % 当前时刻需要全局资源的活动
    % slst = find_slst(project_para, data_set, cpm, iter_variables); %找松弛时间
    % %5.3.2  根据cur_need_global_activity确定冲突活动顺序列表
    % %cur_conflict(按照项目权重、活动工期、全局需求量三个优先规则)
    % if ~isempty(cur_need_global_activity)
    %     [cur_conflict] = find_cur_conflict(data_set, iter_variables, cur_need_global_activity, slst);
    %     [temp_variables, conflict_act_info] = waitfor_othertime_allocate_resource(data_set, iter_variables, timeoff, cur_conflict, time);
    %     %%  局部更新update_clpex_option (优先关系约束及资源约束进行局部更新）
    %     %6.1  通过紧前活动的最大完成时间--确定未安排活动开始时间
    %     temp_variables = reschedule_local_time(temp_variables, forward_set, time);
    %     %6.2  确定未安排活动满足资源约束
    %     temp_variables = reschedule_local_resource(project_para, data_set, temp_variables, time);
    %     % temp_total_duration = max(temp2_local_end_times, [], 2);  % 每个项目工期=每个项目的活动结束时间的最大值2行*1列
    %     %6.3  传递
    %     %             iter_variables = temp_variables;
    %     conflict_acts_info{time} = conflict_act_info;
    % end
