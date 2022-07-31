function [temp_schedule_solution, objective] = adjust_sloving(project_para, data_set, constant_variables, iter_variables, timeoff, performing_acts_infos, variables_with_time, conflict_acts_info)
    % project_para
    L = project_para.L;
    num_j = project_para.num_j;
    T = project_para.T;
    % data_set
    ad = data_set.ad;
    GlobalSourceRequest = data_set.GlobalSourceRequest;
    % timeoff
    leave_time = timeoff.leave_time;
    return_time = timeoff.return_time;
    leave_staff = timeoff.leave_staff;

    %constant_variables
    cpm = constant_variables.cpm;
    CPM = cpm.CPM;
    forward_set = constant_variables.forward_set;

    seq = 0;
    need_global_activity = find_need_global(GlobalSourceRequest);

    %׼������
    %leave_timeʱ����ٻ�ȷ�����Դ
    %if������Դ���㣬��ʱ�����лδ��ɲ��ָ��£���ʼ����ʱ�䡢δ��ɵĹ��ڣ�δ��ɵĹ�������������������cur_conflict���·�����Դ���ٸ���othertime_allocate
    %other_time,ֱ��othertime_allocate_resource

    for time = leave_time:T
        % ����һ���ȴ����ȣ�����Դ���䣬�û�Ŀ�ʼʱ����Զ�����Ϊ���ʱ�̣��������ֱ������repair_scheduling
        sprintf('����һ�� ǰѭ��:%d-%d', seq + 1, time)

        if time == leave_time
            [temp_variables, conflict_acts_info] = adjust_leavetime_schedule(project_para, data_set, iter_variables, conflict_acts_info, timeoff, performing_acts_infos, forward_set, cpm, time);
        end

        if time ~= leave_time
            [temp_variables, conflict_acts_info] = adjust_othertime_schedule(project_para, data_set, iter_variables, conflict_acts_info, performing_acts_infos, forward_set, need_global_activity, cpm, time);
        end

        %% ��.��Դ�ͷ��뷵��

        for i = 1:length(conflict_acts_info)
            temp0 = conflict_acts_info{i};

            for j = 1:length(temp0)
                temp = temp0{j};

                if ~isempty(temp)
                    allocated_resource_num = temp.allocated_resource_num; %resource_num
                    project_and_activity = temp.project_and_activity; % ����
                    released_time = temp.activity_end_time; % �ͷ�ʱ��

                    if isempty(temp_variables.allocated_set)
                        temp_variables.allocated_set = [temp_variables.allocated_set, project_and_activity]; %�ҵ���Щ��Ŀ�ʼʱ��
                    else
                        count = 0;
                        m = 1;
                        len = length(temp_variables.allocated_set);

                        while m <= len
                            xx = (project_and_activity == temp_variables.allocated_set{1, m});

                            if xx(1) == 1 && xx(2) == 1
                                break
                            else
                                count = count + 1;
                                m = m + 1;
                            end

                            if count == length(temp_variables.allocated_set)
                                temp_variables.allocated_set = [temp_variables.allocated_set, project_and_activity];
                            end

                        end

                    end

                    %��Դ�ع������;��
                    %1.�����-��Դ�ͷ�
                    if released_time == time + 1 % ����ͷ�ʱ����ڵ�ǰʱ��
                        temp_variables.Lgs(:, allocated_resource_num) = data_set.Lgs(1:end, allocated_resource_num);
                        temp_variables.skill_num(1, :) = (sum(temp_variables.Lgs ~= 0, 2))';
                    end

                end

            end

        end

        % 2.���Ա������-��Դ�ͷ�
        if return_time == time + 1
            %                         time_conflict_acts = conflict_acts_info{time};
            temp_variables.Lgs(:, leave_staff) = data_set.Lgs(1:end, leave_staff);
            temp_variables.skill_num(1, :) = (sum(temp_variables.Lgs ~= 0, 2))';
        end

        if length(temp_variables.allocated_set) == (num_j * L) || max(max(temp_variables.local_start_times)) <= time
            break
        end

        % ��¼ÿ��ʱ��ʣ�����Դ��ţ����в�ȫΪ0�����Ϊ��Դ���
        %     unallocated_resource_num = find(sum(iter_variables.Lgs, 1) ~= 0);

        finally_start_times = temp_variables.local_start_times - 1;
        finally_end_times = temp_variables.local_end_times - 1;
        makespan = max(finally_end_times, [], 2);
        APD = sum(makespan - ad' - CPM') / L; %1.ƽ����Ŀ����

        objective_act = APD + sum(sum(abs(temp_variables.local_start_times - iter_variables.local_start_times))) / L; %�޸�Ŀ��ֵf1�����й�
        objective_staff = sum(sum(abs(temp_variables.resource_worktime - iter_variables.resource_worktime))) / project_para.people; %�޸�Ŀ��ֵf2����Դ����ʱ��֮��ƫ���iter_variables.resource_worktime��
        objective = (1/2) * objective_act + (1/2) * objective_staff;

        iter_variables = temp_variables;

        iter_variables.objective = objective;
        iter_variables.makespan = makespan;
        iter_variables.allocated_set = temp_variables.allocated_set;

        % save ��ʱ���й�ϵ�ı�������Ҫ����
        variables_with_time{time} = iter_variables;

        temp_schedule_solution.conflict_acts_info = conflict_acts_info;
        temp_schedule_solution.variables_with_time = variables_with_time;
        toc
        seq = seq + 1;
    end
