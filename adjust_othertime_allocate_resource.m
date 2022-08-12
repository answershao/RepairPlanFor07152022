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

    for v = 1:length(cur_conflict) % 閬嶅巻鍐茬獊鍒楄〃涓?姣忎釜鏁扮??
        pro = cur_conflict{1, v}(1, 1);
        act = cur_conflict{1, v}(1, 2);

        if temp_skill_num(skill_cate(pro, act)) >= GlobalSourceRequest(pro, act) %闲置资源满足，可分配，则当前时刻的allocated_set无需更新
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

            %当前时刻为请假时刻，对所有活动取unalready_workload计算
            for order = 1:length(performing_acts_infos)
                each_performing_act = performing_acts_infos{order};
                project_and_activity = each_performing_act.project_and_activity;
                pro_performing = project_and_activity(1); %项目号
                act_performing = project_and_activity(2); %活动号

                if pro == pro_performing && act == act_performing %说明是请假时刻的活动，传递unalready_workload
                    unalready_workload = each_performing_act.unalready_workload;
                    temp_d(act, 1, pro) = ceil(unalready_workload / sum(skill_value));
                else
                    temp_d(act, 1, pro) = ceil(GlobalSourceRequest(pro, act) * data_set.d(act, 1, pro) / sum(skill_value)); %不是请假时刻的活动
                end

            end

            % temp_d(j, 1, i) = ceil((GlobalSourceRequest(i, j) * iter_variables.d(j, 1, i) / sum(skill_number)) * 2) / 2; %姹傝?ユ椿鍔ㄧ殑瀹為檯宸ユ??

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
            % 策略一，移动到下一时刻
            temp_local_start_times(pro, act) = temp_local_start_times(pro, act) + 1;
            temp_local_end_times(pro, act) = temp_local_end_times(pro, act) + 1;

            %         %% 若请假员工离开后，闲置资源不足以让活动继续执行，则 策略一中 当前时刻的allocated_set需更新，移除请假员工所在的活动
            %         %     allocated_set = [allocated_set, project_and_activity]; %找到这些活动的开始时间
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
%                 timeoff.leave_activity_infos.skill_value(index_leave_skill_value) = 0; %移除请假员工的技能值
%                 skill_value = [skill_value, timeoff.leave_activity_infos.skill_value];
