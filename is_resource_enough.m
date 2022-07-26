function [bool] = is_resource_enough(project_para, data_set, iter_variables, performing_acts_infos, timeoff, time)
    %IS_RESOURCE_ENOUGH 此处显示有关此函数的摘要
    %   此处显示详细说明
    activity_infos = timeoff.activity_infos; %当前时刻请假的活动
    skill_cate = data_set.skill_cate;
    skill_num = iter_variables.skill_num;
    Lgs = data_set.Lgs;
    bool = 0;

    %找到time时刻请假活动序号
    pro = activity_infos{3}(1); %项目号；第3项为该活动
    act = activity_infos{3}(2); %活动号

    if 1 <= skill_num(skill_cate(pro, act)) % 如果剩余技能可用量满足请假活动需要的1人,如需要技能3
        bool = 1;
        [~, index3] = find(Lgs (skill_cate(pro, act), :) ~= 0); %找到掌握这些技能的资源序号,index3代表资源序号,如掌握技能3的为资源1,2,3,5
        %找到闲置员工中与满足技能可用的员工的重合部分
        [avalible_staff, ~] = intersect(schedule_solution.result_saves_all{time, 1}, index3); %avalible_staff:满足技能需求的闲置员工的序号，如当前闲置1，符合掌握技能3的需求

        if ~isempty(avalible_staff) %如果非空集,说明闲置资源满足技能需求
            [temp_variables, result] = HL_LN_allocate_staff(data_set, iter_variables, activity, time); %HL&LN 指派策略
        else
            % body
            %% 4.不满足,分别执行策略一、策略二
            %策略一:推至下一时刻继续判断+基线调度计划
            repair_solution1 = wait_for_repair(leave_infos(index), schedule_solution);
            %策略二:所有活动暂停,记录所有活动的资源基本信息：工作时间、剩余工作时间、已完成的工作量、剩余工作量、技能需求量
            %给冲突活动按照softmax机制,资源指派按照hl&ln规则
            repair_solution2 = adjust_repair(leave_infos(index), performing_acts_infos);

            if objective1 < objective2
                repair_solution = repair_solution1;
            end

            schedule_solution = repair_solution;
        end

    end

end
