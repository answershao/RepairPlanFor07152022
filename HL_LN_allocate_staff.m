function [temp_variables, result] = HL_LN_allocate_staff(data_set, iter_variables, time)

    GlobalSourceRequest = data_set.GlobalSourceRequest;
    skill_cate = data_set.skill_cate;
    temp_d = iter_variables.d;
    temp_Lgs = iter_variables.Lgs;
    temp_skill_num = iter_variables.skill_num;
    temp_resource_worktime = iter_variables.resource_worktime;

    result = {};
    people = length(temp_resource_worktime);
    skill_distribution = [];
    resource_serial = [];

    %HL&LN��Դ�������

    %����HL&LNָ�ɲ���ָ����Դ,��һ��HL&LN����,ֱ�ӵ���
    lgs_1 = temp_Lgs (skill_cate(pro, act), avalible_staff); %�ҵ�������Щ���ܵ���Դ���
    schedule_solution.result_saves_all{time, 1}; %����Ա��

    for resource = 1:people
        skill_distribution(resource) = length(find(temp_Lgs(:, resource) ~= 0)); %
        resource_serial(resource) = resource; %��Դ���
    end

    %HL&LNָ�ɲ��ԣ�����ˮƽ��&�������ٵĲ���
    A = [lgs_1; -skill_distribution; -resource_serial];
    [B, indexb] = sortrows(A');
    B(:, 2:3) = -B(:, 2:3);
    Maxlgs = B(:, 1)';
    skill_number = Maxlgs(1, people - GlobalSourceRequest(pro, act) + 1:end); %ȷ����Դ����ֵ
    resource_number = indexb(people - GlobalSourceRequest(pro, act) + 1:end); % ȷ����Դ���

    %ÿ��ָ����Դ��Ҫ�� �Ѿ����ʱ�䡢δ���ʱ�䡢�Ѿ���ɹ�������δ��ɹ�����
    temp_d(act, 1, pro) = ceil(GlobalSourceRequest(pro, act) * .temp_d(act, 1, pro) / sum(skill_number)); %����

    for k = 1:length(resource_number) %��Դ���
        temp_resource_worktime(resource_number(k)) = temp_resource_worktime(resource_number(k)) + temp_d(act, 1, pro); %������Դ����ʱ��
    end

    temp_Lgs(:, resource_number) = 0;

    temp_skill_num = (sum(temp_Lgs ~= 0, 2))'; % 每一行不�?0的�?�算�?�? % �?能可用量更新 iter_skill_num

    temp_local_end_times(pro, act) = time + temp_d(act, 1, pro);
    result{v} = {skill_number, resource_number, [pro, act], temp_local_end_times(pro, act), temp_local_start_times(pro, act)};
