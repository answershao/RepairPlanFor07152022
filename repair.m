clear; clc;

% 2. %请假点,从t=0开始循环,是否有员工请假
% 3. %若有,在t1时刻第一次员工请假,判断当前闲置员工可否满足执行要求
% 4.%若满足,则为其分配资源
% 5. %否,方案一,等待下一时刻继续判断

% default file readed
config()

% define num_j, L,
project_para.num_j = 5; % 总活动数
project_para.L = 2; % 项目数量
project_para.resource_cate = 4; % 资源种类数
project_para.skill_count = 3; % 技能种类数
project_para.T = 500; % 总时间
project_para.cycles = 1; % 10次
project_para.people = 5;

for cycle = 1:project_para.cycles
    
    [data_set, leave_infos] = read_data(project_para);
    %     leave_infos = {};%便于后续
    
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
    
    % data_set
    
    % constant_variables
    
    % iter_variables.R = global_schedule_plan.R; % 局部资源可用量
    % iter_variables.d = global_schedule_plan.d; % 工期变化储存
    % iter_variables.Lgs = global_schedule_plan.Lgs;
    % iter_variables.skill_num = global_schedule_plan.skill_num; %技能可用量
    % iter_variables.local_start_times = global_schedule_plan.local_start_times; %初始局部开始时间
    % iter_variables.local_end_times = global_schedule_plan.local_end_times; %初始局部结束时间
    % iter_variables.allocated_acts_information = global_schedule_plan.allocated_acts_information;
    % iter_variables.resource_num = global_schedule_plan.resource_num;
    % iter_variables.makespan = global_schedule_plan.makespan;
    % iter_variables.APD = global_schedule_plan.APD;
    % iter_variables.resource_worktime = schedule_solution.result_saves_all{2}; % 储存每个员工的工作时间
    
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
    for time = 1:project_para.T
        %         % 生成请假员工信息,以上一次调度计划的最大的完工时间为准
        %         if ~isempty(leave_infos)
        [leave_infos, save_staff_leave_totaltime] = next_leave_infos(project_para,timeoff, iter_allocated_variables_information, iter_allocated_acts_information, save_leave_time, save_staff_leave_totaltime);
        %         else
        %             break
        %         end
        % 1 更新资源
        % 1.1 请假
        % 是否为请假点 ，先更新Lgs,skill_num, 后续策略中更新allocated_set
        [~, index_leave] = ismember(time, leave_infos.leave_time);
        %%  找请假时刻
        %          count = 0;
        if index_leave ~= 0 %说明该time是请假时刻
            save_leave_time = time; %save请假时刻,每次都会更新,所以只记录一次即可，后续请假时刻在当前基础上平移
            %             count = count +1;
            timeoff.leave_time = leave_infos.leave_time(index_leave);
            timeoff.leave_staff = leave_infos.leave_staff(index_leave);
            timeoff.leave_duration = leave_infos.leave_duration(index_leave);
            timeoff.return_time = leave_infos.return_time(index_leave);
            
            %% save请假时刻正在执行的活动信息和请假员工在执行的活动信息
            [timeoff, performing_acts_infos] = find_staff_doing_activity(iter_allocated_variables_information, iter_allocated_acts_information, timeoff);
            
            eachtime_variables_info = iter_allocated_variables_information{time}; %请假时刻的剩余信息
            %% 1.更新资源 （判断不同情况）
            if isempty(timeoff.leave_activity_infos)%不影响，timeoff.leave_activity_infos是空集合，即在整个项目执行期间，请假员工离开时候均为闲置状态
                eachtime_variables_info.Lgs(:, timeoff.leave_staff) = 0;
                eachtime_variables_info.skill_num = (sum(eachtime_variables_info.Lgs ~= 0, 2))';
                iter_allocated_variables_information{time} = eachtime_variables_info;
            else %影响，timeoff.leave_activity_infos非空，判断time和timeoff.leave_time是否相等
                if time ~= timeoff.leave_time  %员工请假时并未执行活动，而是在其返回之前有在执行的活动
                    eachtime_variables_info.Lgs(:, timeoff.leave_staff) = 0;
                    eachtime_variables_info.skill_num = (sum(eachtime_variables_info.Lgs ~= 0, 2))';
                    iter_allocated_variables_information{time} = eachtime_variables_info;
                    %         else %员工请假时正在执行活动,就不需要更新资源了，因为分配时已经更新了
                end
            end
            
            %      if isempty(performing_acts_infos) %timeoff必为空
            %          if isempty(timeoff) %performing_acts_infos不一定为空
            %          end
            %      end
            %% 2.重新调度活动
            if  ~isempty(timeoff.leave_activity_infos)%影响，timeoff.leave_activity_infos不是空集合,则performing_acts_infos也不是空集合
                timeoff = parse_timeoff(data_set, timeoff); %请假时刻请假员工在执行的活动信息
                performing_acts_infos = parse_performing_acts(data_set, performing_acts_infos, time);
                
                pro = timeoff.leave_activity_infos.pro; %员工请假离开后， 活动的剩余工期需要更新
                act = timeoff.leave_activity_infos.act;
                
                %             save_leave_pro_and_act{count} = [pro,act];%save每次请假的项目活动序号
                save_leave_time = timeoff.leave_time; %save请假时刻,每次都会更新
                
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
                [temp_schedule_solution1, objective1] = wait_for_sloving(project_para, data_set, constant_variables, iter_variables, timeoff, iter_variables_with_time(1:timeoff.leave_time - 1), iter_conflict_acts_info(1:timeoff.leave_time));
                %                          temp_schedule_solution = temp_schedule_solution1;%假设第一个策略好，传出了第一个策略
                %                         iter_schedule_solution = temp_schedule_solution;
                % 2.2 策略二:所有活动暂停, 从活动未完成部分开始
                [temp_schedule_solution2, objective2] = adjust_sloving(project_para, data_set, constant_variables, iter_variables, timeoff, performing_acts_infos, iter_variables_with_time(1:timeoff.leave_time - 1), iter_conflict_acts_info(1:timeoff.leave_time));
                %             temp_schedule_solution = temp_schedule_solution2; %假设第一个策略好，传出了第一个策略
                %             iter_schedule_solution = temp_schedule_solution;
                
                if objective1 < objective2
                    temp_schedule_solution = temp_schedule_solution1;
                else
                    temp_schedule_solution = temp_schedule_solution2;
                end
                
                iter_schedule_solution = temp_schedule_solution;
            else
                %% 3.释放资源，不影响时，无需调度活动，直接判断释放资源
                if    timeoff.return_time == time + 1
                    eachtime_variables_info.Lgs(:, timeoff.leave_staff) = data_set.Lgs(1:end, timeoff.leave_staff);
                    eachtime_variables_info.skill_num(1, :) = (sum(eachtime_variables_info.Lgs ~= 0, 2))';
                    iter_allocated_variables_information{time} = eachtime_variables_info;
                end
            end
            iter_schedule_solution.allocated_acts_information = all_act_infos(iter_schedule_solution);
            iter_schedule_solution.allocated_variables_information = all_variables_infos(iter_schedule_solution);
            
            iter_conflict_acts_info = iter_schedule_solution.conflict_acts_info; % 内存储的9个变量+performing_time
            iter_allocated_acts_information = iter_schedule_solution.allocated_acts_information; %根据活动顺序排的，后需要遍历执行时间
            iter_allocated_variables_information = iter_schedule_solution.allocated_variables_information; %已根据时间顺序排好了
        end
    end
end

% 1.2 返回
%1.是否为返回时间点，更新Lgs，skill_num,
%         [~, index_return] = ismember(time, leave_infos.return_time);
%
%         if index_return ~= 0 %说明该time是员工返回时刻
%             timeoff.return_time = leave_infos.return_time(index_return);
%             timeoff.return_staff = leave_infos.leave_staff(index_return); %员工的请假和返回，配对出现，即哪个员工走对应矩阵上的哪个员工便在一定时间返回
%
%             %遍历找返回时刻的活动信息
%             for i = 1:length(iter_allocated_acts_information)
%                 eachtime_act_info = iter_allocated_acts_information{i};
%
%                 if eachtime_act_info.performing_time == timeoff.return_time %找到了返回时刻的活动信息
%                     %员工复职
%                     eachtime_act_info.Lgs(:, timeoff.return_staff) = data_set.Lgs(1:end, timeoff.return_staff);
%                     eachtime_act_info.skill_num(1, :) = (sum(eachtime_act_info.Lgs ~= 0, 2))';
%                     iter_allocated_acts_information{i} = eachtime_act_info;
%                 end
%
%             end
%
