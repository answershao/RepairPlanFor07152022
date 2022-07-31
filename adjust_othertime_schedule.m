function [temp_variables, conflict_acts_info] = adjust_othertime_schedule(project_para,data_set, iter_variables, conflict_acts_info,performing_acts_infos, forward_set,need_global_activity,cpm, time)
temp_variables = iter_variables;
%5.3.1  确定当前时刻需要全局资源的冲突活动列表  cur_need_global_activity
cur_need_global_activity = find_cur_need_global_activity(iter_variables, need_global_activity, time, iter_variables.allocated_set); % 当前时刻需要全局资源的活动
slst = find_slst(project_para, data_set, cpm, iter_variables); %找松弛时间
%5.3.2  根据cur_need_global_activity确定冲突活动顺序列表
%cur_conflict(按照项目权重、活动工期、全局需求量三个优先规则)
if ~isempty(cur_need_global_activity)
    [cur_conflict] = find_cur_conflict(data_set, iter_variables, cur_need_global_activity, slst);
     [temp_variables, conflict_act_info] = adjust_othertime_allocate_resource(data_set, iter_variables,performing_acts_infos, cur_conflict, time);
    %%  局部更新update_clpex_option (优先关系约束及资源约束进行局部更新）
    %6.1  通过紧前活动的最大完成时间--确定未安排活动开始时间
    temp_variables = reschedule_local_time(temp_variables, forward_set, time);
    %6.2  确定未安排活动满足资源约束
    temp_variables = reschedule_local_resource(project_para, data_set, temp_variables, time);
    % temp_total_duration = max(temp2_local_end_times, [], 2);  % 每个项目工期=每个项目的活动结束时间的最大值2行*1列
    %6.3  传递
    %             iter_variables = temp_variables;
    conflict_acts_info{time} = conflict_act_info;
end