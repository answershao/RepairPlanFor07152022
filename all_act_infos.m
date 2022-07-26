function [allocated_acts_information] = all_act_infos(schedule_solution)

conflict_acts_info = schedule_solution.conflict_acts_info;

ind = ~cellfun(@isempty, conflict_acts_info); %�ҵ��ǿ�cell����
[~, index3] = find(ind ~= 0); %index3Ϊ�ǿ�cell���ڵ�λ��
%schedule_solution.global_schedule_plan(index3);��ȡ�ǿ�cell����
allocated_acts_information = {}; %�������л����ִ��ʱ�����Ϣ
count = 0;
allocated_acts = conflict_acts_info(index3); %�������л��Ϣ

for time = 1:length(allocated_acts)
    each_act = allocated_acts{time}; %����ÿ��ʱ�̵Ļ
    
    for conflict_number = 1:length(each_act) %�ӵ�һ�����ʼ��ȡ������Ϣ
        each_act_info = each_act{conflict_number}; %��øû��������Ϣ��{����ֵ����Դ��ţ���Ŀ�[i, j]������ʱ�� temp_variables.local_end_times����ʼʱ�� temp_variables.local_start_times}
        %�����6��Ϊ�û���е�ִ��ʱ�䣨�ӿ�ʼ-������
        head = each_act_info.activity_start_time;
        tail = each_act_info.activity_end_time;
        
        for performing_time = head:tail - 1 %ÿ���allocated_acts{1}{conflict_number}��Ϣ�ĵ�5��Ϊ��ʼʱ�䣬������Ϊ����ʱ��
            count = count +1;
            each_act_info.performing_time = performing_time;
            allocated_acts_information{count} = each_act_info;
            % allocated_acts_information (count, 1:6) = [each_act_infos(1:5), {performing_time}]; %ת��ÿ�����ǰ������ϢΪcell,������Ϊִ��ʱ��
            
        end
        
    end
    
end

end
