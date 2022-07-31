function [timeoff, performing_acts_infos] = find_staff_doing_activity(iter_allocated_variables_information,iter_allocated_acts_information, timeoff)

count = 0;
performing_acts_infos = {}; %储存time时刻正在执行的活动信息

eachtime_variables_info = iter_allocated_variables_information{timeoff.leave_time}; %请假时刻的剩余信息

for i = 1:length(iter_allocated_acts_information)
    eachtime_acts_info = iter_allocated_acts_information{i};

      %遍历请假时刻的活动信息
    if eachtime_acts_info.performing_time == timeoff.leave_time %找到了请假时刻的活动信息
        %         1.先记录time 时刻正在执行所有活动的信息
        count = count + 1;
        performing_acts_infos{count} = eachtime_acts_info;
        
        %2.再找请假时刻请假员工正在执行的活动信息
        %2.1请假时并未在执行活动,更新Lgs,skill_num
        if eachtime_variables_info.Lgs(:,timeoff.leave_staff)~=0 %请假员工列b不为0，说明请假时并未在执行活动，更新Lgs,skill_num
            eachtime_variables_info.Lgs(:, timeoff.leave_staff) = 0;
            eachtime_variables_info.skill_num = (sum(eachtime_variables_info.Lgs ~= 0, 2))';
        else %2.2请假时在执行活动的信息

           timeoff.leave_activity_infos.skill_value = eachtime_acts_info.skill_value;
            timeoff.leave_activity_infos.allocated_resource_num = eachtime_acts_info.allocated_resource_num;
         timeoff.leave_activity_infos.project_and_activity = eachtime_acts_info.project_and_activity;
          timeoff.leave_activity_infos.activity_start_time = eachtime_acts_info.activity_start_time;
         timeoff.leave_activity_infos.activity_end_time = eachtime_acts_info.activity_end_time;
          timeoff.leave_activity_infos.performing_time = eachtime_acts_info.performing_time;
%             break
            
        end
        
    end
end
    
    
    %             timeoff.unallocated_resource_num = eachtime_act_info.unallocated_resource_num