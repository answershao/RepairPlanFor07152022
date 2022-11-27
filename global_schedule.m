function [variables_with_time, conflict_acts_info] = global_schedule(project_para, data_set, constant_variables, local_schedule_plan, cycle)
    % global_schedule - Description
    tic
    global max_iteration global_seed
    max_iteration = 20;
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

    % ����������ı���
    % from data_set
    iter_variables.R = data_set.R; % �ֲ���Դ������
    iter_variables.d = data_set.d; % ���ڱ仯����

    % from local schedule plan
    iter_variables.local_start_times = local_schedule_plan.local_start_times; % ��ʼ�ֲ���ʼʱ��
    iter_variables.local_end_times = local_schedule_plan.local_end_times; % ��ʼ�ֲ�����ʱ��

    %����Դ������ص�
    iter_variables.Lgs = data_set.Lgs;
    iter_variables.skill_num = data_set.original_skill_num; %���ܿ�����
    iter_variables.resource_worktime = zeros(1, people);
    %
    %     conflict_act.Lgs = data_set.Lgs;
    %     conflict_act.skill_num = data_set.original_skill_num; %���ܿ�����
    %     conflict_act.resource_worktime = zeros(1, people);

    % Ѱ��ȫ����Դ��б�need_global_activity
    need_global_activity = find_need_global(GlobalSourceRequest);
    seq = 0;

    %     allocated_set_with_time = {};
    allocated_set = {}; % �����Ѿ�������Դ�Ļ
    variables_with_time = {};
    conflict_acts_info = {};
    
    objective = 0;
    makespan = 0;
    for time = 1:T
        sprintf('��ǰѭ��:%d-%d-%d', cycle, seq + 1, time)
        %5.3.1  ȷ����ǰʱ����Ҫȫ����Դ�ĳ�ͻ��б�  cur_need_global_activity
        cur_need_global_activity = find_cur_need_global_activity(iter_variables, need_global_activity, time, allocated_set); % ��ǰʱ����Ҫȫ����Դ�Ļ
        %5.3.2  ����cur_need_global_activityȷ����ͻ�˳���б�
        %cur_conflict(������ĿȨ�ء�����ڡ�ȫ���������������ȹ���)
        if ~isempty(cur_need_global_activity)
            iterations = factorial(length(cur_need_global_activity)); %��ͻ������Ľ׳�-���ڳ�ͻ�ȫ���л���
            L3 = cell(min(iterations, max_iteration), length(cur_need_global_activity));

            for p = 1:size(L3, 1)
                rand('seed', (global_seed + p) * cycle);
                L3(p, :) = cur_need_global_activity(randperm(length(cur_need_global_activity))); %L3-��ͻ���ȫ����˳��L5-��ͻ��Ŀ��ȫ����˳��
            end

            results = {}; all_order_temp_variables = {}; all_order_objective = zeros(size(L3, 1), 1);

            for u = 1:size(L3, 1) % ÿ��˳���µĳ�ͻ��б�  20
                sprintf('��ǰ˳��:%d / %d', u, size(L3, 1))
                L6 = L3(u, :);
                % L6(cellfun(@isempty,L6)) = []; %���˵��յ�Ԫ������
                %5.3.3  ָ����Դallocate_source
                [temp_variables, conflict_act_info] = allocate_source(data_set, iter_variables, L6, time);
                %% ��. �ֲ�����update_clpex_option (���ȹ�ϵԼ������ԴԼ�����оֲ����£�
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
                objective = sum(makespan - ad' - CPM') / L;
                all_order_objective(u) = objective; %����˳���ƽ����Ŀ����
            end

            pos = find(all_order_objective == min(all_order_objective)); % �ж���һ��˳��Ŀ��ֵ��С
            conflict_act_info = results{pos};
            temp_variables = all_order_temp_variables{pos};
            %6.3  ����
            iter_variables = temp_variables;
            conflict_acts_info{time} = conflict_act_info;
        end % ������ǰʱ����Դ���估�ֲ�����

        %%  ��.����ȫ��Э�����߹���-�ж����õ�ȫ����Դ��һʱ���Ƿ���ͷ�
        for i = 1:length(conflict_acts_info)
            temp0 = conflict_acts_info{i};

            for j = 1:length(temp0)
                temp = temp0{j};

                if ~isempty(temp)
                    allocated_resource_num = temp.allocated_resource_num; %resource_num
                    project_and_activity = temp.project_and_activity; % ����
                    released_time = temp.activity_end_time; % �ͷ�ʱ��

                    if isempty(allocated_set)
                        allocated_set = [allocated_set, project_and_activity]; %�ҵ���Щ��Ŀ�ʼʱ��
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

                    if released_time == time + 1 % ����ͷ�ʱ����ڵ�ǰʱ��
                        iter_variables.Lgs(:, allocated_resource_num) = data_set.Lgs(1:end, allocated_resource_num);
                        iter_variables.skill_num(1, :) = (sum(iter_variables.Lgs ~= 0, 2))';
                    end

                end

                % ��¼ÿ��ʱ��ʣ�����Դ��ţ����в�ȫΪ0�����Ϊ��Դ���
                %                 unallocated_resource_num = find(sum(iter_variables.Lgs, 1) ~= 0);
                %                 temp.unallocated_resource_num = unallocated_resource_num;
                %                 temp0{j} = temp;
                conflict_acts_info{i} = temp0;

            end

        end

        iter_variables.objective = objective;
        iter_variables.makespan = makespan;
        iter_variables.allocated_set = allocated_set;

        % save ��ʱ���й�ϵ�ı�������Ҫ����
        variables_with_time{time} = iter_variables;

        if length(allocated_set) == length(need_global_activity) || max(max(iter_variables.local_start_times)) <= time

            break
        end

        %
        %       if length(allocated_set) == length(need_global_activity)
        %
        %         break
        %     end

        toc
        seq = seq + 1;
    end

end
