clear; clc;
fclose all;

% 2. ��ٵ�,��t=0��ʼѭ��,�Ƿ���Ա�����
% 3. ����,��t1ʱ�̵�һ��Ա�����,�жϵ�ǰ����Ա���ɷ�����ִ��Ҫ��
% 4. ������,��Ϊ�������Դ
% 5. ��,����һ,�ȴ���һʱ�̼����ж�

% define num_j, L,
project_para.cycles = 10; % 10��
project_para.T = 2000; % ��ʱ��

project_para.L = 10; % ��Ŀ����
project_para.num_j = 92; % �ܻ��
project_para.skill_count = 4; % ����������
project_para.resource_cate = 4; % ��Դ������,һֱ����
% project_para.timeoff_level = 1; % ���ʱ��ϵ��
% default file readed
files = 5;
save_file_objective = [];
save_cycle_objective = zeros(project_para.cycles, files); %file=5
save_file_leave_level = [];
save_cycle_leave_duration = zeros(project_para.cycles, files);

%  for alpha = 0:0.5:1
for alpha = 1
    sprintf('alpha, %d', alpha)

    %     for index_strategy = 1:3
    for index_strategy = 1

        if index_strategy == 1
            strategy = 'dynamic';
        elseif index_strategy == 2
            strategy = "waitfor";
        elseif index_strategy == 3
            strategy = "adjust";
        end

        sprintf('strategy, %s', strategy)

        t1 = clock;

        for cycle = 1:project_para.cycles

            for file = 1:5
                %        file=5;
                [data_set, project_para] = config(project_para, file);
                % schedule_solution: start_time, end_time, resource_assignment

                [schedule_solution, constant_variables] = baseline_schedule(project_para, data_set, cycle);
                % schedule_solution.variables_with_time = variables_with_time;%����ʱ�̵Ļִ����Ϣ
                % schedule_solution.conflict_acts_info = conflict_acts_info;%ÿ��ʱ�̻������Դ����Ϣ
                % constant_variables ���ߵ��ȼƻ������ɵĶ�����һ�����ɾ�����

                %%����Ա������ʱ���ƫ��=�޸���ÿ��Ա������ʱ��-�޸�ǰÿ������ʱ��
                % output :
                %% ����repair_schedule_plan;
                %��Ҫ����baseline���ɵ�repairʱ����Ȼ���ֲ������������Ҫ������������
                % project.para�����ֲ���
                %forward_set\cpmҲ���ֲ���
                %global_schedule_plan��baseline���ɵ�ԭʼ���ݣ�һ���洢Ҳ���ֲ��䣬��߼����õ�
                %iter_variables������Ա����ٷ����仯��
                %���У���result�з����仯���ǣ�resource_num��iter_variables��finally_total_duration��APD�� time����APD��λ��Ӧ��Ϊ�޸�Ŀ��ֵobjective
                %���ֲ������ad
                %������global_schedule_plan���ݸ�iter_variables,����iter_variables�м����������Ǽ���ֵskill_value,��Դ���resource_num,����ʱ��end_times,��ʼʱ��start_times,

                %% 1. ���ݵ�һ�����ʱ�̵���Ϣ����Դ���䣬�Ӷ��޸���������Ѱ�Һ��������ʱ��

                % schedule_solution
                % time��ʼ�����л��Ϣ �����������Ϣ
                % iter_schedule_solution.variables_with_time;%R,d,start,end,APD,makespan, allocated_set
                % Lgs,skill_num,resource_worktime,skill_value,allocated_resource_num,project_and_activity,start,end,unallocated_resource_num

                % iter
                iter_schedule_solution = schedule_solution;
                % iter_schedule_solution.variables_with_time
                % iter_schedule_solution.conflict_acts_info
                iter_schedule_solution.allocated_acts_information = all_act_infos(iter_schedule_solution);
                iter_schedule_solution.allocated_variables_information = all_variables_infos(iter_schedule_solution);

                iter_variables_with_time = iter_schedule_solution.variables_with_time;
                iter_conflict_acts_info = iter_schedule_solution.conflict_acts_info; % �ڴ洢��9������+performing_time
                iter_allocated_acts_information = iter_schedule_solution.allocated_acts_information; %���ݻ˳���ŵģ�����Ҫ����ִ��ʱ��
                iter_allocated_variables_information = iter_schedule_solution.allocated_variables_information; %�Ѹ���ʱ��˳���ź���

                timeoff = {};
                save_leave_time = 0;
                save_staff_leave_totaltime = zeros(1, project_para.people); %ÿ�������Ա�����ʱ��֮��

                %% repair plan
                leave_infos = {};
                save_leave_infos = {};
                count = 0;

                for time = 1:project_para.T
                    %         % �������Ա����Ϣ,����һ�ε��ȼƻ��������깤ʱ��Ϊ׼
                    if isempty(leave_infos)
                        [leave_infos, save_staff_leave_totaltime] = next_leave_infos(project_para, schedule_solution, timeoff, iter_allocated_acts_information, iter_allocated_variables_information, save_leave_time, save_staff_leave_totaltime);
                        count = count + 1;
                        save_leave_infos{count} = leave_infos;
                    end

                    if isempty(leave_infos) %˵���������һ�����ʱ���ˣ��Ҳ�������������Ŀֹͣ
                        break
                    end

                    % 1 ������Դ
                    % 1.1 ���
                    % �Ƿ�Ϊ��ٵ� ���ȸ���Lgs,skill_num, ���������и���allocated_set

                    [~, index_leave] = ismember(time, leave_infos.leave_time);
                    %%  �����ʱ��
                    if index_leave ~= 0 %˵����time�����ʱ��
                        save_leave_time = time; %save���ʱ��,ÿ�ζ������,����ֻ��¼һ�μ��ɣ��������ʱ���ڵ�ǰ������ƽ��
                        timeoff.leave_time = leave_infos.leave_time(index_leave);
                        timeoff.leave_staff = leave_infos.leave_staff(index_leave);
                        timeoff.leave_duration = leave_infos.leave_duration(index_leave);
                        timeoff.return_time = leave_infos.return_time(index_leave);
                        leave_infos = {};
                        %% save���ʱ������ִ�еĻ��Ϣ�����Ա����ִ�еĻ��Ϣ
                        [timeoff, performing_acts_infos] = find_staff_doing_activity(iter_allocated_acts_information, timeoff);
                        %% 1.������Դ �����ʱ����ڵ���Դȫ����

                        %% 2.���µ��Ȼ
                        if ~isempty(timeoff.leave_activity_infos) %Ӱ�죬timeoff.leave_activity_infos���ǿռ���,��performing_acts_infosҲ���ǿռ���

                            timeoff = parse_timeoff(data_set, timeoff); %���ʱ�����Ա����ִ�еĻ��Ϣ
                            performing_acts_infos = parse_performing_acts(data_set, performing_acts_infos, timeoff);

                            pro = timeoff.leave_activity_infos.pro; %Ա������뿪�� ���ʣ�๤����Ҫ����
                            act = timeoff.leave_activity_infos.act;

                            % save_leave_pro_and_act{count} = [pro,act];%saveÿ����ٵ���Ŀ����
                            save_leave_time = timeoff.leave_time; %save���ʱ��,ÿ�ζ������

                            if time ~= timeoff.leave_time %Ա�����ʱ��δִ�л���������䷵��֮ǰ����ִ�еĻ

                                for order = time:timeoff.leave_time
                                    %������еĿ�ʼִ��ʱ��
                                    %����´�time��leave_time ����ʱ����Ϣ
                                    iter_variables_with_time{order}.Lgs(:, timeoff.leave_staff) = 0;
                                    iter_variables_with_time{order}.skill_num = (sum(iter_variables_with_time{order}.Lgs ~= 0, 2))';
                                end

                                %������еĿ�ʼִ��ʱ��+ֱ�������ʱ��Ϊֹ����+���һ�������������һ�������Ϊֹ������ʱ��
                                %ֻ�����leave_timeʱ��
                                iter_allocated_variables_information{timeoff.leave_time}.Lgs(:, timeoff.leave_staff) = 0;
                                iter_allocated_variables_information{timeoff.leave_time}.skill_num = (sum(iter_allocated_variables_information{timeoff.leave_time}.Lgs ~= 0, 2))';
                            end

                            iter_variables.R = iter_allocated_variables_information{timeoff.leave_time}.R;
                            iter_allocated_variables_information{timeoff.leave_time}.d(act, :, pro) = timeoff.leave_activity_infos.unalready_duration;
                            iter_variables.d = iter_allocated_variables_information{timeoff.leave_time}.d; %Ա������뿪�� ���ʣ�๤����Ҫ����
                            iter_variables.local_start_times = iter_allocated_variables_information{timeoff.leave_time}.local_start_times;
                            iter_variables.local_end_times = iter_allocated_variables_information{timeoff.leave_time}.local_end_times;
                            iter_variables.allocated_set = iter_allocated_variables_information{timeoff.leave_time}.allocated_set;
                            iter_variables.objective = iter_allocated_variables_information{timeoff.leave_time}.objective;
                            iter_variables.makespan = iter_allocated_variables_information{timeoff.leave_time}.makespan;
                            iter_variables.Lgs = iter_allocated_variables_information{timeoff.leave_time}.Lgs;
                            iter_variables.skill_num = iter_allocated_variables_information{timeoff.leave_time}.skill_num; %���ܿ�����
                            iter_variables.resource_worktime = iter_allocated_variables_information{timeoff.leave_time}.resource_worktime;

                            %% 2.1 ��������Դ�����ã����ȡ��̬����
                            %             %����һ:������һʱ�̼����ж�+���ߵ��ȼƻ�

                            if strategy == "dynamic"
                                [temp_schedule_solution1, objective1] = wait_for_sloving(project_para, data_set, constant_variables, iter_variables, timeoff, iter_variables_with_time(1:timeoff.leave_time), iter_conflict_acts_info(1:timeoff.leave_time), alpha);
                                %  temp_schedule_solution = temp_schedule_solution1;
                                % 2.2 ���Զ�:���л��ͣ, �ӻδ��ɲ��ֿ�ʼ
                                [temp_schedule_solution2, objective2] = adjust_sloving(project_para, data_set, constant_variables, iter_variables, timeoff, performing_acts_infos, iter_variables_with_time(1:timeoff.leave_time), iter_conflict_acts_info(1:timeoff.leave_time), alpha);
                                %   temp_schedule_solution = temp_schedule_solution2;
                                if objective1 < objective2
                                    temp_schedule_solution = temp_schedule_solution1;
                                else
                                    temp_schedule_solution = temp_schedule_solution2;
                                end

                            elseif strategy == "waitfor"
                                [temp_schedule_solution, objective] = wait_for_sloving(project_para, data_set, constant_variables, iter_variables, timeoff, iter_variables_with_time(1:timeoff.leave_time), iter_conflict_acts_info(1:timeoff.leave_time), alpha);
                            elseif strategy == "adjust"
                                [temp_schedule_solution, objective] = adjust_sloving(project_para, data_set, constant_variables, iter_variables, timeoff, performing_acts_infos, iter_variables_with_time(1:timeoff.leave_time), iter_conflict_acts_info(1:timeoff.leave_time), alpha);
                            else

                                while 1
                                    sprintf("Error")
                                end

                            end

                            iter_schedule_solution = temp_schedule_solution;

                            iter_schedule_solution.allocated_acts_information = all_act_infos(iter_schedule_solution);
                            iter_schedule_solution.allocated_variables_information = all_variables_infos(iter_schedule_solution);

                            iter_variables_with_time = iter_schedule_solution.variables_with_time;
                            iter_conflict_acts_info = iter_schedule_solution.conflict_acts_info; % �ڴ洢��9������+performing_time
                            iter_allocated_acts_information = iter_schedule_solution.allocated_acts_information; %���ݻ˳���ŵģ�����Ҫ����ִ��ʱ��
                            iter_allocated_variables_information = iter_schedule_solution.allocated_variables_information; %�Ѹ���ʱ��˳���ź���
                        else
                            %% Ա����ٶԵ��Ȳ�Ӱ�죬�������Դ���ͷ���Դ
                            %1.����iter_variables_with_time
                            if length(iter_variables_with_time) < timeoff.return_time

                                for order = time:length(iter_variables_with_time)
                                    %������еĿ�ʼִ��ʱ��
                                    %����´�time��return_time-1
                                    %����ʱ����Ϣ,����iter_variables_with_time�в�δ��ŵ�returnʱ��ʣ����Ϣ��
                                    iter_variables_with_time{order}.Lgs(:, timeoff.leave_staff) = 0;
                                    iter_variables_with_time{order}.skill_num = (sum(iter_variables_with_time{order}.Lgs ~= 0, 2))';
                                end

                            elseif timeoff.return_time <= length(iter_variables_with_time)

                                for order = time:timeoff.return_time - 1
                                    %������еĿ�ʼִ��ʱ��
                                    %����´�time��return_time-1
                                    %����ʱ����Ϣ,����iter_variables_with_time�в�δ��ŵ�returnʱ��ʣ����Ϣ��
                                    iter_variables_with_time{order}.Lgs(:, timeoff.leave_staff) = 0;
                                    iter_variables_with_time{order}.skill_num = (sum(iter_variables_with_time{order}.Lgs ~= 0, 2))';
                                end

                            end

                            %2.����iter_allocated_variables_information
                            if length(iter_allocated_variables_information) < timeoff.return_time
                                %����´�time��return_time-1 ����ʱ����Ϣ
                                for order = time:length(iter_allocated_variables_information)
                                    iter_allocated_variables_information{order}.Lgs(:, timeoff.leave_staff) = 0;
                                    iter_allocated_variables_information{order}.skill_num = (sum(iter_allocated_variables_information{order}.Lgs ~= 0, 2))';
                                end

                            elseif timeoff.return_time <= length(iter_allocated_variables_information)

                                for order = time:timeoff.return_time - 1
                                    iter_allocated_variables_information{order}.Lgs(:, timeoff.leave_staff) = 0;
                                    iter_allocated_variables_information{order}.skill_num = (sum(iter_allocated_variables_information{order}.Lgs ~= 0, 2))';
                                end

                            end

                            %�Ƿ���Ҫ�ٴθ���
                            %   iter_variables_with_time = iter_schedule_solution.variables_with_time;
                            %                 iter_conflict_acts_info = iter_schedule_solution.conflict_acts_info; % �ڴ洢��9������+performing_time
                            %                 iter_allocated_acts_information = iter_schedule_solution.allocated_acts_information; %���ݻ˳���ŵģ�����Ҫ����ִ��ʱ��
                            %                 iter_allocated_variables_information = iter_schedule_solution.allocated_variables_information; %�Ѹ���ʱ��˳���ź���

                        end

                    end

                end

                save_file_objective (file) = iter_allocated_variables_information{length(iter_allocated_variables_information)}.objective;
                %   save_file_leave_duration(file) = sum(save_staff_leave_totaltime);%ÿ��file��ٵ�������
                save_file_leave_level(file) = sum(save_staff_leave_totaltime) / max(schedule_solution.variables_with_time{length(schedule_solution.variables_with_time)}.makespan);
            end

            save_cycle_objective(cycle, :) = save_file_objective; %file 5���ļ��ľ�ֵ
            save_cycle_leave_duration(cycle, :) = save_file_leave_level;
        end

        average_cpu = etime(clock, t1) / (files * project_para.cycles);

        saved_infos = zeros(project_para.cycles + 1, 2 * files + 2);
        saved_infos(1:project_para.cycles, 1:files) = save_cycle_objective; %file 5���ļ���Ŀ��ֵ1-5
        saved_infos(1:project_para.cycles, files + 1:files * 2) = save_cycle_leave_duration; %file 5���ļ���levelֵ6-10
        saved_infos(1:project_para.cycles, files * 2 + 1) = sum(save_cycle_objective, 2) / files; % 5���ļ���Ŀ��ֵ��ֵ��ֵ11
        saved_infos(1:project_para.cycles, files * 2 + 2) = sum(save_cycle_leave_duration, 2) / files; %5���ļ���levelֵ��ֵ12
        saved_infos(project_para.cycles + 1, 1) = average_cpu;
        saved_infos(project_para.cycles + 1, 2) = mean(saved_infos(1:project_para.cycles, files * 2 + 1));
        saved_infos(project_para.cycles + 1, 3) = mean(saved_infos(1:project_para.cycles, files * 2 + 2));

        L = project_para.L;
        num_j = project_para.num_j;
        saved_path = strcat('F:\\YuYining\\Code\\UncertainResources_06262022\\RepairPlan-mpsplib����\\LST\\', 'j', num2str(num_j - 2), '\\', 'MP', num2str(num_j - 2), '_', num2str(L), '\\', strategy, num2str(alpha), '.mat');
        save(saved_path, 'saved_infos');
        fclose all;
    end

end
