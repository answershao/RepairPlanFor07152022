function [timeoff, performing_acts_infos] = find_staff_doing_activity(iter_allocated_variables_information,iter_allocated_acts_information, timeoff)

count = 0;
performing_acts_infos = {}; %����timeʱ������ִ�еĻ��Ϣ

eachtime_variables_info = iter_allocated_variables_information{timeoff.leave_time}; %���ʱ�̵�ʣ����Ϣ

for i = 1:length(iter_allocated_acts_information)
    eachtime_acts_info = iter_allocated_acts_information{i};

      %�������ʱ�̵Ļ��Ϣ
    if eachtime_acts_info.performing_time == timeoff.leave_time %�ҵ������ʱ�̵Ļ��Ϣ
        %         1.�ȼ�¼time ʱ������ִ�����л����Ϣ
        count = count + 1;
        performing_acts_infos{count} = eachtime_acts_info;
        
        %2.�������ʱ�����Ա������ִ�еĻ��Ϣ
        %2.1���ʱ��δ��ִ�л,����Lgs,skill_num
        if eachtime_variables_info.Lgs(:,timeoff.leave_staff)~=0 %���Ա����b��Ϊ0��˵�����ʱ��δ��ִ�л������Lgs,skill_num
            eachtime_variables_info.Lgs(:, timeoff.leave_staff) = 0;
            eachtime_variables_info.skill_num = (sum(eachtime_variables_info.Lgs ~= 0, 2))';
        else %2.2���ʱ��ִ�л����Ϣ

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