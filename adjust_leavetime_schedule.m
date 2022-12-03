function [temp_variables, conflict_acts_info] = adjust_leavetime_schedule(project_para, data_set, iter_variables, conflict_acts_info, timeoff, performing_acts_infos, forward_set, cpm, time)

    %请假时刻资源分配
    [temp_variables, conflict_act_info, cur_need_global_activity] = adjust_leavetime_allocate_resource(data_set, iter_variables, timeoff, performing_acts_infos, time);

    if ~isempty(cur_need_global_activity{1}) %说明leave_time时刻，无闲置资源可分配，需要重新调整活动分配，所以赋值给cur_need_global_activity
        conflict_acts_info{time} = [];
        lft = find_lft(project_para, data_set, cpm, iter_variables); %最晚开始时间
        [cur_conflict] = find_cur_conflict_repair(data_set, temp_variables, cur_need_global_activity, lft); %softmax评分确定活动执行顺序
        %重新调整时与其他活动分配相同
        [temp_variables, conflict_act_info] = adjust_othertime_allocate_resource(data_set, temp_variables, performing_acts_infos, cur_conflict, time);
        %%  局部更新update_clpex_option (优先关系约束及资源约束进行局部更新）
        %6.1  通过紧前活动的最大完成时间--确定未安排活动开始时间
        temp_variables = reschedule_local_time(temp_variables, forward_set, time);
        %6.2  确定未安排活动满足资源约束
        temp_variables = reschedule_local_resource(project_para, data_set, temp_variables, time);
        % temp_total_duration = max(temp2_local_end_times, [], 2);  % 每个项目工期=每个项目的活动结束时间的最大值2行*1列
        %6.3  传递
        %             iter_variables = temp_variables;
        conflict_acts_info{time} = conflict_act_info;
    end

    if isempty(cur_need_global_activity{1}) %说明conflict_act_info不为空，leave_time有闲置资源可分配
        %     ~isempty(conflict_act_info)%说明conflict_act_info不为空，leave_time有闲置资源可分配
        %%  局部更新update_clpex_option (优先关系约束及资源约束进行局部更新）
        %6.1  通过紧前活动的最大完成时间--确定未安排活动开始时间
        temp_variables = reschedule_local_time(temp_variables, forward_set, time);
        %6.2  确定未安排活动满足资源约束
        temp_variables = reschedule_local_resource(project_para, data_set, temp_variables, time);
        %6.3  传递
        %         iter_variables = temp_variables;
        %更新每个时刻分配的活动
        %     time_conflict_acts = conflict_acts_info(time);
        time_conflict_acts = conflict_acts_info{time}; %time时刻，分配的活动
        temp_time_conflict_acts = {};
        index = 1;

        if isempty(time_conflict_acts)
            conflict_acts_info{time} = time_conflict_acts;
        end

        if ~isempty(time_conflict_acts)
            ind = ~cellfun(@isempty, time_conflict_acts); %找到非空cell数组
            [~, index3] = find(ind ~= 0); %index3为非空cell所在的位置
            oral_time_conflict_acts = time_conflict_acts(index3);

            if ~isempty(oral_time_conflict_acts)

                for order = 1:length(oral_time_conflict_acts)

                    if timeoff.leave_activity_infos.project_and_activity == oral_time_conflict_acts{order}.project_and_activity

                        if ~isempty(conflict_act_info)
                            temp_time_conflict_acts{index} = conflict_act_info{1}; %conflict_act_info只存放一个，只要找到该请假活动，无论其是否分配均更新请假活动的位置（未分配，为空集，分配了则更新信息）
                            index = index + 1;
                        end

                    else
                        temp_time_conflict_acts{index} = oral_time_conflict_acts{order}; %conflict_act_info只存放一个，只要找到该请假活动，无论其是否分配均更新请假活动的位置（未分配，为空集，分配了则更新信息）
                        index = index + 1;
                    end

                end

                conflict_acts_info{time} = temp_time_conflict_acts;
            else
                conflict_acts_info{time} = oral_time_conflict_acts;
            end

        end

    end
