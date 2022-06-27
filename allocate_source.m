function [temp_variables, result] = allocate_source(data_set, iter_variables, cur_conflict, time)
    % 函数功能�? 1种顺序的资源分配
    % skill_number = [];%�?能�??
    % resource_number = [];%执行该活动的资源序号
    GlobalSourceRequest = data_set.GlobalSourceRequest;
    skill_cate = data_set.skill_cate;

    temp_R = iter_variables.R;
    temp_d = iter_variables.d;
    temp_Lgs = iter_variables.Lgs;
    temp_skill_num = iter_variables.skill_num;
    temp_local_start_times = iter_variables.local_start_times;
    temp_local_end_times = iter_variables.local_end_times;
    temp_resource_worktime = iter_variables.resource_worktime;

    result = {};
    people = length(temp_resource_worktime);
    skill_distribution = [];
    resource_serial = [];

    for v = 1:length(cur_conflict) % 遍历冲突列表中每个数�?
        i = cur_conflict{1, v}(1, 1);
        j = cur_conflict{1, v}(1, 2);

        if GlobalSourceRequest(i, j) <= temp_skill_num(skill_cate(i, j)) % 按照顺序优先分配�?能�?�高的资�?,第一优先�?
            lgs_1 = temp_Lgs(skill_cate(i, j), :); %该技能的资源掌握值情况，�?能�??

            for resource = 1:people
                skill_distribution(resource) = length(find(temp_Lgs(:, resource) ~= 0)); %�?能数
                resource_serial(resource) = resource; %资源序号
            end

            A = [lgs_1; -skill_distribution; -resource_serial]; %�?能�?�（第一），�?能数（第�?)，工作时间（第三），资源序号（第四）
            [B, indexb] = sortrows(A'); %升序indexb指排序后对应的资源序�?
            B(:, 2:3) = -B(:, 2:3); %把该位置上的�?能数、工作时间�?�资源序号从高到低排,加负�?
            Maxlgs = B(:, 1)'; %�?能�??
            skill_number = Maxlgs(1, people - GlobalSourceRequest(i, j) + 1:end);
            resource_number = indexb(people - GlobalSourceRequest(i, j) + 1:end); % 取出执行活动的全�?资源序号
            % temp_d(j, 1, i) = ceil(GlobalSourceRequest(i, j) * iter_variables.d(j, 1, i) / sum(skill_number)); %求该活动的实际工�?
            temp_d(j, 1, i) = ceil((GlobalSourceRequest(i, j) * iter_variables.d(j, 1, i) / sum(skill_number)) * 2) / 2; %求该活动的实际工�?

            for k = 1:length(resource_number) %把安排的资源找到
                temp_resource_worktime(resource_number(k)) = temp_resource_worktime(resource_number(k)) + temp_d(j, 1, i); %找到每个资源的序�?
                %每个资源的工作时长累�?
            end

            temp_Lgs(:, resource_number) = 0;

            temp_skill_num = (sum(temp_Lgs ~= 0, 2))'; % 每一行不�?0的计算个�? % �?能可用量更新 iter_skill_num

            temp_local_end_times(i, j) = time + temp_d(j, 1, i);
            result{v} = {skill_number, resource_number, [i, j], temp_local_end_times(i, j), temp_local_start_times(i, j)};
        else
            temp_local_start_times(i, j) = temp_local_start_times(i, j) + 1;
            temp_local_end_times(i, j) = temp_local_end_times(i, j) + 1;
        end

    end

    temp_variables.R = temp_R;
    temp_variables.d = temp_d;
    temp_variables.Lgs = temp_Lgs;
    temp_variables.skill_num = temp_skill_num;
    temp_variables.local_start_times = temp_local_start_times;
    temp_variables.local_end_times = temp_local_end_times;
    temp_variables.resource_worktime = temp_resource_worktime;

end
