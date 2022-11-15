% 如从t=该时刻,开始循环, 计算概率值P,超过0.5的记录为请假时刻,

% 如何确认请假时间点：泊松分布的 均值为前一个调度计划的项目工期的一半,每次进行修复前,都要确定一下请假的员工,
%在请假时刻中任意选择一个员工请假即可,任意选择请假类型及请假时长
% 若与上一次的修复调度计划中的请假时刻重复,如上一次,获得t=5时刻请假,任意选择员工2请假；这一次即使求得5仍然为请假时刻,也以上一次设定好的请假的员工为准,如员工2仍在T=5请假
% 循环到上一次得到的项目结束时间为准

% 每个员工可以请假多次，但请假天数有个上限，
%若员工请假类型为事假，则按照事假上限天数；若员工请假类型为病假，则按照病假上限天数。

%且每个时刻只能有一个员工请假；每个活动只能有一个时刻为请假情况即每个活动只能有一个员工请假一次

%一个员工可以请假多次，设置请假时间上限,每个月有个最大的请假天数，一年有最大的请假天数，如果前一个调度计划不足两个月，则以两个月计算

%% 生成请假工期leave_duration
%1.事假[0.5,4],一个月最多4天，一年不超过30天
%简化体现在程序中：不考虑周末，一月以工作20天计算，每20天最多4天请假，max(makespan)不足20以20计算，一年以20*12=240计算，240内不超30天
%2.病假[0.5,10],一个月最多10天，一年不超过15天------如上

function [leave_infos, save_staff_leave_totaltime] = next_leave_infos(project_para, timeoff, iter_variables_with_time, iter_allocated_acts_information, iter_allocated_variables_information, save_leave_time, save_staff_leave_totaltime, count)
    save_pro_act_infos = {};
    count = 0;
    resource_serial = [];

    %% 一.生成请假时刻iter_prepare_leave_time
    %     LAMBDA = max(baseline_makespan) / 2;
    % leave_time = intmax('uint64');
    %     while leave_time >= length(schedule_solution.variables_with_time)  || leave_time <= save_leave_time
    %   leave_time = poissrnd(7, 1, 1); % 产生以Lambda为平均值的m行n列Poisson 随机数
    %     end
    % if leave_time >= length(schedule_solution.variables_with_time) %请假时刻不能超过基线中最后一个活动的开始分配时刻
    %     break
    % end
    % while leave_time >= length(schedule_solution.variables_with_time)
    %     % sprintf('leave time :%d', leave_time)
    %     prepare_leave_time = poissrnd(7, 1, 1); % 产生以Lambda为平均值的m行n列Poisson 随机数．
    %     leave_time = save_leave_time + prepare_leave_time; %请假时刻，在前一次请假时刻之后，保证了时间逐渐推移
    %     %% 分析生成请假时刻的影响因素及方案
    %     %如果最后一个活动分配完，iter_variables_with_time中存放到最后一个活动的分配时刻，因为活动是全分配完立马停止了（allocated_set满），
    %     %所以没有给请假员工return时刻释放资源，因为以为活动已经全部执行完了，就结束了
    %     %但是需要根据上一个调度计划生成下一次的请假时刻，如果下一次请假时刻在最后一个活动的分配之后进行，
    %     %由于之前没给活动分配完后的还未return的请假员工释放，则容易漏掉资源
    %     %综上，方案1，活动分配完后也给未未return的请假员工释放，不限制请假时刻
    %     %方案2，让请假时刻控制在length(iter_variables_with_time)之内，之后就不再找了
    % end

    %  prepare_leave_time = poissrnd(30, 1, 1); % 产生以Lambda为平均值的m行n列Poisson 随机数．
    %     leave_time = save_leave_time + prepare_leave_time; %请假时刻，在前一次请假时刻之后，保证了时间逐渐推移

    repaire_makespan = max(iter_allocated_variables_information{length(iter_allocated_variables_information)}.makespan);
    lamda = repaire_makespan / 2; %期望值
    leave_time = 0;

    flag = 1;

    num_random = 1000;
    while leave_time <= save_leave_time

        if lamda < max(lamda, save_leave_time * 0.75)
            flag = 0;
            break
        end

        %     if count==0 %说明第一次传，
        %         rand('seed', 10);
        %         leave_time = poissrnd(lamda, 1, 1); % 第一个请假时刻进行固定
        %     else
        %         leave_time = poissrnd(lamda, 1, 1); % 产生以Lambda为平均值的m行n列Poisson 随机数．
        %     end
        leave_time = poissrnd(lamda, 1, 1); % 产生以Lambda为平均值的m行n列Poisson 随机数．
        num_random = num_random - 1;
        if num_random < 0
            break
        end
        if leave_time > save_leave_time && leave_time <= length(iter_variables_with_time) %请假时刻，在前一次请假时刻之后，保证了时间逐渐推移
            break
        end

    end

    %% 二.生成请假员工leave_staff

    staff_qualified = 0;

    if flag
        scaned_staffs = zeros(1, project_para.people);
        %         baseline_makespan = max(schedule_solution.variables_with_time{length(schedule_solution.variables_with_time)}.makespan);
        baseline_makespan = max(iter_variables_with_time{length(iter_variables_with_time)}.makespan);

        while ~staff_qualified

            % 遍历所有员工，都不满足，则退出循环,如果所有员工的请假时间在这之内，则继续循环，最后统计一个项目内的最大请假天数
            %         if sum(save_staff_leave_totaltime) >= project_para.timeoff_level * baseline_makespan || all(scaned_staffs)
            %             break
            %         end

            if leave_time >= length(iter_variables_with_time) %请假时刻不能超过基线中最后一个活动的开始分配时刻
                break
            end

            if count == 0 %说明第一次传，
                rand('seed', 11);
                leave_staff = randperm(project_para.people, 1); %从原有资源里，随机选择一个为请假员工
            else
                leave_staff = randperm(project_para.people, 1); %从原有资源里，随机选择一个为请假员工
            end

            scaned_staffs(leave_staff) = 1;

            % condition1
            months = ceil(baseline_makespan / 20);

            if save_staff_leave_totaltime(1, leave_staff) < min ((4 * months), 30)
                %事假，避免出现0.5，从1开始，方便计算，在1-4内选择1个工期
                %            leave_duration = randperm(min(4, min(30 - save_staff_leave_totaltime(1, leave_staff), project_para.timeoff_level * baseline_makespan - sum(save_staff_leave_totaltime))), 1);

                if count == 0 %说明第一次传，
                    rand('seed', 12);
                    leave_duration = randperm(min(4, min(30 - save_staff_leave_totaltime(1, leave_staff))), 1);
                else
                    leave_duration = randperm(min(4, min(30 - save_staff_leave_totaltime(1, leave_staff))), 1);
                end

                %condition2--- if leave_staff 满足条件
                for i = 1:length(iter_allocated_acts_information)
                    each_allocated_act_info = iter_allocated_acts_information{i};

                    if ~isempty(timeoff) && ~isempty(timeoff.leave_activity_infos)

                        if each_allocated_act_info.project_and_activity == timeoff.leave_activity_infos.project_and_activity %如何避免重复找？因为这里是根据Performing存储的
                            count = count + 1;
                            save_pro_act_infos{count}.project_and_activity = each_allocated_act_info.project_and_activity;
                            save_pro_act_infos{count}.allocated_resource_num = each_allocated_act_info.allocated_resource_num; %如资源2,4
                            save_pro_act_infos{count}.activity_start_time = each_allocated_act_info.activity_start_time;
                            save_pro_act_infos{count}.activity_end_time = each_allocated_act_info.activity_end_time;
                            %选择好请假时刻leavetime后，如果该时刻在执行活动，则要保证该活动不是之前的请假活动

                            %1.如果leavetime在上一次请假时刻与请假活动的结束之间，则需要把为上一请假活动的分配资源删除掉，从剩余资源选请假员工，再判断请假天数是否满足上限
                            %2.如果leavetime在上一次请假活动的结束之后，则只需要考虑请假员工是否满足请假天数上限即可
                            for resource = 1:project_para.people
                                resource_serial(resource) = resource; %给资源排序号
                            end

                            if save_pro_act_infos{count}.activity_start_time <= leave_time <= save_pro_act_infos{count}.activity_end_time

                                [~, index_leave_staff] = ismember(leave_staff, save_pro_act_infos{count}.allocated_resource_num);

                                if index_leave_staff == 0 %说明leave_staff不执行上一请假活动，满足
                                    staff_qualified = 1;
                                    break
                                    %                         else %leave_staff在执行上一请假活动，不满足
                                end

                            else %iter_prepare_leave_time也一定大于save_leave_time，说明上次的请假活动已经结束，只需考虑请假天数是否满足上限
                                staff_qualified = 1;
                                break
                            end

                        end

                    else
                        staff_qualified = 1;
                        break
                    end

                end

            end

        end

    end

    if staff_qualified
        leave_infos.leave_staff = leave_staff;
        leave_infos.leave_duration = leave_duration;
        save_staff_leave_totaltime(1, leave_infos.leave_staff) = save_staff_leave_totaltime(1, leave_infos.leave_staff) + leave_infos.leave_duration;
        leave_infos.leave_time = leave_time;
        leave_infos.return_time = leave_infos.leave_time + leave_infos.leave_duration;
    else
        leave_infos = {};
    end

end
