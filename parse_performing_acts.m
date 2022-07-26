function [performing_acts] = parse_performing_acts(data_set, performing_acts_infos, iter_variables, time)
    % PARSE_TIMEOFF �˴���ʾ�йش˺�����ժҪ
    % �˴���ʾ��ϸ˵��
    % ������Դ%��¼�û��ֹ����ʱ���Ѿ���ɵĹ���ʱ�䡢ʣ�๤��ʱ�䡢����ɵĹ�������ʣ�๤����(��Ҫ���£�
    GlobalSourceRequest = data_set.GlobalSourceRequest;
    
    %performing_acts_infos���ν���ѭ������Ҫ��timeoff��Ϊperforming_acts_infos?
     for count = 1:size(performing_acts_infos,1)

    skill_value =  performing_acts_infos{count,1};
    project_and_activity = performing_acts_infos{count, 3};
    start_time_in_baseline = performing_acts_infos{count, 5};
    end_time_in_baseline = performing_acts_infos{count, 4};

    pro = project_and_activity(1); %��Ŀ��,��3��Ϊ�û
    act = project_and_activity(2); %���

    already_duration = time - start_time_in_baseline; % ��ֹ����ʱ���Ѿ���ɵĹ���ʱ��
    unalready_duration = end_time_in_baseline - already_duration; %��ֹ����ʱ�������Ӱ��Ļ��ʣ�๤��ʱ�䣨�������ֻ����ϣ�

    already_workload = sum(skill_value) * already_duration; % ��ֹ����ʱ���Ѿ���ɵĹ�����
    unalready_workload = GlobalSourceRequest(pro, act) *iter_variables.d(act, 1, pro) - already_workload; % %��ֹ����ʱ��ʣ�๤����

    performing_acts.pro = pro;
    performing_acts.act = act;
    performing_acts.already_duration = already_duration;
    performing_acts.already_workload = already_workload;
    performing_acts.unalready_duration = unalready_duration;
    performing_acts.unalready_workload = unalready_workload;
     end
end
