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

function [leave_infos, save_staff_leave_totaltime] = next_leave_infos(project_para, timeoff, iter_allocated_variables_information, iter_allocated_acts_information, save_leave_time, save_staff_leave_totaltime)

    save_pro_act_infos = {};
    count = 0;
    resource_serial = [];

    %% 一.生成请假时刻iter_prepare_leave_time
    makespan = iter_allocated_variables_information{length(iter_allocated_variables_information)}.makespan; %上一请假时刻的工期
    LAMBDA = max(makespan) / 2;
    prepare_leave_time = poissrnd(LAMBDA, 1, 1); % 产生以Lambda为平均值的m行n列Poisson 随机数．
    leave_time = save_leave_time + prepare_leave_time; %请假时刻，在前一次请假时刻之后，保证了时间逐渐推移

    %% 二.生成请假员工leave_staff
    staff_qualified = 0;
    order = 0;

    while ~staff_qualified

        %     if order == project_para.people
        %         leave_infos = [];
        %         break
        %     end
        %
        leave_staff = randperm(project_para.people, 1); %从原有资源里，随机选择一个为请假员工

        % condition1
        if save_staff_leave_totaltime(1, leave_staff) < 30
            %事假，避免出现0.5，从1开始，方便计算，在1-4内选择1个工期
            leave_duration = randperm(min(4, 30 - save_staff_leave_totaltime(1, leave_staff)), 1);

            %condition2--- if leave_staff 满足条件

            for i = 1:length(iter_allocated_acts_information)
                each_allocated_act_info = iter_allocated_acts_information{i};

                if ~isempty(timeoff)

                    if each_allocated_act_info.project_and_activity == timeoff.leave_activity_infos.project_and_activity %如何避免重复找？因为这里是根据Performing存储的
                        count = count + 1;
                        save_pro_act_infos{count}.project_and_activity = each_allocated_act_info.project_and_activity;
                        save_pro_act_infos{count}.allocated_resource_num = each_allocated_act_info.allocated_resource_num; %如资源2,4
                        save_pro_act_infos{count}.activity_start_time = each_allocated_act_info.activity_start_time;
                        save_pro_act_infos{count}.activity_end_time = each_allocated_act_info.activity_end_time;
                        %选择好请假时刻leavetime后，如果该时刻在执行活动，则要保证该活动不是之前的请假活动

                        %1.如果leavetime在上一次请假时刻与请假活动的结束之间，则需要把为上一请假活动的分配资源删除掉，从剩余资源选请假员工，再判断请假天数是否满足上限
                        %2.如果leavetime在上一次请假活动的结束之后，则只需要考虑请假员工是否满足请假天数上限即可
                        for resource = 1:people
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

        %     order = order + 1;
    end

    leave_infos.leave_staff = leave_staff;
    leave_infos.leave_duration = leave_duration;
    save_staff_leave_totaltime(1, leave_infos.leave_staff) = save_staff_leave_totaltime(1, leave_infos.leave_staff) + leave_infos.leave_duration;
    leave_infos.leave_time = leave_time;
    leave_infos.return_time = leave_infos.leave_time + leave_infos.leave_duration;
end
