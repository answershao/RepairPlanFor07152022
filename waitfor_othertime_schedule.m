function [temp_variables, conflict_acts_info] = waitfor_othertime_schedule(project_para, data_set, iter_variables, conflict_acts_info, timeoff, forward_set, need_global_activity, cpm, alpha, cycle, time)
    global max_iteration
    L = project_para.L;
    ad = data_set.ad;
    CPM = cpm.CPM;
    temp_variables = iter_variables;
    %5.3.1  ȷ����ǰʱ����Ҫȫ����Դ�ĳ�ͻ��б�  cur_need_global_activity
    cur_need_global_activity = find_cur_need_global_activity(iter_variables, need_global_activity, time, iter_variables.allocated_set); % ��ǰʱ����Ҫȫ����Դ�Ļ

    % ����cur_need_global_activityȷ����ͻ�˳���б�-��ͻ����л���

    if ~isempty(cur_need_global_activity)

        iterations = factorial(length(cur_need_global_activity)); %��ͻ������Ľ׳�-���ڳ�ͻ�ȫ���л���
        L3 = cell(min(iterations, max_iteration), length(cur_need_global_activity));

        for p = 1:size(L3, 1)
            rand('seed', (p) * cycle);
            L3(p, :) = cur_need_global_activity(randperm(length(cur_need_global_activity))); %L3-��ͻ���ȫ����˳��L5-��ͻ��Ŀ��ȫ����˳��
        end

        results = {}; all_order_temp_variables = {}; all_order_objective = zeros(size(L3, 1), 1);

        for u = 1:size(L3, 1) % ÿ��˳���µĳ�ͻ��б�  20
            sprintf('��ǰ˳��:%d / %d', u, size(L3, 1))
            L6 = L3(u, :);
            [temp_variables, conflict_act_info] = waitfor_othertime_allocate_resource(data_set, iter_variables, timeoff, L6, time);
            %%  �ֲ�����update_clpex_option (���ȹ�ϵԼ������ԴԼ�����оֲ����£�
            %6.1  ͨ����ǰ���������ʱ��--ȷ��δ���Ż��ʼʱ��
            temp_variables = reschedule_local_time(temp_variables, forward_set, time);
            %6.2  ȷ��δ���Ż������ԴԼ��
            temp_variables = reschedule_local_resource(project_para, data_set, temp_variables, time);

            %������˳��u��ͳ����һ��
            results {u} = conflict_act_info;
            all_order_temp_variables{u} = temp_variables;

            finally_start_times = temp_variables.local_start_times - 1;
            finally_end_times = temp_variables.local_end_times - 1;
            makespan = max(finally_end_times, [], 2);
            APD = sum(makespan - ad' - CPM') / L;

            %          objective_act = abs(APD - iter_variables.objective);
            %         objective_start_time = sum(sum(abs(finally_start_times - (iter_variables.local_start_times - 1)))) / L; %�޸�Ŀ��ֵf1�����й�
            %         all_order_objective(u)  =  alpha * objective_act + (1 - alpha) * objective_start_time;

            objective_act = APD + sum(sum(abs(finally_start_times - (iter_variables.local_start_times - 1)))) / L; %�޸�Ŀ��ֵf1�����й�
            objective_staff = sum(abs(temp_variables.resource_worktime - iter_variables.resource_worktime)) / project_para.people; %�޸�Ŀ��ֵf2����Դ����ʱ��֮��ƫ���iter_variables.resource_worktime��
            all_order_objective(u) = alpha * objective_act + (1 - alpha) * objective_staff;

        end

        pos = find(all_order_objective == min(all_order_objective)); % �ж���һ��˳��Ŀ��ֵ��С
        conflict_act_info = results{pos};
        temp_variables = all_order_temp_variables{pos};
        %6.3  ����
        iter_variables = temp_variables;
        conflict_acts_info{time} = conflict_act_info;
    end % ������ǰʱ����Դ���估�ֲ�����

    %
    % temp_variables = iter_variables;
    % %5.3.1  ȷ����ǰʱ����Ҫȫ����Դ�ĳ�ͻ��б�  cur_need_global_activity
    % cur_need_global_activity = find_cur_need_global_activity(iter_variables, need_global_activity, time, iter_variables.allocated_set); % ��ǰʱ����Ҫȫ����Դ�Ļ
    % slst = find_slst(project_para, data_set, cpm, iter_variables); %���ɳ�ʱ��
    % %5.3.2  ����cur_need_global_activityȷ����ͻ�˳���б�
    % %cur_conflict(������ĿȨ�ء�����ڡ�ȫ���������������ȹ���)
    % if ~isempty(cur_need_global_activity)
    %     [cur_conflict] = find_cur_conflict(data_set, iter_variables, cur_need_global_activity, slst);
    %     [temp_variables, conflict_act_info] = waitfor_othertime_allocate_resource(data_set, iter_variables, timeoff, cur_conflict, time);
    %     %%  �ֲ�����update_clpex_option (���ȹ�ϵԼ������ԴԼ�����оֲ����£�
    %     %6.1  ͨ����ǰ���������ʱ��--ȷ��δ���Ż��ʼʱ��
    %     temp_variables = reschedule_local_time(temp_variables, forward_set, time);
    %     %6.2  ȷ��δ���Ż������ԴԼ��
    %     temp_variables = reschedule_local_resource(project_para, data_set, temp_variables, time);
    %     % temp_total_duration = max(temp2_local_end_times, [], 2);  % ÿ����Ŀ����=ÿ����Ŀ�Ļ����ʱ������ֵ2��*1��
    %     %6.3  ����
    %     %             iter_variables = temp_variables;
    %     conflict_acts_info{time} = conflict_act_info;
    % end
