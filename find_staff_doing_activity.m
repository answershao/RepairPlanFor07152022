function [timeoff, performing_acts_infos] = find_staff_doing_activity(iter_variables, timeoff, time)
%FIND_STAFF_DOING_ACTIVITY 此处显示有关此函数的摘要
[~, index] = ismember(timeoff.leave_staff, iter_variables.resource_num); % index为请假员工的位置，判断请假员工是否是闲置员工

% activity_num = 1;
if index == 0 %说明请假员工当前在执行活动
    % 2.找到该员工当前时刻time时正在执行的活动集合, global_schedule_plan中找,
    % 2.1找到所有的活动执行时刻的信息
    allocated_acts_information = iter_variables.allocated_acts_information;
    % 2.2 找到time 时刻正在执行的活动
    
    % all_time_infos = allocated_acts_information(:, 6); %第六项-所有时间time列出
    performing_acts_infos = {}; %储存time时刻正在执行的活动信息
    count = 0;
    
    for time_order = 1:length(allocated_acts_information)
        each_act_information =  allocated_acts_information{time_order};%每个时刻每个活动的执行信息
        if each_act_information.performing_time == time %若相等,记录行数time_order
            count = count + 1;
            performing_acts_infos{count} = each_act_information;%time 时刻正在执行所有活动的信息
            %找请假时刻请假员工正在执行的活动信息
            [~, index5] = ismember(timeoff.leave_staff, each_act_information.allocated_resource_num); %资源序号,判断请假员工是否属于执行一员,若是,找出该活动
            
            if index5 ~= 0 % 说明请假员工在执行该活动
                %time时刻请假员工所在活动的基本信息
                timeoff.leave_activity_infos.skill_value = each_act_information.skill_value;
                timeoff.leave_activity_infos.allocated_resource_num = each_act_information.allocated_resource_num;
                timeoff.leave_activity_infos.project_and_activity = each_act_information.project_and_activity;
                timeoff.leave_activity_infos.activity_start_time = each_act_information.activity_start_time;
                timeoff.leave_activity_infos.activity_end_time = each_act_information.activity_end_time;
                timeoff.leave_activity_infos.performing_time = each_act_information.performing_time;
                break
            end
        end
        
    end
    
end

end
