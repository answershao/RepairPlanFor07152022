function [performing_acts_infos] = parse_performing_acts(data_set, performing_acts_infos, time)
    % PARSE_TIMEOFF 此处显示有关此函数的摘要
    % 此处显示详细说明
    % 分配资源%记录该活动截止到该时刻已经完成的工作时间、剩余工作时间、已完成的工作量、剩余工作量(需要更新）
    GlobalSourceRequest = data_set.GlobalSourceRequest;
    
    %performing_acts_infos依次进行循环，需要把timeoff换为performing_acts_infos?
     for count = 1:size(performing_acts_infos,2)
each_performing_act = performing_acts_infos{count};

    skill_value =  each_performing_act.skill_value;
    allocated_resource_num = each_performing_act.allocated_resource_num;
    project_and_activity = each_performing_act.project_and_activity;
    activity_start_time = each_performing_act.activity_start_time;
   activity_end_time = each_performing_act.activity_end_time;
   performing_time = each_performing_act.performing_time;
  
    pro = project_and_activity(1); %项目号
    act = project_and_activity(2); %活动号

    already_duration = time - activity_start_time; % 截止到该时刻已经完成的工作时间
    unalready_duration = activity_end_time - time; %截止到该时刻受请假影响的活动的剩余工作时间（用在评分机制上）

    already_workload = sum(skill_value) * already_duration; % 截止到该时刻已经完成的工作量
    unalready_workload = GlobalSourceRequest(pro, act) *data_set.d(act, 1, pro) - already_workload; % %截止到该时刻剩余工作量


    each_performing_act.pro = pro;
    each_performing_act.act = act;
    each_performing_act.already_duration = already_duration;
    each_performing_act.already_workload = already_workload;
    each_performing_act.unalready_duration = unalready_duration;
    each_performing_act.unalready_workload = unalready_workload;
    
     performing_acts_infos{count} = each_performing_act;
    
     end
end
