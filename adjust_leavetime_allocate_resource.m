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
    other_staff = timeoff.leave_activity_infos.allocated_resource_num(index_other_staff)'; %基线中剩余的员工

    cur_need_global_activity = cell(1, size(performing_acts_infos, 1));

    %%  leave_time时刻请假活动先分配资源
    if temp_skill_num(skill_cate(pro, act)) >= 1 %闲置资源满足，可分配，则当前时刻的allocated_set无需更新
        lgs_1 = temp_Lgs(skill_cate(pro, act), :); %符合要求的技能值

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

        %请假员工离开，需要旧人+新人的技能值之和
        other_staff_skill_value = temp_Lgs(skill_cate(pro, act), other_staff);
        skill_value = [skill_value, other_staff_skill_value]; %旧人+新人的技能值
        allocated_resource_num = [allocated_resource_num, other_staff]; %人员分配=旧人+新人
        %只要 pro = timeoff.leave_activity_infos.pro&& act = timeoff.leave_activity_infos.act;
        unalready_workload = timeoff.leave_activity_infos.unalready_workload; %对于请假活动来说，每次新分配资源后，都用剩余工作量/（旧人+新人）技能值之和

        temp_d(act, 1, pro) = ceil(unalready_workload / sum(skill_value)); %基线中已经指派的剩余的员工+新替代的1人 的技能值
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
        conflict_acts_info{1} = conflict_act; %因为任何时刻，只能是存一个活动

    else
        %% 所有在执行的活动暂停，重新分配
        %cur_need_global_activity = cell(1, size(performing_acts_infos, 1));
        %1.未完成部分更新（开始结束时间、未完成的工期），调出，根据cur_conflict重新分配资源，再根据othertime_allocate
        for order = 1:length(performing_acts_infos)
            each_performing_act = performing_acts_infos{order};
            project_and_activity = each_performing_act.project_and_activity;

            pro_performing = project_and_activity(1); %项目号
            act_performing = project_and_activity(2); %活动号

            cur_need_global_activity{order} = [pro_performing, act_performing]; %便于后续进行冲突活动顺序确定
            %更新请假时刻所有在执行的活动开始结束时间
            gap = time - temp_local_start_times(pro_performing, act_performing);
            temp_local_start_times(pro_performing, act_performing) = time;
            temp_local_end_times(pro_performing, act_performing) = temp_local_end_times(pro_performing, act_performing) + gap;

            %更新请假时刻的所有在执行的活动工期，请假活动的工期在传之前已经更新了
            temp_d(act_performing, 1, pro_performing)= each_performing_act.unalready_duration; %员工请假离开后， 活动的剩余工期需要更新

            %2.闲置资源不足，该时刻所有执行的活动已分配的资源释放
            if pro_performing == pro && act_performing == act %3.1请假活动中除请假人员外的其他人员释放
                temp_Lgs(:, other_staff) = data_set.Lgs(1:end, other_staff);
                temp_skill_num(1, :) = (sum(temp_Lgs ~= 0, 2))';
            else %3.2非请假活动中所已经分配的人员释放
                temp_Lgs(:, each_performing_act.allocated_resource_num) = data_set.Lgs(1:end, each_performing_act.allocated_resource_num);
                temp_skill_num(1, :) = (sum(temp_Lgs ~= 0, 2))'; %???????
            end

            %3.allocated_set需更新，移除当前时刻在执行的所有活动
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
