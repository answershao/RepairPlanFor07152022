function [timeoff] = parse_timeoff(data_set, timeoff)
% PARSE_TIMEOFF 此处显示有关此函数的摘要
% 此处显示详细说明
% 分配资源%记录该活动截止到该时刻已经完成的工作时间、剩余工作时间、已完成的工作量、剩余工作量(需要更新）
GlobalSourceRequest = data_set.GlobalSourceRequest;
leave_time = timeoff.leave_time;
skill_value = timeoff.leave_activity_infos.skill_value;
project_and_activity  = timeoff.leave_activity_infos.project_and_activity;
activity_start_time =  timeoff.leave_activity_infos.activity_start_time;
activity_end_time = timeoff.leave_activity_infos.activity_end_time;


pro = project_and_activity(1); %项目号,第3项为该活动
act = project_and_activity(2); %活动号

already_duration = leave_time  -activity_start_time; % 截止到该时刻已经完成的工作时间
unalready_duration =activity_end_time -  leave_time ; %截止到该时刻受请假影响的活动的剩余工作时间（用在评分机制上）

already_workload = sum(skill_value) * already_duration; % 截止到该时刻已经完成的工作量
unalready_workload = GlobalSourceRequest(pro, act) * data_set.d(act, 1, pro) - already_workload; % %截止到该时刻剩余工作量

timeoff.leave_activity_infos.pro = pro;
timeoff.leave_activity_infos.act = act;
timeoff.leave_activity_infos.already_duration = already_duration;
timeoff.leave_activity_infos.already_workload = already_workload;
timeoff.leave_activity_infos.unalready_duration = unalready_duration;
timeoff.leave_activity_infos.unalready_workload = unalready_workload;
end
