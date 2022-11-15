function [temp_variables, conflict_acts_info] = adjust_leavetime_schedule(project_para, data_set, iter_variables, conflict_acts_info, timeoff, performing_acts_infos, forward_set, cpm, alpha,cycle,time)
global max_iteration global_seed
    L = project_para.L;
 ad = data_set.ad;
      CPM = cpm.CPM;
%请假时刻资源分配
[temp_variables, conflict_act_info, cur_need_global_activity] = adjust_leavetime_allocate_resource(data_set, iter_variables, timeoff, performing_acts_infos, time);

if ~isempty(cur_need_global_activity{1}) %说明leave_time时刻，无闲置资源可分配，需要重新调整活动分配，所以赋值给cur_need_global_activity
    conflict_acts_info{time} = [];
    iterations = factorial(length(cur_need_global_activity)); %冲突活动个数的阶乘-基于冲突活动全排列机制
    L3 = cell(min(iterations, max_iteration), length(cur_need_global_activity));
    for p = 1:size(L3, 1)
        rand('seed', (global_seed + p) * cycle);
        L3(p, :) = cur_need_global_activity(randperm(length(cur_need_global_activity))); %L3-冲突活动的全排列顺序；L5-冲突项目的全排列顺序
    end
    results = {}; all_order_temp_variables = {}; all_order_objective = zeros(size(L3, 1), 1);
    
    for u = 1:size(L3, 1) % 每个顺序下的冲突活动列表  20
        sprintf('当前顺序:%d / %d', u, size(L3, 1))
        L6 = L3(u, :);
        %重新调整时与其他活动分配相同
        [temp_variables, conflict_act_info] = adjust_othertime_allocate_resource(data_set, temp_variables, performing_acts_infos, L6 , time);
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
        APD  = sum(makespan - ad' - CPM') / L;
        
        
        objective_act = APD + sum(sum(abs(finally_start_times - (iter_variables.local_start_times - 1)))) / L; %修复目标值f1：与活动有关
        objective_staff = sum(abs(temp_variables.resource_worktime - iter_variables.resource_worktime)) / project_para.people; %修复目标值f2：资源工作时间之和偏差，找iter_variables.resource_worktime？
        all_order_objective(u)  = alpha * objective_act + (1 - alpha) * objective_staff;
        
    end
    
    pos = find(all_order_objective == min(all_order_objective)); % 判断哪一个顺序目标值最小
    conflict_act_info = results{pos};
    temp_variables = all_order_temp_variables{pos};
    %6.3  传递
    iter_variables = temp_variables;
    conflict_acts_info{time} = conflict_act_info;
end % 结束当前时刻资源分配及局部更新


if isempty(cur_need_global_activity{1}) %说明conflict_act_info不为空，leave_time有闲置资源可分配
    %     ~isempty(conflict_act_info)%说明conflict_act_info不为空，leave_time有闲置资源可分配
    %%  局部更新update_clpex_option (优先关系约束及资源约束进行局部更新）
    %6.1  通过紧前活动的最大完成时间--确定未安排活动开始时间
    temp_variables = reschedule_local_time(temp_variables, forward_set, time);
    %6.2  确定未安排活动满足资源约束
    temp_variables = reschedule_local_resource(project_para, data_set, temp_variables, time);
    %6.3  传递
    %         iter_variables = temp_variables;
    %更新每个时刻分配的活动
    %     time_conflict_acts = conflict_acts_info(time);
    time_conflict_acts = conflict_acts_info{time}; %time时刻，分配的活动
    temp_time_conflict_acts = {};
    index = 1;
    
    if isempty(time_conflict_acts)
        conflict_acts_info{time} = time_conflict_acts;
    end
    
    if ~isempty(time_conflict_acts)
        ind = ~cellfun(@isempty, time_conflict_acts); %找到非空cell数组
        [~, index3] = find(ind ~= 0); %index3为非空cell所在的位置
        oral_time_conflict_acts = time_conflict_acts(index3);
        
        if ~isempty(oral_time_conflict_acts)
            
            for order = 1:length(oral_time_conflict_acts)
                
                if timeoff.leave_activity_infos.project_and_activity == oral_time_conflict_acts{order}.project_and_activity
                    
                    if ~isempty(conflict_act_info)
                        temp_time_conflict_acts{index} = conflict_act_info{1}; %conflict_act_info只存放一个，只要找到该请假活动，无论其是否分配均更新请假活动的位置（未分配，为空集，分配了则更新信息）
                        index = index + 1;
                    end
                    
                else
                    temp_time_conflict_acts{index} = oral_time_conflict_acts{order}; %conflict_act_info只存放一个，只要找到该请假活动，无论其是否分配均更新请假活动的位置（未分配，为空集，分配了则更新信息）
                    index = index + 1;
                end
                
            end
            
            conflict_acts_info{time} = temp_time_conflict_acts;
        else
            conflict_acts_info{time} = oral_time_conflict_acts;
        end
        
    end
    
end
