% 基线进度计划
% 2. %请假点，从t=0开始循环，是否有员工请假
% 3. %若有，在t1时刻第一次员工请假，判断当前闲置员工可否满足执行要求
% 4.%若满足，则为其分配资源
% 5. %否，方案一，等待下一时刻继续判断

% %方案二，当前时刻所有正在进行的活动暂停，通过从其他活动中调整，重新分配资源

% 6.%如何调整：
% 7.%调整是把请假的活动和正在进行的活动都放在一起，softmax评分，分配资源同基线进度计划

%找该员工请假的活动

%为该活动重新分配资源

%1.剩余员工中存在可用员工（技能、数量均满足）
%allocate_resource 分配资源
%2. 剩余员工中不存在可用员工（技能、数量任一不满足）
%方案一， wait for solving

%方案二， 从其他活动中调整资源， 即正在执行的活动均暂停，其资源均释放，所有资源重新分配
%1.找掌握同等技能的人
%2.去掉请假的人
%3.找到符合技能要求的人，并记录当前时刻其正在执行的活动
%4. 为请假活动、被调整的活动均分配资源

% 8.%并继续从当前时刻开始循环，t = t1+1，注意请假与返工时配对出现，资源更新考虑（返工+其他活动释放）;
% 9.%过程同基线计划，完成后，得到目标值： 平均项目延期APD+活动开始时间偏差 +人员工作时间变化偏差
% 10.%判断方案一和二的目标值，最小选其一

% 10. %从t1开始循环，找下一个中断点，有员工请假，重复上述操作

% 11.%每个决策点动态决策选择最优方案，直到完成所有活动的调度

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
    % schedule_solution: start_time, end_time, resource_assignment
    schedule_solution = baseline_schedule(project_para, data_set, cycle);

    % repair plan

    %找请假时间点
    for t1 = 1:length(leave_infos.leave_time)
        leave_infos.staff(t1) ;%
    leave_infos.leave_duration(t1);
    leave_infos.leave_time(t1) ;
        leave_infos.leave_time(t1);%
        %找请假时刻正在执行的活动，从schedule_solution 
        %把所有活动暂停，资源释放


    end

    for index = 1:length(leave_infos)
        % staff = leave_infos(index){1};
        % leave_time = leave_infos(index){2};
        % leave_length = leave_infos(index){3};

        % repair solution: start_time, end_time, resource_assignment, objective
        repair_solution1 = wait_for_sloving(leave_infos(index), schedule_solution);
        repair_solution2 = adjust(leave_infos(index), schedule_solution);

        if objective1 < objective2
            repair_solution = repair_solution1;
        end

        schedule_solution = repair_solution;
    end

end

dynamic_schedule
