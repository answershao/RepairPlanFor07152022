function [temp_variables, conflict_acts_info, cur_need_global_activity] = adjust_leavetime_allocate_resource(data_set, iter_variables, timeoff, performing_acts_infos, time)

    %data_set
    skill_cate = data_set.skill_cate;
    % GlobalSourceRequest = data_set.GlobalSourceRequest;
    %iter_variables
    temp_R = iter_variables.R;
    temp_d = iter_variables.d;
    temp_local_start_times = iter_variables.local_start_times;
    temp_local_end_times = iter_variables.local_end_times;
    temp_variables.allocated_set = iter_variables.allocated_set;
    temp_Lgs = iter_variables.Lgs;
    temp_skill_num = iter_variables.skill_num;
    temp_resource_worktime = iter_variables.resource_worktime;
    temp_allocated_set = iter_variables.allocated_set;
    %timeoff
    % leave_time = timeoff.leave_time;
    % pro = timeoff.leave_activity_infos.pro;
    % act = timeoff.leave_activity_infos.act;
    pro = timeoff.leave_activity_infos.pro;
    act = timeoff.leave_activity_infos.act;

    people = length(temp_resource_worktime);
    skill_distribution = [];
    resource_serial = [];
    conflict_acts_info = {};

    [~, index_other_staff] = find(timeoff.leave_activity_infos.allocated_resource_num' ~= timeoff.leave_staff);
    other_staff = timeoff.leave_activity_infos.allocated_resource_num(index_other_staff)'; %������ʣ���Ա��

    cur_need_global_activity = cell(1, size(performing_acts_infos, 1));

    %%  leave_timeʱ����ٻ�ȷ�����Դ
    if temp_skill_num(skill_cate(pro, act)) >= 1 %������Դ���㣬�ɷ��䣬��ǰʱ�̵�allocated_set�������
        lgs_1 = temp_Lgs(skill_cate(pro, act), :); %����Ҫ��ļ���ֵ

        for resource = 1:people
            skill_distribution(resource) = length(find(temp_Lgs(:, resource) ~= 0));
            resource_serial(resource) = resource; %????
        end

        A = [lgs_1; -skill_distribution; -resource_serial]; %????-????
        [B, indexb] = sortrows(A');
        B(:, 2:3) = -B(:, 2:3);
        Maxlgs = B(:, 1)';
        skill_value = Maxlgs(1, people:end);
        allocated_resource_num = indexb(people:end);

        %���Ա���뿪����Ҫ����+���˵ļ���ֵ֮��
        other_staff_skill_value = temp_Lgs(skill_cate(pro, act), other_staff);
        skill_value = [skill_value, other_staff_skill_value]; %����+���˵ļ���ֵ
        allocated_resource_num = [allocated_resource_num, other_staff]; %��Ա����=����+����
        %ֻҪ pro = timeoff.leave_activity_infos.pro&& act = timeoff.leave_activity_infos.act;
        unalready_workload = timeoff.leave_activity_infos.unalready_workload; %������ٻ��˵��ÿ���·�����Դ�󣬶���ʣ�๤����/������+���ˣ�����ֵ֮��

        temp_d(act, 1, pro) = ceil(unalready_workload / sum(skill_value)); %�������Ѿ�ָ�ɵ�ʣ���Ա��+�������1�� �ļ���ֵ
        % temp_d(j, 1, i) = ceil((GlobalSourceRequest(i, j) * iter_variables.d(j, 1, i) / sum(skill_number)) * 2) / 2; %求�?�活动的实际工�??

        for k = 1:length(allocated_resource_num) %????????
            temp_resource_worktime(allocated_resource_num (k)) = temp_resource_worktime(allocated_resource_num (k)) + temp_d(act, 1, pro);
        end

        temp_Lgs(:, allocated_resource_num) = 0;
        temp_skill_num = (sum(temp_Lgs ~= 0, 2))'; %???????
        temp_local_end_times(pro, act) = time + temp_d(act, 1, pro);

        conflict_act.skill_value = skill_value;
        conflict_act.allocated_resource_num = allocated_resource_num;
        conflict_act.project_and_activity = [pro, act];
        conflict_act.activity_start_time = temp_local_start_times(pro, act);
        conflict_act.activity_end_time = temp_local_end_times(pro, act);
        conflict_acts_info{1} = conflict_act; %��Ϊ�κ�ʱ�̣�ֻ���Ǵ�һ���

    else
        %% ������ִ�еĻ��ͣ�����·���
        %cur_need_global_activity = cell(1, size(performing_acts_infos, 1));
        %1.δ��ɲ��ָ��£���ʼ����ʱ�䡢δ��ɵĹ��ڣ�������������cur_conflict���·�����Դ���ٸ���othertime_allocate
        for order = 1:length(performing_acts_infos)
            each_performing_act = performing_acts_infos{order};
            project_and_activity = each_performing_act.project_and_activity;

            pro_performing = project_and_activity(1); %��Ŀ��
            act_performing = project_and_activity(2); %���

            cur_need_global_activity{order} = [pro_performing, act_performing]; %���ں������г�ͻ�˳��ȷ��
            %�������ʱ��������ִ�еĻ��ʼ����ʱ��
            gap = time - temp_local_start_times(pro_performing, act_performing);
            temp_local_start_times(pro_performing, act_performing) = time;
            temp_local_end_times(pro_performing, act_performing) = temp_local_end_times(pro_performing, act_performing) + gap;

            %�������ʱ�̵�������ִ�еĻ���ڣ���ٻ�Ĺ����ڴ�֮ǰ�Ѿ�������
            temp_d(act_performing, 1, pro_performing)= each_performing_act.unalready_duration; %Ա������뿪�� ���ʣ�๤����Ҫ����

            %2.������Դ���㣬��ʱ������ִ�еĻ�ѷ������Դ�ͷ�
            if pro_performing == pro && act_performing == act %3.1��ٻ�г������Ա���������Ա�ͷ�
                temp_Lgs(:, other_staff) = data_set.Lgs(1:end, other_staff);
                temp_skill_num(1, :) = (sum(temp_Lgs ~= 0, 2))';
            else %3.2����ٻ�����Ѿ��������Ա�ͷ�
                temp_Lgs(:, each_performing_act.allocated_resource_num) = data_set.Lgs(1:end, each_performing_act.allocated_resource_num);
                temp_skill_num(1, :) = (sum(temp_Lgs ~= 0, 2))'; %???????
            end

            %3.allocated_set����£��Ƴ���ǰʱ����ִ�е����л
            for i = 1:length(temp_allocated_set)
                assigned_pro_and_act = temp_allocated_set{i};
                assigned_pro = assigned_pro_and_act(1);
                assigned_act = assigned_pro_and_act(2);

                if assigned_pro == pro_performing && assigned_act == act_performing
                    temp_allocated_set(i) = [];
                    break
                end

            end

        end

    end

    temp_variables.R = temp_R;
    temp_variables.d = temp_d;
    temp_variables.local_start_times = temp_local_start_times;
    temp_variables.local_end_times = temp_local_end_times;
    temp_variables.Lgs = temp_Lgs;
    temp_variables.skill_num = temp_skill_num;
    temp_variables.resource_worktime = temp_resource_worktime;
    temp_variables.allocated_set = temp_allocated_set;
end
