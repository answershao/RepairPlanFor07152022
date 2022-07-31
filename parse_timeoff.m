function [timeoff] = parse_timeoff(data_set, timeoff)
% PARSE_TIMEOFF �˴���ʾ�йش˺�����ժҪ
% �˴���ʾ��ϸ˵��
% ������Դ%��¼�û��ֹ����ʱ���Ѿ���ɵĹ���ʱ�䡢ʣ�๤��ʱ�䡢����ɵĹ�������ʣ�๤����(��Ҫ���£�
GlobalSourceRequest = data_set.GlobalSourceRequest;
leave_time = timeoff.leave_time;
skill_value = timeoff.leave_activity_infos.skill_value;
project_and_activity  = timeoff.leave_activity_infos.project_and_activity;
activity_start_time =  timeoff.leave_activity_infos.activity_start_time;
activity_end_time = timeoff.leave_activity_infos.activity_end_time;


pro = project_and_activity(1); %��Ŀ��,��3��Ϊ�û
act = project_and_activity(2); %���

already_duration = leave_time  -activity_start_time; % ��ֹ����ʱ���Ѿ���ɵĹ���ʱ��
unalready_duration =activity_end_time -  leave_time ; %��ֹ����ʱ�������Ӱ��Ļ��ʣ�๤��ʱ�䣨�������ֻ����ϣ�

already_workload = sum(skill_value) * already_duration; % ��ֹ����ʱ���Ѿ���ɵĹ�����
unalready_workload = GlobalSourceRequest(pro, act) * data_set.d(act, 1, pro) - already_workload; % %��ֹ����ʱ��ʣ�๤����

timeoff.leave_activity_infos.pro = pro;
timeoff.leave_activity_infos.act = act;
timeoff.leave_activity_infos.already_duration = already_duration;
timeoff.leave_activity_infos.already_workload = already_workload;
timeoff.leave_activity_infos.unalready_duration = unalready_duration;
timeoff.leave_activity_infos.unalready_workload = unalready_workload;
end
