function [temp_variables, conflict_acts_info] = adjust_othertime_schedule(project_para,data_set, iter_variables, conflict_acts_info,performing_acts_infos, forward_set,need_global_activity,cpm, time)
temp_variables = iter_variables;
%5.3.1  ȷ����ǰʱ����Ҫȫ����Դ�ĳ�ͻ��б�  cur_need_global_activity
cur_need_global_activity = find_cur_need_global_activity(iter_variables, need_global_activity, time, iter_variables.allocated_set); % ��ǰʱ����Ҫȫ����Դ�Ļ
slst = find_slst(project_para, data_set, cpm, iter_variables); %���ɳ�ʱ��
%5.3.2  ����cur_need_global_activityȷ����ͻ�˳���б�
%cur_conflict(������ĿȨ�ء�����ڡ�ȫ���������������ȹ���)
if ~isempty(cur_need_global_activity)
    [cur_conflict] = find_cur_conflict(data_set, iter_variables, cur_need_global_activity, slst);
     [temp_variables, conflict_act_info] = adjust_othertime_allocate_resource(data_set, iter_variables,performing_acts_infos, cur_conflict, time);
    %%  �ֲ�����update_clpex_option (���ȹ�ϵԼ������ԴԼ�����оֲ����£�
    %6.1  ͨ����ǰ���������ʱ��--ȷ��δ���Ż��ʼʱ��
    temp_variables = reschedule_local_time(temp_variables, forward_set, time);
    %6.2  ȷ��δ���Ż������ԴԼ��
    temp_variables = reschedule_local_resource(project_para, data_set, temp_variables, time);
    % temp_total_duration = max(temp2_local_end_times, [], 2);  % ÿ����Ŀ����=ÿ����Ŀ�Ļ����ʱ������ֵ2��*1��
    %6.3  ����
    %             iter_variables = temp_variables;
    conflict_acts_info{time} = conflict_act_info;
end