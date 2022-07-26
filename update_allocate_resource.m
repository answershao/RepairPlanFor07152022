function [temp_variables] = update_allocate_resource (data_set, iter_variables, timeoff, time)

    GlobalSourceRequest = data_set.GlobalSourceRequest;
    skill_cate = data_set.skill_cate;

    %temp_R = iter_variables.R;
    temp_Lgs = iter_variables.Lgs;
    % temp_skill_num = iter_variables.skill_num;
    temp_local_start_times = iter_variables.local_start_times;
    temp_local_end_times = iter_variables.local_end_times;
    temp_resource_worktime = iter_variables.resource_worktime;

    pro = timeoff.leave_activity_infos.pro;
    act = timeoff.leave_activity_infos.act;
    unalready_workload = timeoff.leave_activity_infos.unalready_workload;

    allocated_acts_information = {};
    people = length(temp_resource_worktime);
    skill_distribution = [];
    resource_serial = [];

    lgs_1 = temp_Lgs(skill_cate(pro, act), :); %????????
    % 策略一，移动到下一时刻
    for resource = 1:people
        skill_distribution(resource) = length(find(temp_Lgs(:, resource) ~= 0));
        resource_serial(resource) = resource; %????
    end

    A = [lgs_1; -skill_distribution; -resource_serial]; %????-????
    [B, indexb] = sortrows(A');
    B(:, 2:3) = -B(:, 2:3);
    Maxlgs = B(:, 1)';
    skill_number = Maxlgs(1, people:end);
    resource_number = indexb(people:end);
    temp_d(act, 1, pro) = ceil(unalready_workload / sum(skill_number)); %???????
    % temp_d(j, 1, i) = ceil((GlobalSourceRequest(i, j) * iter_variables.d(j, 1, i) / sum(skill_number)) * 2) / 2; %姹傝?ユ椿鍔ㄧ殑瀹為檯宸ユ??

    for k = 1:length(resource_number) %????????
        temp_resource_worktime(resource_number(k)) = temp_resource_worktime(resource_number(k)) + temp_d(act, 1, pro);
    end

    temp_Lgs(:, resource_number) = 0;

    temp_skill_num = (sum(temp_Lgs ~= 0, 2))'; %???????

    temp_local_end_times(pro, act) = time + temp_d(act, 1, pro);
    allocated_acts_information{v} = {skill_number, resource_number, [pro, act], temp_local_end_times(pro, act), temp_local_start_times(pro, act)};

    %temp_variables.R = temp_R;
    temp_variables.d = temp_d;
    temp_variables.Lgs = temp_Lgs;
    temp_variables.skill_num = temp_skill_num;
    temp_variables.local_start_times = temp_local_start_times;
    temp_variables.local_end_times = temp_local_end_times;
    temp_variables.resource_worktime = temp_resource_worktime;
    temp_variables.allocated_acts_information = allocated_acts_information;

end
