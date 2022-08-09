function [temp_variables, conflict_acts_info] = adjust_leavetime_schedule(project_para, data_set, iter_variables, conflict_acts_info, timeoff, performing_acts_infos, forward_set, cpm, time)

    %���ʱ����Դ����
    [temp_variables, conflict_act_info, cur_need_global_activity] = adjust_leavetime_allocate_resource(data_set, iter_variables, timeoff, performing_acts_infos, time);

    if ~isempty(cur_need_global_activity{1}) %˵��leave_timeʱ�̣���������Դ�ɷ��䣬��Ҫ���µ�������䣬���Ը�ֵ��cur_need_global_activity
        conflict_acts_info{time} = [];
        slst = find_slst(project_para, data_set, cpm, temp_variables); %���ɳ�ʱ��
        [cur_conflict] = find_cur_conflict(data_set, temp_variables, cur_need_global_activity, slst); %softmax����ȷ���ִ��˳��
        %���µ���ʱ�������������ͬ
        [temp_variables, conflict_act_info] = adjust_othertime_allocate_resource(data_set, temp_variables, performing_acts_infos, cur_conflict, time);
        %%  �ֲ�����update_clpex_option (���ȹ�ϵԼ������ԴԼ�����оֲ����£�
        %6.1  ͨ����ǰ���������ʱ��--ȷ��δ���Ż��ʼʱ��
        temp_variables = reschedule_local_time(temp_variables, forward_set, time);
        %6.2  ȷ��δ���Ż������ԴԼ��
        temp_variables = reschedule_local_resource(project_para, data_set, temp_variables, time);
        % temp_total_duration = max(temp2_local_end_times, [], 2);  % ÿ����Ŀ����=ÿ����Ŀ�Ļ����ʱ������ֵ2��*1��
        %6.3  ����
        %             iter_variables = temp_variables;
        conflict_acts_info{time} = conflict_act_info;
    end

    if isempty(cur_need_global_activity{1}) %˵��conflict_act_info��Ϊ�գ�leave_time��������Դ�ɷ���
        %     ~isempty(conflict_act_info)%˵��conflict_act_info��Ϊ�գ�leave_time��������Դ�ɷ���
        %%  �ֲ�����update_clpex_option (���ȹ�ϵԼ������ԴԼ�����оֲ����£�
        %6.1  ͨ����ǰ���������ʱ��--ȷ��δ���Ż��ʼʱ��
        temp_variables = reschedule_local_time(temp_variables, forward_set, time);
        %6.2  ȷ��δ���Ż������ԴԼ��
        temp_variables = reschedule_local_resource(project_para, data_set, temp_variables, time);
        %6.3  ����
        %         iter_variables = temp_variables;
        %����ÿ��ʱ�̷���Ļ
        time_conflict_acts = conflict_acts_info{time}; %timeʱ�̣�����Ļ
        temp_time_conflict_acts = {};
        index = 1;

        for order = 1:length(time_conflict_acts)

            if timeoff.leave_activity_infos.project_and_activity == time_conflict_acts{order}.project_and_activity

                if ~isempty(conflict_act_info)
                    temp_time_conflict_acts{index} = conflict_act_info{1}; %conflict_act_infoֻ���һ����ֻҪ�ҵ�����ٻ���������Ƿ�����������ٻ��λ�ã�δ���䣬Ϊ�ռ����������������Ϣ��
                    index = index + 1;
                end

            else
                temp_time_conflict_acts{index} = time_conflict_acts{order}; %conflict_act_infoֻ���һ����ֻҪ�ҵ�����ٻ���������Ƿ�����������ٻ��λ�ã�δ���䣬Ϊ�ռ����������������Ϣ��
                index = index + 1;
            end

        end

        conflict_acts_info{time} = temp_time_conflict_acts;
    end
