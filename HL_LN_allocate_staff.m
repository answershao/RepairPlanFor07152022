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

    %HL&LN资源分配策略

    %根据HL&LN指派策略指派资源,做一个HL&LN函数,直接调用
    lgs_1 = temp_Lgs (skill_cate(pro, act), avalible_staff); %找到掌握这些技能的资源序号
    schedule_solution.result_saves_all{time, 1}; %闲置员工

    for resource = 1:people
        skill_distribution(resource) = length(find(temp_Lgs(:, resource) ~= 0)); %
        resource_serial(resource) = resource; %资源序号
    end

    %HL&LN指派策略：技能水平高&技能数少的策略
    A = [lgs_1; -skill_distribution; -resource_serial];
    [B, indexb] = sortrows(A');
    B(:, 2:3) = -B(:, 2:3);
    Maxlgs = B(:, 1)';
    skill_number = Maxlgs(1, people - GlobalSourceRequest(pro, act) + 1:end); %确定资源技能值
    resource_number = indexb(people - GlobalSourceRequest(pro, act) + 1:end); % 确定资源序号

    %每次指派资源需要： 已经完成时间、未完成时间、已经完成工作量、未完成工作量
    temp_d(act, 1, pro) = ceil(GlobalSourceRequest(pro, act) * .temp_d(act, 1, pro) / sum(skill_number)); %工期

    for k = 1:length(resource_number) %资源序号
        temp_resource_worktime(resource_number(k)) = temp_resource_worktime(resource_number(k)) + temp_d(act, 1, pro); %更新资源工作时间
    end

    temp_Lgs(:, resource_number) = 0;

    temp_skill_num = (sum(temp_Lgs ~= 0, 2))'; % 姣忎竴琛屼笉涓?0鐨勮?＄畻涓?鏁? % 鎶?鑳藉彲鐢ㄩ噺鏇存柊 iter_skill_num

    temp_local_end_times(pro, act) = time + temp_d(act, 1, pro);
    result{v} = {skill_number, resource_number, [pro, act], temp_local_end_times(pro, act), temp_local_start_times(pro, act)};
