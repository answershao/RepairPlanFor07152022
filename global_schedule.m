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

    % ����������ı���
    % from data_set
    iter_variables.R = data_set.R; % �ֲ���Դ������
    iter_variables.d = data_set.d; % ���ڱ仯����
    iter_variables.Lgs = data_set.Lgs;
    iter_variables.skill_num = data_set.original_skill_num; %���ܿ�����

    % from local schedule plan
    iter_variables.local_start_times = local_schedule_plan.local_start_times; %��ʼ�ֲ���ʼʱ��
    iter_variables.local_end_times = local_schedule_plan.local_end_times; %��ʼ�ֲ�����ʱ��
    iter_variables.resource_worktime = zeros(1, people);

    allocated_set = {}; %�����Ѿ�������Դ�Ļ
    global_schedule_plan = {};

    % Ѱ��ȫ����Դ��б�need_global_activity
    need_global_activity = find_need_global(GlobalSourceRequest);
    seq = 0;

    for time = 1:T
        sprintf('��ǰѭ��:%d-%d-%d', cycle, seq + 1, time)
        %5.3.1  ȷ����ǰʱ����Ҫȫ����Դ�ĳ�ͻ��б�  cur_need_global_activity
        cur_need_global_activity = find_cur_need_global_activity(iter_variables, need_global_activity, time, allocated_set); % ��ǰʱ����Ҫȫ����Դ�Ļ
        slst = find_slst(project_para, data_set, cpm, iter_variables); %���ɳ�ʱ��
        %5.3.2  ����cur_need_global_activityȷ����ͻ�˳���б�
        %cur_conflict(������ĿȨ�ء�����ڡ�ȫ���������������ȹ���)
        if ~isempty(cur_need_global_activity)

            [cur_conflict] = find_cur_conflict(data_set, iter_variables, cur_need_global_activity, slst);
            %5.3.3  ָ����Դallocate_source
            [temp_variables, result] = allocate_source(data_set, iter_variables, cur_conflict, time);
            %% ��. �ֲ�����update_clpex_option (���ȹ�ϵԼ������ԴԼ�����оֲ����£�
            %6.1  ͨ����ǰ���������ʱ��--ȷ��δ���Ż��ʼʱ��
            temp_variables = reschedule_local_time(temp_variables, time, forward_set);
            %6.2  ȷ��δ���Ż������ԴԼ��
            temp_variables = reschedule_local_resource(project_para, data_set, temp_variables, time);
            % temp_total_duration = max(temp2_local_end_times, [], 2);  % ÿ����Ŀ����=ÿ����Ŀ�Ļ����ʱ������ֵ2��*1��
            finally_start_times = temp_variables.local_start_times - 1;
            finally_end_times = temp_variables.local_end_times - 1;
            finally_total_duration = max(finally_end_times, [], 2);

            APD = sum(finally_total_duration - ad' - CPM') / L; %1.ƽ����Ŀ����
            %6.3  ����
            iter_variables = temp_variables;
            global_schedule_plan{time} = result;
            result = {};
        end % ������ǰʱ����Դ���估�ֲ�����

        %%  ��.����ȫ��Э�����߹���-�ж����õ�ȫ����Դ��һʱ���Ƿ���ͷ�
        for i = 1:length(global_schedule_plan)
            temp0 = global_schedule_plan{i};

            for j = 1:length(temp0)
                temp = temp0(j);

                if ~isempty(temp{1})
                    temp1 = temp{1};
                    temp12 = temp1(2); %Resource_number
                    temp13 = temp1(3); % ����
                    temp14 = temp1(4); % �ͷ�ʱ��

                    if isempty(allocated_set)
                        allocated_set = [allocated_set, temp13{1}]; %�ҵ���Щ��Ŀ�ʼʱ��
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

                    if temp14{1} == time + 1 % ����ͷ�ʱ����ڵ�ǰʱ��
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
