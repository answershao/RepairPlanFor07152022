clear; clc;
fclose all;

% 2. 请假点,从t=0开始循环,是否有员工请假
% 3. 若有,在t1时刻第一次员工请假,判断当前闲置员工可否满足执行要求
% 4. 若满足,则为其分配资源
% 5. 否,方案一,等待下一时刻继续判断

% define num_j, L,
project_para.cycles = 10; % 10次
project_para.T = 2000; % 总时间

project_para.L = 10; % 项目数量
project_para.num_j = 92; % 总活动数
project_para.skill_count = 4; % 技能种类数
project_para.resource_cate = 4; % 资源种类数,一直不变
% project_para.timeoff_level = 1; % 请假时间系数
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
                % schedule_solution.variables_with_time = variables_with_time;%所有时刻的活动执行信息
                % schedule_solution.conflict_acts_info = conflict_acts_info;%每个时刻活动分配资源的信息
                % constant_variables 基线调度计划中生成的定量，一旦生成均不变

                %%计算员工工作时间的偏差=修复后每个员工工作时间-修复前每个工作时间
                % output :
                %% 分析repair_schedule_plan;
                %需要分析baseline过渡到repair时，仍然保持不变的量，及需要继续迭代的量
                % project.para均保持不变
                %forward_set\cpm也保持不变
                %global_schedule_plan是baseline生成的原始数据，一旦存储也保持不变，后边极少用到
                %iter_variables是随着员工请假发生变化的
                %其中，在result中发生变化的是，resource_num、iter_variables、finally_total_duration、APD、 time，且APD的位置应改为修复目标值objective
                %保持不变的是ad
                %后续把global_schedule_plan传递给iter_variables,则在iter_variables中继续迭代的是技能值skill_value,资源序号resource_num,结束时间end_times,开始时间start_times,

                %% 1. 根据第一次请假时刻的信息，资源分配，从而修复，并继续寻找后续的请假时刻

                % schedule_solution
                % time开始，所有活动信息 单个活动分配信息
                % iter_schedule_solution.variables_with_time;%R,d,start,end,APD,makespan, allocated_set
                % Lgs,skill_num,resource_worktime,skill_value,allocated_resource_num,project_and_activity,start,end,unallocated_resource_num

                % iter
                iter_schedule_solution = schedule_solution;
                % iter_schedule_solution.variables_with_time
                % iter_schedule_solution.conflict_acts_info
                iter_schedule_solution.allocated_acts_information = all_act_infos(iter_schedule_solution);
                iter_schedule_solution.allocated_variables_information = all_variables_infos(iter_schedule_solution);

                iter_variables_with_time = iter_schedule_solution.variables_with_time;
                iter_conflict_acts_info = iter_schedule_solution.conflict_acts_info; % 内存储的9个变量+performing_time
                iter_allocated_acts_information = iter_schedule_solution.allocated_acts_information; %根据活动顺序排的，后需要遍历执行时间
                iter_allocated_variables_information = iter_schedule_solution.allocated_variables_information; %已根据时间顺序排好了

                timeoff = {};
                save_leave_time = 0;
                save_staff_leave_totaltime = zeros(1, project_para.people); %每个请假人员的请假时间之和

                %% repair plan
                leave_infos = {};
                save_leave_infos = {};
                count = 0;

                for time = 1:project_para.T
                    %         % 生成请假员工信息,以上一次调度计划的最大的完工时间为准
                    if isempty(leave_infos)
                        [leave_infos, save_staff_leave_totaltime] = next_leave_infos(project_para, schedule_solution, timeoff, iter_allocated_acts_information, iter_allocated_variables_information, save_leave_time, save_staff_leave_totaltime);
                        count = count + 1;
                        save_leave_infos{count} = leave_infos;
                    end

                    if isempty(leave_infos) %说明这是最后一个请假时刻了，且不符合条件，项目停止
                        break
                    end

                    % 1 更新资源
                    % 1.1 请假
                    % 是否为请假点 ，先更新Lgs,skill_num, 后续策略中更新allocated_set

                    [~, index_leave] = ismember(time, leave_infos.leave_time);
                    %%  找请假时刻
                    if index_leave ~= 0 %说明该time是请假时刻
                        save_leave_time = time; %save请假时刻,每次都会更新,所以只记录一次即可，后续请假时刻在当前基础上平移
                        timeoff.leave_time = leave_infos.leave_time(index_leave);
                        timeoff.leave_staff = leave_infos.leave_staff(index_leave);
                        timeoff.leave_duration = leave_infos.leave_duration(index_leave);
                        timeoff.return_time = leave_infos.return_time(index_leave);
                        leave_infos = {};
                        %% save请假时刻正在执行的活动信息和请假员工在执行的活动信息
                        [timeoff, performing_acts_infos] = find_staff_doing_activity(iter_allocated_acts_information, timeoff);
                        %% 1.更新资源 把请假时间段内的资源全更新

                        %% 2.重新调度活动
                        if ~isempty(timeoff.leave_activity_infos) %影响，timeoff.leave_activity_infos不是空集合,则performing_acts_infos也不是空集合

                            timeoff = parse_timeoff(data_set, timeoff); %请假时刻请假员工在执行的活动信息
                            performing_acts_infos = parse_performing_acts(data_set, performing_acts_infos, timeoff);

                            pro = timeoff.leave_activity_infos.pro; %员工请假离开后， 活动的剩余工期需要更新
                            act = timeoff.leave_activity_infos.act;

                            % save_leave_pro_and_act{count} = [pro,act];%save每次请假的项目活动序号
                            save_leave_time = timeoff.leave_time; %save请假时刻,每次都会更新

                            if time ~= timeoff.leave_time %员工请假时并未执行活动，而是在其返回之前有在执行的活动

                                for order = time:timeoff.leave_time
                                    %存放所有的开始执行时刻
                                    %需更新从time到leave_time 所有时刻信息
                                    iter_variables_with_time{order}.Lgs(:, timeoff.leave_staff) = 0;
                                    iter_variables_with_time{order}.skill_num = (sum(iter_variables_with_time{order}.Lgs ~= 0, 2))';
                                end

                                %存放所有的开始执行时刻+直到活动结束时刻为止，即+最后一个活动分配完后到最后一个活动结束为止的所有时段
                                %只需更新leave_time时刻
                                iter_allocated_variables_information{timeoff.leave_time}.Lgs(:, timeoff.leave_staff) = 0;
                                iter_allocated_variables_information{timeoff.leave_time}.skill_num = (sum(iter_allocated_variables_information{timeoff.leave_time}.Lgs ~= 0, 2))';
                            end

                            iter_variables.R = iter_allocated_variables_information{timeoff.leave_time}.R;
                            iter_allocated_variables_information{timeoff.leave_time}.d(act, :, pro) = timeoff.leave_activity_infos.unalready_duration;
                            iter_variables.d = iter_allocated_variables_information{timeoff.leave_time}.d; %员工请假离开后， 活动的剩余工期需要更新
                            iter_variables.local_start_times = iter_allocated_variables_information{timeoff.leave_time}.local_start_times;
                            iter_variables.local_end_times = iter_allocated_variables_information{timeoff.leave_time}.local_end_times;
                            iter_variables.allocated_set = iter_allocated_variables_information{timeoff.leave_time}.allocated_set;
                            iter_variables.objective = iter_allocated_variables_information{timeoff.leave_time}.objective;
                            iter_variables.makespan = iter_allocated_variables_information{timeoff.leave_time}.makespan;
                            iter_variables.Lgs = iter_allocated_variables_information{timeoff.leave_time}.Lgs;
                            iter_variables.skill_num = iter_allocated_variables_information{timeoff.leave_time}.skill_num; %技能可用量
                            iter_variables.resource_worktime = iter_allocated_variables_information{timeoff.leave_time}.resource_worktime;

                            %% 2.1 若闲置资源不可用，则采取动态策略
                            %             %策略一:推至下一时刻继续判断+基线调度计划

                            if strategy == "dynamic"
                                [temp_schedule_solution1, objective1] = wait_for_sloving(project_para, data_set, constant_variables, iter_variables, timeoff, iter_variables_with_time(1:timeoff.leave_time), iter_conflict_acts_info(1:timeoff.leave_time), alpha);
                                %  temp_schedule_solution = temp_schedule_solution1;
                                % 2.2 策略二:所有活动暂停, 从活动未完成部分开始
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
                            iter_conflict_acts_info = iter_schedule_solution.conflict_acts_info; % 内存储的9个变量+performing_time
                            iter_allocated_acts_information = iter_schedule_solution.allocated_acts_information; %根据活动顺序排的，后需要遍历执行时间
                            iter_allocated_variables_information = iter_schedule_solution.allocated_variables_information; %已根据时间顺序排好了
                        else
                            %% 员工请假对调度不影响，需更新资源和释放资源
                            %1.更新iter_variables_with_time
                            if length(iter_variables_with_time) < timeoff.return_time

                                for order = time:length(iter_variables_with_time)
                                    %存放所有的开始执行时刻
                                    %需更新从time到return_time-1
                                    %所有时刻信息,但是iter_variables_with_time中并未存放到return时的剩余信息，
                                    iter_variables_with_time{order}.Lgs(:, timeoff.leave_staff) = 0;
                                    iter_variables_with_time{order}.skill_num = (sum(iter_variables_with_time{order}.Lgs ~= 0, 2))';
                                end

                            elseif timeoff.return_time <= length(iter_variables_with_time)

                                for order = time:timeoff.return_time - 1
                                    %存放所有的开始执行时刻
                                    %需更新从time到return_time-1
                                    %所有时刻信息,但是iter_variables_with_time中并未存放到return时的剩余信息，
                                    iter_variables_with_time{order}.Lgs(:, timeoff.leave_staff) = 0;
                                    iter_variables_with_time{order}.skill_num = (sum(iter_variables_with_time{order}.Lgs ~= 0, 2))';
                                end

                            end

                            %2.更新iter_allocated_variables_information
                            if length(iter_allocated_variables_information) < timeoff.return_time
                                %需更新从time到return_time-1 所有时刻信息
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

                            %是否需要再次更新
                            %   iter_variables_with_time = iter_schedule_solution.variables_with_time;
                            %                 iter_conflict_acts_info = iter_schedule_solution.conflict_acts_info; % 内存储的9个变量+performing_time
                            %                 iter_allocated_acts_information = iter_schedule_solution.allocated_acts_information; %根据活动顺序排的，后需要遍历执行时间
                            %                 iter_allocated_variables_information = iter_schedule_solution.allocated_variables_information; %已根据时间顺序排好了

                        end

                    end

                end

                save_file_objective (file) = iter_allocated_variables_information{length(iter_allocated_variables_information)}.objective;
                %   save_file_leave_duration(file) = sum(save_staff_leave_totaltime);%每个file请假的总天数
                save_file_leave_level(file) = sum(save_staff_leave_totaltime) / max(schedule_solution.variables_with_time{length(schedule_solution.variables_with_time)}.makespan);
            end

            save_cycle_objective(cycle, :) = save_file_objective; %file 5个文件的均值
            save_cycle_leave_duration(cycle, :) = save_file_leave_level;
        end

        average_cpu = etime(clock, t1) / (files * project_para.cycles);

        saved_infos = zeros(project_para.cycles + 1, 2 * files + 2);
        saved_infos(1:project_para.cycles, 1:files) = save_cycle_objective; %file 5个文件的目标值1-5
        saved_infos(1:project_para.cycles, files + 1:files * 2) = save_cycle_leave_duration; %file 5个文件的level值6-10
        saved_infos(1:project_para.cycles, files * 2 + 1) = sum(save_cycle_objective, 2) / files; % 5个文件的目标值均值均值11
        saved_infos(1:project_para.cycles, files * 2 + 2) = sum(save_cycle_leave_duration, 2) / files; %5个文件的level值均值12
        saved_infos(project_para.cycles + 1, 1) = average_cpu;
        saved_infos(project_para.cycles + 1, 2) = mean(saved_infos(1:project_para.cycles, files * 2 + 1));
        saved_infos(project_para.cycles + 1, 3) = mean(saved_infos(1:project_para.cycles, files * 2 + 2));

        L = project_para.L;
        num_j = project_para.num_j;
        saved_path = strcat('F:\\YuYining\\Code\\UncertainResources_06262022\\RepairPlan-mpsplib算例\\LST\\', 'j', num2str(num_j - 2), '\\', 'MP', num2str(num_j - 2), '_', num2str(L), '\\', strategy, num2str(alpha), '.mat');
        save(saved_path, 'saved_infos');
        fclose all;
    end

end
