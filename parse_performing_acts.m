function [performing_acts_infos] = parse_performing_acts(data_set, performing_acts_infos, time)
    % PARSE_TIMEOFF �˴���ʾ�йش˺�����ժҪ
    % �˴���ʾ��ϸ˵��
    % ������Դ%��¼�û��ֹ����ʱ���Ѿ���ɵĹ���ʱ�䡢ʣ�๤��ʱ�䡢����ɵĹ�������ʣ�๤����(��Ҫ���£�
    GlobalSourceRequest = data_set.GlobalSourceRequest;
    
    %performing_acts_infos���ν���ѭ������Ҫ��timeoff��Ϊperforming_acts_infos?
     for count = 1:size(performing_acts_infos,2)
each_performing_act = performing_acts_infos{count};

    skill_value =  each_performing_act.skill_value;
    allocated_resource_num = each_performing_act.allocated_resource_num;
    project_and_activity = each_performing_act.project_and_activity;
    activity_start_time = each_performing_act.activity_start_time;
   activity_end_time = each_performing_act.activity_end_time;
   performing_time = each_performing_act.performing_time;
  
    pro = project_and_activity(1); %��Ŀ��
    act = project_and_activity(2); %���

    already_duration = time - activity_start_time; % ��ֹ����ʱ���Ѿ���ɵĹ���ʱ��
    unalready_duration = activity_end_time - time; %��ֹ����ʱ�������Ӱ��Ļ��ʣ�๤��ʱ�䣨�������ֻ����ϣ�

    already_workload = sum(skill_value) * already_duration; % ��ֹ����ʱ���Ѿ���ɵĹ�����
    unalready_workload = GlobalSourceRequest(pro, act) *data_set.d(act, 1, pro) - already_workload; % %��ֹ����ʱ��ʣ�๤����


    each_performing_act.pro = pro;
    each_performing_act.act = act;
    each_performing_act.already_duration = already_duration;
    each_performing_act.already_workload = already_workload;
    each_performing_act.unalready_duration = unalready_duration;
    each_performing_act.unalready_workload = unalready_workload;
    
     performing_acts_infos{count} = each_performing_act;
    
     end
end
