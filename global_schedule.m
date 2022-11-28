function [variables_with_time, conflict_acts_info] = global_schedule(project_para, data_set, constant_variables, local_schedule_plan, cycle)
    % global_schedule - Description
    tic
    % used parameters
    L = project_para.L;
    T = project_para.T;
    people = project_para.people;

    % used data_set
    GlobalSourceRequest = data_set.GlobalSourceRequest;
    ad = data_set.ad;

    % constant_variables
    % used cpm
    cpm = constant_variables.cpm;
    CPM = cpm.CPM;
    forward_set = constant_variables.forward_set;

    % 设置需迭代的变量
    % from data_set
    iter_variables.R = data_set.R; % 局部资源可用量
    iter_variables.d = data_set.d; % 工期变化储存

    % from local schedule plan
    iter_variables.local_start_times = local_schedule_plan.local_start_times; % 初始局部开始时间
    iter_variables.local_end_times = local_schedule_plan.local_end_times; % 初始局部结束时间

    %与资源技能相关的
    iter_variables.Lgs = data_set.Lgs;
    iter_variables.skill_num = data_set.original_skill_num; %技能可用量
    iter_variables.resource_worktime = zeros(1, people);
    %
    %     conflict_act.Lgs = data_set.Lgs;
    %     conflict_act.skill_num = data_set.original_skill_num; %技能可用量
    %     conflict_act.resource_worktime = zeros(1, people);

    % 寻找全局资源活动列表need_global_activity
    need_global_activity = find_need_global(GlobalSourceRequest);
    seq = 0;

    %     allocated_set_with_time = {};
    allocated_set = {}; % 承载已经分配资源的活动
    variables_with_time = {};
    conflict_acts_info = {};

    for time = 1:T
        sprintf('当前循环:%d-%d-%d', cycle, seq + 1, time)
        %5.3.1  确定当前时刻需要全局资源的冲突活动列表  cur_need_global_activity
        cur_need_global_activity = find_cur_need_global_activity(iter_variables, need_global_activity, time, allocated_set); % 当前时刻需要全局资源的活动
        slst = find_slst(project_para, data_set, cpm, iter_variables); %找松弛时间
        %5.3.2  根据cur_need_global_activity确定冲突活动顺序列表
        %cur_conflict(按照项目权重、活动工期、全局需求量三个优先规则)
        if ~isempty(cur_need_global_activity)

            [cur_conflict] = find_cur_conflict_baseline(data_set, iter_variables, cur_need_global_activity, slst);
            %5.3.3  指派资源allocate_source
            [temp_variables, conflict_act_info] = allocate_source(data_set, iter_variables, cur_conflict, time);
            %% 六. 局部更新update_clpex_option (优先关系约束及资源约束进行局部更新）
            %6.1  通过紧前活动的最大完成时间--确定未安排活动开始时间
            temp_variables = reschedule_local_time(temp_variables, forward_set, time);
            %6.2  确定未安排活动满足资源约束
            temp_variables = reschedule_local_resource(project_para, data_set, temp_variables, time);
            % temp_total_duration = max(temp2_local_end_times, [], 2);  % 每个项目工期=每个项目的活动结束时间的最大值2行*1列
            finally_start_times = temp_variables.local_start_times - 1;
            finally_end_times = temp_variables.local_end_times - 1;
            makespan = max(finally_end_times, [], 2);

            objective = sum(makespan - ad' - CPM') / L; %1.平均项目延期
            %6.3  传递
            iter_variables = temp_variables;
            conflict_acts_info{time} = conflict_act_info;
        end % 结束当前时刻资源分配及局部更新

        %%  七.返回全局协调决策过程-判断已用的全局资源下一时刻是否会释放
        for i = 1:length(conflict_acts_info)
            temp0 = conflict_acts_info{i};

            for j = 1:length(temp0)
                temp = temp0{j};

                if ~isempty(temp)
                    allocated_resource_num = temp.allocated_resource_num; %resource_num
                    project_and_activity = temp.project_and_activity; % 活动序号
                    released_time = temp.activity_end_time; % 释放时间

                    if isempty(allocated_set)
                        allocated_set = [allocated_set, project_and_activity]; %找到这些活动的开始时间
                    else
                        count = 0;
                        m = 1;
                        len = length(allocated_set);

                        while m <= len
                            xx = (project_and_activity == allocated_set{1, m});

                            if xx(1) == 1 && xx(2) == 1
                                break
                            else
                                count = count + 1;
                                m = m + 1;
                            end

                            if count == length(allocated_set)
                                allocated_set = [allocated_set, project_and_activity];
                            end

                        end

                    end

                    if released_time == time + 1 % 如果释放时间等于当前时间
                        iter_variables.Lgs(:, allocated_resource_num) = data_set.Lgs(1:end, allocated_resource_num);
                        iter_variables.skill_num(1, :) = (sum(iter_variables.Lgs ~= 0, 2))';
                    end

                end

                % 记录每个时刻剩余的资源序号，该列不全为0的序号为资源序号
                %                 unallocated_resource_num = find(sum(iter_variables.Lgs, 1) ~= 0);
                %                 temp.unallocated_resource_num = unallocated_resource_num;
                %                 temp0{j} = temp;
                conflict_acts_info{i} = temp0;

            end

        end

        iter_variables.objective = objective;
        iter_variables.makespan = makespan;
        iter_variables.allocated_set = allocated_set;

        % save 和时间有关系的变量，需要保存
        variables_with_time{time} = iter_variables;

        if length(allocated_set) == length(need_global_activity) || max(max(iter_variables.local_start_times)) <= time

            break
        end

        toc
        seq = seq + 1;
    end

end
