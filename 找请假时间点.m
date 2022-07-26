% 找请假时间点
[~, index1] = ismember(time, leave_infos.leave_time); %判断该点是否为请假点,,index1为请假点的位置,便于寻找对应的请假员工及请假时长

if index1 ~= 0 % 是请假点 %leave_infos.leave_time需每次修复计划后随之更新
    iter_variables.Lgs(:, leave_infos.leave_staff(index1)) = 0; %更新当前时刻的技能可用量
    iter_variables.skill_num = (sum(iter_variables.Lgs ~= 0, 2))';
    % leave_infos.leave_staff(index1)该时刻的请假员工,%每个时刻只请假一个员工
    %% 1.检查该请假员工在请假时刻是否在执行活动
    %schedule_solution.result_saves_all的第一列为资源号,time与其行号相关
    [~, index2] = ismember(leave_infos.leave_staff(index1), schedule_solution.result_saves_all{time, 1}); %index2为请假员工的位置

    if index2 == 0 %说明请假员工当前在执行活动
        % 2.找到该员工当前时刻time时正在执行的活动集合,在schedule_solution.global_schedule_plan中找,
        %2.1找到所有的活动执行时刻的信息
        [allocated_acts_information] = all_act_infos(schedule_solution);
        %2.2 找到time 时刻正在执行的活动
        all_time_infos = allocated_acts_information(:, 6); %第六项-所有时间列出
        performing_acts_infos = {}; %储存time时刻正在执行的活动信息
        count = 0;

        for time_order = 1:length(all_time_infos)

            if all_time_infos{time_order} == time %若相等,记录行数time_order
                count = count + 1;
                performing_acts_infos(count, :) = allocated_acts_information(time_order, :); %time 时刻正在执行的活动的信息
                %记录该活动的截止到该时刻已经完成的工作时间、剩余工作时间、已完成的工作量、剩余工作量

                %[~, index5] = ismember(leave_infos.leave_staff(index1), performing_acts_infos(count,:){2}); %第2项为资源序号,判断请假员工是否属于执行一员,若是,找出该活动

                %                         if index5 ~= 0 %说明请假员工在执行该活动
                %                             pro = performing_acts_infos{3}(1); %项目号；第3项为该活动
                %                             act = performing_acts_infos{3}(2); %活动号
                %                         else
                %                         end

            else
            end

        end

        %2.2 请假员工给正在执行的活动的技能

        %% 3.判断当前时刻闲置员工中可否替代请假员工,满足该活动的技能需求量（请假一人,找一人）

        %3.1 if满足,则分配,更新skill_num.继续按照基线调度计划完成该请假时刻的多项目调度计划
        if 1 <= iter_variables.skill_num (skill_cate(pro, act)) % 如果剩余技能可用量满足请假活动需要的1人,
            [~, index3] = find(iter_variables.Lgs(skill_cate(pro, act), :) ~= 0); %找到掌握这些技能的资源序号,index3代表资源序号
            %找到闲置员工中与满足技能可用的员工的重合部分
            [avalible_staff, ~] = intersect(schedule_solution.result_saves_all{time, 1}, index3); %resource_num:满足技能需求的闲置员工的序号

            if ~isempty(avalible_staff) %如果非空集,说明闲置资源满足技能需求
                %根据HL&LN指派策略指派资源,做一个HL&LN函数,直接调用
                lgs_1 = iter_variables.Lgs(skill_cate(pro, act), avalible_staff); %找到掌握这些技能的资源序号
                schedule_solution.result_saves_all{time, 1}; %闲置员工

                for resource = 1:people
                    skill_distribution(resource) = length(find(temp_Lgs(:, resource) ~= 0)); %
                    resource_serial(resource) = resource; %资源序号
                end

                %HL&LN指派策略：技能水平高&技能数少的策略
                A = [lgs_1; -skill_distribution; -resource_serial];
                [B, indexb] = sortrows(A');
                B(:, 2:3) = -B(:, 2:3);
                Maxlgs = B(:, 1)';
                skill_number = Maxlgs(1, people - GlobalSourceRequest(pro, act) + 1:end); %确定资源技能值
                resource_number = indexb(people - GlobalSourceRequest(pro, act) + 1:end); % 确定资源序号
                temp_d(act, 1, pro) = ceil(GlobalSourceRequest(pro, act) * iter_variables.d(act, 1, pro) / sum(skill_number)); %工期

                for k = 1:length(resource_number) %资源序号
                    temp_resource_worktime(resource_number(k)) = temp_resource_worktime(resource_number(k)) + temp_d(act, 1, pro); %更新资源工作时间
                end

                temp_Lgs(:, resource_number) = 0;

                temp_skill_num = (sum(temp_Lgs ~= 0, 2))'; % 姣忎竴琛屼笉涓?0鐨勮?＄畻涓?鏁? % 鎶?鑳藉彲鐢ㄩ噺鏇存柊 iter_skill_num

                temp_local_end_times(pro, act) = time + temp_d(act, 1, pro);
                result{v} = {skill_number, resource_number, [pro, act], temp_local_end_times(pro, act), temp_local_start_times(pro, act)};
            else
                temp_local_start_times(pro, act) = temp_local_start_times(pro, act) + 1;
                temp_local_end_times(pro, act) = temp_local_end_times(pro, act) + 1;
            end

            %% 4.不满足,分别执行策略一、策略二
            %策略一:推至下一时刻继续判断+基线调度计划
            repair_solution1 = wait_for_sloving(leave_infos(index), schedule_solution);
            %策略二:所有活动暂停,记录所有活动的资源基本信息：工作时间、剩余工作时间、已完成的工作量、剩余工作量、技能需求量
            %给冲突活动按照softmax机制,资源指派按照hl&ln规则
            repair_solution2 = adjust_repair(leave_infos(index), schedule_solution);

            if objective1 < objective2
                repair_solution = repair_solution1;
            end

            schedule_solution = repair_solution;

        end

    else
        %% 5.请假员工当前属于闲置状态,记住后续根据返回时间及时更新及技能可用量,
        %按照基线进度计划执行即可,并对当前时刻的活动重新分配资源

    end

else
end
