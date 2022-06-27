function [global_schedule_plan, result_saves_all] = global_schedule(project_para, data_set, cpm, forward_set, local_schedule_plan, cycle)
    % global_schedule - Description
    tic
    % used parameters
    L = project_para.L;
    T = project_para.T;
    people = project_para.people;

    % used data_set
    GlobalSourceRequest = data_set.GlobalSourceRequest;
    ad = data_set.ad;
    % used cpm
    CPM = cpm.CPM;

    % 设置需迭代的变量
    % from data_set
    iter_variables.R = data_set.R; % 局部资源可用量
    iter_variables.d = data_set.d; % 工期变化储存
    iter_variables.Lgs = data_set.Lgs;
    iter_variables.skill_num = data_set.original_skill_num; %技能可用量

    % from local schedule plan
    iter_variables.local_start_times = local_schedule_plan.local_start_times; %初始局部开始时间
    iter_variables.local_end_times = local_schedule_plan.local_end_times; %初始局部结束时间
    iter_variables.resource_worktime = zeros(1, people);

    allocated_set = {}; %承载已经分配资源的活动
    global_schedule_plan = {};

    % 寻找全局资源活动列表need_global_activity
    need_global_activity = find_need_global(GlobalSourceRequest);
    seq = 0;

    for time = 1:T
        sprintf('当前循环:%d-%d-%d', cycle, seq + 1, time)
        %5.3.1  确定当前时刻需要全局资源的冲突活动列表  cur_need_global_activity
        cur_need_global_activity = find_cur_need_global_activity(iter_variables, need_global_activity, time, allocated_set); % 当前时刻需要全局资源的活动
        slst = find_slst(project_para, data_set, cpm, iter_variables); %找松弛时间
        %5.3.2  根据cur_need_global_activity确定冲突活动顺序列表
        %cur_conflict(按照项目权重、活动工期、全局需求量三个优先规则)
        if ~isempty(cur_need_global_activity)

            [cur_conflict] = find_cur_conflict(data_set, iter_variables, cur_need_global_activity, slst);
            %5.3.3  指派资源allocate_source
            [temp_variables, result] = allocate_source(data_set, iter_variables, cur_conflict, time);
            %% 六. 局部更新update_clpex_option (优先关系约束及资源约束进行局部更新）
            %6.1  通过紧前活动的最大完成时间--确定未安排活动开始时间
            temp_variables = reschedule_local_time(temp_variables, time, forward_set);
            %6.2  确定未安排活动满足资源约束
            temp_variables = reschedule_local_resource(project_para, data_set, temp_variables, time);
            % temp_total_duration = max(temp2_local_end_times, [], 2);  % 每个项目工期=每个项目的活动结束时间的最大值2行*1列
            finally_start_times = temp_variables.local_start_times - 1;
            finally_end_times = temp_variables.local_end_times - 1;
            finally_total_duration = max(finally_end_times, [], 2);

            APD = sum(finally_total_duration - ad' - CPM') / L; %1.平均项目延期
            %6.3  传递
            iter_variables = temp_variables;
            global_schedule_plan{time} = result;
            result = {};
        end % 结束当前时刻资源分配及局部更新

        %%  七.返回全局协调决策过程-判断已用的全局资源下一时刻是否会释放
        for i = 1:length(global_schedule_plan)
            temp0 = global_schedule_plan{i};

            for j = 1:length(temp0)
                temp = temp0(j);

                if ~isempty(temp{1})
                    temp1 = temp{1};
                    temp12 = temp1(2); %Resource_number
                    temp13 = temp1(3); % 活动序号
                    temp14 = temp1(4); % 释放时间

                    if isempty(allocated_set)
                        allocated_set = [allocated_set, temp13{1}]; %找到这些活动的开始时间
                    else
                        count = 0;
                        m = 1;
                        len = length(allocated_set);

                        while m <= len
                            xx = (temp13{1} == allocated_set{1, m});

                            if xx(1) == 1 && xx(2) == 1
                                break
                            else
                                count = count + 1;
                                m = m + 1;
                            end

                            if count == length(allocated_set)
                                allocated_set = [allocated_set, temp13{1}];
                            end

                        end

                    end

                    if temp14{1} == time + 1 % 如果释放时间等于当前时间
                        iter_variables.Lgs(:, temp12{1}) = data_set.Lgs(1:end, temp12{1});
                        iter_variables.skill_num(1, :) = (sum(iter_variables.Lgs ~= 0, 2))';
                    end

                end

            end

        end

        if length(allocated_set) == length(need_global_activity) || max(max(iter_variables.local_start_times)) <= time
            break
        end

        %% save
        % result_save = {iter_variables.skill_num, UF, CPM, original_total_duration, finally_total_duration, APD, ad, time};
        result_save = {iter_variables.skill_num, CPM, finally_total_duration, APD, ad, time};
        toc
        seq = seq + 1;
        result_saves(seq, :) = result_save;

    end

    result_saves_all(cycle, :) = result_save;
end
