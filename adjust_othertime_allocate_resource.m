function [temp_variables, conflict_acts_info] = adjust_othertime_allocate_resource(data_set, iter_variables, performing_acts_infos, cur_conflict, time)
    %data_set
    skill_cate = data_set.skill_cate;
    GlobalSourceRequest = data_set.GlobalSourceRequest;
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

    people = length(temp_resource_worktime);
    skill_distribution = [];
    resource_serial = [];
    conflict_acts_info = {};

    for v = 1:length(cur_conflict) % 遍历冲突列表�?每个数�??
        pro = cur_conflict{1, v}(1, 1);
        act = cur_conflict{1, v}(1, 2);

        if temp_skill_num(skill_cate(pro, act)) >= GlobalSourceRequest(pro, act) %������Դ���㣬�ɷ��䣬��ǰʱ�̵�allocated_set�������
            lgs_1 = temp_Lgs(skill_cate(pro, act), :); %????????

            for resource = 1:people
                skill_distribution(resource) = length(find(temp_Lgs(:, resource) ~= 0));
                resource_serial(resource) = resource; %????
            end

            A = [lgs_1; -skill_distribution; -resource_serial]; %????-????
            [B, indexb] = sortrows(A');
            B(:, 2:3) = -B(:, 2:3);
            Maxlgs = B(:, 1)';
            skill_value = Maxlgs(1, people - GlobalSourceRequest(pro, act) + 1:end);
            allocated_resource_num = indexb(people - GlobalSourceRequest(pro, act) + 1:end);
            allocated_resource_num = allocated_resource_num';
            %         skill_value = Maxlgs(1, people:end);
            %         allocated_resource_num = indexb(people:end);

            %��ǰʱ��Ϊ���ʱ�̣������лȡunalready_workload����
            for order = 1:length(performing_acts_infos)
                each_performing_act = performing_acts_infos{order};
                project_and_activity = each_performing_act.project_and_activity;
                pro_performing = project_and_activity(1); %��Ŀ��
                act_performing = project_and_activity(2); %���

                if pro == pro_performing && act == act_performing %˵�������ʱ�̵Ļ������unalready_workload
                    unalready_workload = each_performing_act.unalready_workload;
                    temp_d(act, 1, pro) = ceil(unalready_workload / sum(skill_value));
                else
                    temp_d(act, 1, pro) = ceil(GlobalSourceRequest(pro, act) * data_set.d(act, 1, pro) / sum(skill_value)); %�������ʱ�̵Ļ
                end

            end

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
            conflict_acts_info{v} = conflict_act;

        else
            % ����һ���ƶ�����һʱ��
            temp_local_start_times(pro, act) = temp_local_start_times(pro, act) + 1;
            temp_local_end_times(pro, act) = temp_local_end_times(pro, act) + 1;

            %         %% �����Ա���뿪��������Դ�������û����ִ�У��� ����һ�� ��ǰʱ�̵�allocated_set����£��Ƴ����Ա�����ڵĻ
            %         %     allocated_set = [allocated_set, project_and_activity]; %�ҵ���Щ��Ŀ�ʼʱ��
            %         for i = 1:length(temp_allocated_set)
            %             assigned_pro_and_act = temp_allocated_set{i};
            %             assigned_pro = assigned_pro_and_act(1);
            %             assigned_act = assigned_pro_and_act(2);
            %
            %             if assigned_pro == pro && assigned_act == act
            %                 temp_allocated_set(i) = [];
            %                 break
            %             end
            %
            %         end

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


%                 [~, index_leave_skill_value] = ismember(temp_Lgs(skill_cate(pro, act), timeoff.leave_staff), timeoff.leave_activity_infos.skill_value);
%                 timeoff.leave_activity_infos.skill_value(index_leave_skill_value) = 0; %�Ƴ����Ա���ļ���ֵ
%                 skill_value = [skill_value, timeoff.leave_activity_infos.skill_value];
