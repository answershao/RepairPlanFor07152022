function [temp_variables, conflict_acts_info] = waitfor_leavetime_schedule(project_para,data_set, iter_variables, conflict_acts_info,timeoff, forward_set, time)

%��Դ����
[temp_variables, conflict_act_info] = waitfor_leavetime_allocate_resource(data_set, iter_variables, timeoff,  time);
%%  �ֲ�����update_clpex_option (���ȹ�ϵԼ������ԴԼ�����оֲ����£�
%6.1  ͨ����ǰ���������ʱ��--ȷ��δ���Ż��ʼʱ��
temp_variables = reschedule_local_time(temp_variables, forward_set, time);
%6.2  ȷ��δ���Ż������ԴԼ��
temp_variables = reschedule_local_resource(project_para, data_set, temp_variables, time);
%6.3  ����
%         iter_variables = temp_variables;
%����ÿ��ʱ�̷���Ļ
time_conflict_acts = conflict_acts_info{time}; %timeʱ�̣�����Ļ
temp_time_conflict_acts = {};
index = 1;
for order = 1:length(time_conflict_acts)
    if timeoff.leave_activity_infos.project_and_activity == time_conflict_acts{order}.project_and_activity
        if ~isempty(conflict_act_info)
            temp_time_conflict_acts{index} = conflict_act_info{1}; %conflict_act_infoֻ���һ����ֻҪ�ҵ�����ٻ���������Ƿ�����������ٻ��λ�ã�δ���䣬Ϊ�ռ����������������Ϣ��
            index = index + 1;
        end
    else
        temp_time_conflict_acts{index} = time_conflict_acts{order}; %conflict_act_infoֻ���һ����ֻҪ�ҵ�����ٻ���������Ƿ�����������ٻ��λ�ã�δ���䣬Ϊ�ռ����������������Ϣ��
        index = index + 1;
    end
end
conflict_acts_info{time} = temp_time_conflict_acts;