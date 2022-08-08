function [cur_conflict] = find_cur_conflict(data_set, iter_variables, cur_need_global_activity, slst) %当前时刻冲突活动列表

    E = data_set.E;
    GlobalSourceRequest = data_set.GlobalSourceRequest;

    iter_d = iter_variables.d;

    %% 1.储存冲突活动的延期成本�?�计划工期�?�全�?资源�?求量
    %2.对三者softmax函数相加�?

    duration = zeros(1, length(cur_need_global_activity)); %计划工期�? %实际剩余工期,以上次更新的调度计划为准
    slacktime = zeros(1, length(cur_need_global_activity)); %计划松弛时间 %实际松弛时间，以上次更新的调度计划为�?
    requireskill = zeros(1, length(cur_need_global_activity)); %储存全局资源�?求量�?
    lateract = zeros(1, length(cur_need_global_activity)); %紧后活动个数

    for x = 1:length(cur_need_global_activity) %遍历cur_need_global_activity中每个数�?
        program = cur_need_global_activity{1, x}(1, 1);
        activity = cur_need_global_activity{1, x}(1, 2);
        duration(x) = iter_d(activity, :, program); %对活动工期， 1-softmax
        %找松弛时间TS
        slacktime(x) = slst(program, activity);
        requireskill(x) = GlobalSourceRequest(program, activity); %对技能需求量�? 1-softmax
        %找紧后活动个数E
        lateract(x) = sum(E(activity, :, program) ~= 0); %紧后活动个数，softmax

    end

    %工期短，松弛时间小，�?能需求量小，紧后活动个数�?

    activity = zeros(length(duration), 4); %行数代表活动数；列代表softmax分类
    pre_act = zeros(length(duration), 4); %记录每个活动每个类别的softmax�?
    softmax = zeros(1, length(duration)); %记录每个活动�?4类softmax值之和，三个1-softmax,�?个softmax

    for i = 1:length(duration)
        activity(i, :) = [exp(duration(i)), exp(slacktime(i)), exp(requireskill(i)), exp(lateract(i))];
        %activity(i,:) = [exp(duration(i)), exp(reqireskill(i)),exp(lateract(i))];
    end

    for row = 1:size(activity, 1) %3�?

        for col = 1:size(activity, 2) %4�?
            pre_act(row, col) = activity(row, col) / sum(activity(:, col));
        end

        softmax(1, row) = 3 - sum(pre_act(row, 1:3)) + pre_act(row, 4);
    end

    [D, pos] = sort(softmax, 'descend'); %对冲突活动排�?

    cur_conflict = cell(1, length(cur_need_global_activity)); %储存排序完成的冲突活�?

    for y = 1:length(pos)
        cur_conflict{y} = cur_need_global_activity{1, pos(y)};
    end

end
