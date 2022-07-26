function [iter_variables, objective] = wait_for_sloving(project_para, data_set,original_variables, conflict_acts_info, iter_variables, constant_variables, timeoff)

%constant_variables
cpm =  constant_variables.cpm;
forward_set = constant_variables.forward_set;

% timeoff
leave_time = timeoff.leave_time;
pro = timeoff.leave_activity_infos.pro;
act = timeoff.leave_activity_infos.act;

% iter_variables
temp_variables = iter_variables;

 %% 若请假员工离开后，闲置资源不足以让活动继续执行，则 策略一中 当前时刻的allocated_set需更新，移除请假员工所在的活动
%     allocated_set = [allocated_set, project_and_activity]; %找到这些活动的开始时间
 for i = 1:length( iter_variables.allocated_set)
     assigned_pro_and_act =  iter_variables.allocated_set {i} ;
     assigned_pro = assigned_pro_and_act(1);
     assigned_act = assigned_pro_and_act(2);
     if assigned_pro == pro && assigned_act ==act
     iter_variables.allocated_set(i) = [];
     end
 end

%策略一，无闲置资源就移到下一时刻
temp_variables.local_start_times(pro, act) = temp_variables.local_start_times(pro, act) + 1;
temp_variables.local_end_times(pro, act) = temp_variables.local_end_times(pro, act) +1;

%更新紧后活动的开始时间、结束时间，类似局部更新
%%  局部更新update_clpex_option (优先关系约束及资源约束进行局部更新）
%6.1  通过紧前活动的最大完成时间--确定未安排活动开始时间
temp_variables = reschedule_local_time(temp_variables,forward_set, leave_time);
%6.2  确定未安排活动满足资源约束
temp_variables = reschedule_local_resource(project_para, data_set, temp_variables, leave_time);

%% 七.释放函数
%% 返回全局协调决策过程-判断已用的全局资源下一时刻是否会释放
% allocated_acts_information = temp_variables.allocated_acts_information;

for i = leave_time:length(conflict_acts_info)
    temp0 = conflict_acts_info{i};
    for j = 1:length(temp0)
        temp = temp0{j};
        
        if ~isempty(temp)
            allocated_resource_num = temp.allocated_resource_num; %resource_num
%             project_and_activity = temp.project_and_activity; % 活动序号
            released_time = temp.activity_end_time; % 释放时间
            
            if released_time ==  leave_time  + 1 % 如果释放时间等于当前时间
                iter_variables.Lgs(:, allocated_resource_num) = data_set.Lgs(1:end, allocated_resource_num);
                iter_variables.skill_num(1, :) = (sum(iter_variables.Lgs ~= 0, 2))';
            end
            
            %记录每个时刻剩余的资源序号，该列不全为0的序号为资源序号
            temp_variables.resource_num = find(sum(temp_variables.Lgs, 1) ~= 0);
        end
        
    end
end   
    
    % repair schedule
    %从请假时刻+1开始继续往下循环，直到完成所有时刻的调度计划（后续计划按照无请假员工调度的）
    [iter_variables,objective] = repair_schedule1(project_para, data_set,original_variables, temp_variables, forward_set ,cpm,leave_time);
end

% if length(allocated_set) == length(need_global_activity) || max(max(iter_variables.local_start_times)) <= time
%     break
% end

%% save
% result_save = {iter_variables.skill_num, UF, CPM, original_total_duration, finally_total_duration, APD, ad, time};
% result_save = {resource_number, iter_variables, finally_total_duration, APD, ad, time};
% toc
% seq = seq + 1;
% result_saves(seq, :) = result_save;

% temp_R = iter_variables.R; % 局部资源可用量
% temp_d = iter_variables.d; % 工期变化储存
% temp_Lgs = iter_variables.Lgs;
% temp_skill_num = iter_variables.skill_num; %技能可用量
% temp_local_start_times = iter_variables.local_start_times; %初始局部开始时间
% temp_local_end_times = iter_variables.local_end_times; %初始局部结束时间
% temp_allocated_acts_information = iter_variables.allocated_acts_information;
% temp_resource_num = iter_variables.resource_num;
% temp_makespan = iter_variables.makespan;
% temp_APD = iter_variables.APD;
% temp_ad = iter_variables.ad;
% temp_resource_worktime = zeros(1, project_para.people);

%6.3  传递
% iter_variables = temp_variables;

% temp_total_duration = max(temp2_local_end_times, [], 2);  % 每个项目工期=每个项目的活动结束时间的最大值2行*1列
% finally_start_times = temp_variables.local_start_times - 1;
% finally_end_times = temp_variables.local_end_times - 1;
% finally_total_duration = max(finally_end_times, [], 2);

% APD = sum(finally_total_duration - ad' - CPM') / L; %1.平均项目延期
% objective_act = APD + abs(finally_start_times - iter_variables.local_start_times) / L; %修复目标值f1：与活动有关
% objective_staff = abs(iter_variables.resource_worktime - temp_variables.resource_worktime); %修复目标值f2：资源工作时间之和偏差，找iter_variables.resource_worktime？
% objective = (1/2) * objective_act + (1/2) * objective_staff;
