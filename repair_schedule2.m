function [iter_variables] = repair_schedule2(project_para, data_set, cpm, forward_set,iter_variables, cycle)



allocated_set = {}; %承载已经分配资源的活动


% 寻找全局资源活动列表need_global_activity
need_global_activity = find_need_global(GlobalSourceRequest);
seq = 0;

for time =  timeoff.leave_time:T
    sprintf('当前循环:%d-%d-%d', cycle, seq + 1, time)
    %5.3.1  确定当前时刻需要全局资源的冲突活动列表  cur_need_global_activity
    cur_need_global_activity = find_cur_need_global_activity(iter_variables, need_global_activity, time, allocated_set); % 当前时刻需要全局资源的活动
    slst = find_slst(project_para, data_set, cpm, iter_variables); %找松弛时间
    %5.3.2  根据cur_need_global_activity确定冲突活动顺序列表
    %cur_conflict(按照项目权重、活动工期、全局需求量三个优先规则)
    if ~isempty(cur_need_global_activity)
        
        [cur_conflict] = find_cur_conflict(data_set, iter_variables, cur_need_global_activity, slst);
        %5.3.3  指派资源allocate_source
        [temp_variables, result] = update_allocate_resource(data_set, iter_variables, timeoff, time);
        %% 六. 局部更新update_clpex_option (优先关系约束及资源约束进行局部更新）
        %6.1  通过紧前活动的最大完成时间--确定未安排活动开始时间
        temp_variables = reschedule_local_time(temp_variables, forward_set,time);
        %6.2  确定未安排活动满足资源约束
        temp_variables = reschedule_local_resource(project_para, data_set, temp_variables, time);
        % temp_total_duration = max(temp2_local_end_times, [], 2);  % 每个项目工期=每个项目的活动结束时间的最大值2行*1列
        finally_start_times = temp_variables.local_start_times - 1;
        finally_end_times = temp_variables.local_end_times - 1;
        finally_total_duration = max(finally_end_times, [], 2);
        
        APD = sum(finally_total_duration - ad' - CPM') / L; %1.平均项目延期
        objective_act = APD + abs(finally_start_times - iter_variables.local_start_times) / L; %修复目标值f1：与活动有关
        objective_staff =  abs(iter_variables.resource_worktime-temp_variables.resource_worktime) ; %修复目标值f2：资源工作时间之和偏差，找iter_variables.resource_worktime？
        objective = (1/2) * objective_act + (1/2) * objective_staff;
        
        %6.3  传递
        iter_variables = temp_variables;
        
        iter_variables{time} = result;
        result = {};
    end % 结束当前时刻资源分配及局部更新
    
    %%  七.返回全局协调决策过程-判断已用的全局资源下一时刻是否会释放
    for i = 1:length(global_schedule_plan)
        temp0 = global_schedule_plan{i};
        
        for j = 1:length(temp0)
            temp = temp0(j);
            
            if ~isempty(temp{1})
                temp1 = temp{1};
                temp12 = temp1(2); %Resource_number
                temp13 = temp1(3); % 活动序号
                temp14 = temp1(4); % 释放时间
                
                if isempty(allocated_set)
                    allocated_set = [allocated_set, temp13{1}]; %找到这些活动的开始时间
                else
                    count = 0;
                    m = 1;
                    len = length(allocated_set);
                    
                    while m <= len
                        xx = (temp13{1} == allocated_set{1, m});
                        
                        if xx(1) == 1 && xx(2) == 1
                            break
                        else
                            count = count + 1;
                            m = m + 1;
                        end
                        
                        if count == length(allocated_set)
                            allocated_set = [allocated_set, temp13{1}];
                        end
                        
                    end
                    
                end
                
                if temp14{1} == time + 1 % 如果释放时间等于当前时间
                    iter_variables.Lgs(:, temp12{1}) = data_set.Lgs(1:end, temp12{1});
                    iter_variables.skill_num(1, :) = (sum(iter_variables.Lgs ~= 0, 2))';
                end
                
            end
            
        end
        
    end
    
    if length(allocated_set) == length(need_global_activity) || max(max(iter_variables.local_start_times)) <= time
        break
    end
    
    %记录每个时刻剩余的资源序号，该列不全为0的序号为资源序号
    resource_number = find(sum(iter_variables.Lgs, 1) ~= 0);
    %% save
    % result_save = {iter_variables.skill_num, UF, CPM, original_total_duration, finally_total_duration, APD, ad, time};
    result_save = {resource_number, iter_variables, finally_total_duration, APD, ad, time};
    toc
    seq = seq + 1;
    result_saves(seq, :) = result_save;
    
end

result_saves_all(1:seq, :, cycle) = result_saves;