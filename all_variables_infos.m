function [allocated_variables_information]=all_variables_infos(schedule_solution)

variables_with_time = schedule_solution.variables_with_time;

allocated_variables_information = {}; %�������л����ִ��ʱ�����Ϣ

last_time_information = variables_with_time(length(variables_with_time));%���һ�����������Ϣ
last_act_endtime_info =max(max(last_time_information{1}.local_end_times));%���һ����Ľ���ʱ��
allocated_variables_information(1:length(variables_with_time)) = variables_with_time;%��1-6��Ϊvariables_with_time

for count = length(variables_with_time)+1:last_act_endtime_info%7-�յĽ���ʱ�䣬��Ϊ���һ�̵���Ϣlast_time_information
    allocated_variables_information(count) = last_time_information;
end







%
% for order = 1:length(variables_with_time)
%     each_act = variables_with_time{order}; %����ÿ��ʱ�̵Ļ
%
%     %     for conflict_number = 1:length(each_act) %�ӵ�һ�����ʼ��ȡ������Ϣ
%     %         each_act_info = each_act{conflict_number}; %��øû��������Ϣ��{����ֵ����Դ��ţ���Ŀ�[i, j]������ʱ�� temp_variables.local_end_times����ʼʱ�� temp_variables.local_start_times}
%  %�Ȱ�4��������ʾ������������˳���޹�
% %       allocated_variables_information{1} = each_act;
% %        allocated_variables_information{2} = each_act;
% %         allocated_variables_information{3} = each_act;
% %          allocated_variables_information{4} = each_act;
%     for pro = 1: project_para.L
%         for act = 2: project_para.num_j-1
%             head = each_act.local_start_times(pro,act);
%             tail = each_act.local_end_times(pro,act);
%
%             for performing_time = head:tail - 1 %ÿ���allocated_acts{1}{conflict_number}��Ϣ�ĵ�5��Ϊ��ʼʱ�䣬������Ϊ����ʱ��
%                 count = count +1;
%                 each_act.performing_time = performing_time;
%                 allocated_variables_information{count} = each_act;
% %                 variables_with_time{order} = allocated_variables_information;
%                 % allocated_acts_information (count, 1:6) = [each_act_infos(1:5), {performing_time}]; %ת��ÿ�����ǰ������ϢΪcell,������Ϊִ��ʱ��
%
%             end
%
%         end
%     end
% %      variables_with_time{order} = allocated_variables_information;
% end
%

