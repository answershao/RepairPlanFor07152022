function [timeoff, performing_acts_infos] = find_staff_doing_activity(iter_variables, timeoff, time)
%FIND_STAFF_DOING_ACTIVITY �˴���ʾ�йش˺�����ժҪ
[~, index] = ismember(timeoff.leave_staff, iter_variables.resource_num); % indexΪ���Ա����λ�ã��ж����Ա���Ƿ�������Ա��

% activity_num = 1;
if index == 0 %˵�����Ա����ǰ��ִ�л
    % 2.�ҵ���Ա����ǰʱ��timeʱ����ִ�еĻ����, global_schedule_plan����,
    % 2.1�ҵ����еĻִ��ʱ�̵���Ϣ
    allocated_acts_information = iter_variables.allocated_acts_information;
    % 2.2 �ҵ�time ʱ������ִ�еĻ
    
    % all_time_infos = allocated_acts_information(:, 6); %������-����ʱ��time�г�
    performing_acts_infos = {}; %����timeʱ������ִ�еĻ��Ϣ
    count = 0;
    
    for time_order = 1:length(allocated_acts_information)
        each_act_information =  allocated_acts_information{time_order};%ÿ��ʱ��ÿ�����ִ����Ϣ
        if each_act_information.performing_time == time %�����,��¼����time_order
            count = count + 1;
            performing_acts_infos{count} = each_act_information;%time ʱ������ִ�����л����Ϣ
            %�����ʱ�����Ա������ִ�еĻ��Ϣ
            [~, index5] = ismember(timeoff.leave_staff, each_act_information.allocated_resource_num); %��Դ���,�ж����Ա���Ƿ�����ִ��һԱ,����,�ҳ��û
            
            if index5 ~= 0 % ˵�����Ա����ִ�иû
                %timeʱ�����Ա�����ڻ�Ļ�����Ϣ
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
