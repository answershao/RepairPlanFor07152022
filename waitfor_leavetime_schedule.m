function [temp_variables, conflict_acts_info] = waitfor_leavetime_schedule(project_para,data_set, iter_variables, conflict_acts_info,timeoff, forward_set, time)

%资源分配
[temp_variables, conflict_act_info] = waitfor_leavetime_allocate_resource(data_set, iter_variables, timeoff,  time);
%%  局部更新update_clpex_option (优先关系约束及资源约束进行局部更新）
%6.1  通过紧前活动的最大完成时间--确定未安排活动开始时间
temp_variables = reschedule_local_time(temp_variables, forward_set, time);
%6.2  确定未安排活动满足资源约束
temp_variables = reschedule_local_resource(project_para, data_set, temp_variables, time);
%6.3  传递
%         iter_variables = temp_variables;
%更新每个时刻分配的活动
time_conflict_acts = conflict_acts_info{time}; %time时刻，分配的活动
temp_time_conflict_acts = {};
index = 1;
for order = 1:length(time_conflict_acts)
    if timeoff.leave_activity_infos.project_and_activity == time_conflict_acts{order}.project_and_activity
        if ~isempty(conflict_act_info)
            temp_time_conflict_acts{index} = conflict_act_info{1}; %conflict_act_info只存放一个，只要找到该请假活动，无论其是否分配均更新请假活动的位置（未分配，为空集，分配了则更新信息）
            index = index + 1;
        end
    else
        temp_time_conflict_acts{index} = time_conflict_acts{order}; %conflict_act_info只存放一个，只要找到该请假活动，无论其是否分配均更新请假活动的位置（未分配，为空集，分配了则更新信息）
        index = index + 1;
    end
end
conflict_acts_info{time} = temp_time_conflict_acts;