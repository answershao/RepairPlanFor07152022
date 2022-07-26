function [performing_acts] = parse_performing_acts(data_set, performing_acts_infos, iter_variables, time)
    % PARSE_TIMEOFF 此处显示有关此函数的摘要
    % 此处显示详细说明
    % 分配资源%记录该活动截止到该时刻已经完成的工作时间、剩余工作时间、已完成的工作量、剩余工作量(需要更新）
    GlobalSourceRequest = data_set.GlobalSourceRequest;
    
    %performing_acts_infos依次进行循环，需要把timeoff换为performing_acts_infos?
     for count = 1:size(performing_acts_infos,1)

    skill_value =  performing_acts_infos{count,1};
    project_and_activity = performing_acts_infos{count, 3};
    start_time_in_baseline = performing_acts_infos{count, 5};
    end_time_in_baseline = performing_acts_infos{count, 4};

    pro = project_and_activity(1); %项目号,第3项为该活动
    act = project_and_activity(2); %活动号

    already_duration = time - start_time_in_baseline; % 截止到该时刻已经完成的工作时间
    unalready_duration = end_time_in_baseline - already_duration; %截止到该时刻受请假影响的活动的剩余工作时间（用在评分机制上）

    already_workload = sum(skill_value) * already_duration; % 截止到该时刻已经完成的工作量
    unalready_workload = GlobalSourceRequest(pro, act) *iter_variables.d(act, 1, pro) - already_workload; % %截止到该时刻剩余工作量

    performing_acts.pro = pro;
    performing_acts.act = act;
    performing_acts.already_duration = already_duration;
    performing_acts.already_workload = already_workload;
    performing_acts.unalready_duration = unalready_duration;
    performing_acts.unalready_workload = unalready_workload;
     end
end
