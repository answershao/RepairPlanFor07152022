function [timeoff, performing_acts_infos] = find_staff_doing_activity(iter_allocated_acts_information, timeoff)

leave_time = timeoff.leave_time;

   order = 0; save_start_time = []; save_eachtime_acts_info = {};
    for i = 1:length(iter_allocated_acts_information)
        eachtime_acts_info = iter_allocated_acts_information{i};

        [~, index_leave] = ismember(timeoff.leave_staff, eachtime_acts_info.allocated_resource_num); %针对每个已经分配的活动找请假员工是否在内
        if index_leave ~= 0 %说明请假员工在整个项目中有在执行活动
            %判断该活动是在其请假前、请假中、请假后？
            order = order + 1;
            %         save_pro_acts{order} =  eachtime_acts_info.project_and_activity;%save请假活动
            %请假员工整个项目所执行活动的start-end time
            start_time = eachtime_acts_info.activity_start_time;
            %判断leave_time几种情况
            save_start_time (order) = start_time;
            save_eachtime_acts_info{order} = eachtime_acts_info;
        end

    end

    [~, index_start] = sort(save_start_time); %把请假人员所在活动的开始时间从小到大排序，index_start代表开始时间对应位置

    
    sort_eachtime_acts_info = save_eachtime_acts_info(index_start); %将最小的开始时间的活动记录，从它开始找

    %% 找到请假员工在整个项目中执行的活动了
    to_schedule = 0;

    for j = 1:length(sort_eachtime_acts_info)
        iter_eachtime_acts_info = sort_eachtime_acts_info{j};
        start_time = iter_eachtime_acts_info.activity_start_time;
        end_time = iter_eachtime_acts_info.activity_end_time;
        %1.start<=leave_time<=end -1
        if end_time <= leave_time
            %时刻已过，不影响基线中已经分配好的活动，不调度
            continue
        elseif start_time <= leave_time && leave_time< end_time %说明该活动为请假活动,即请假时员工在执行活动
            %请假人员未回，影响基线中已分配好的活动，当前时刻有请假活动，应调度
            to_schedule = 1;
            break
        else
            % leave_time <start_time
            if start_time < timeoff.return_time
                %请假人员未回，影响基线中已分配好的活动，starttime时刻才有请假活动，应调度
                to_schedule = 1;
                leave_time = start_time;
                break
            elseif timeoff.return_time <= start_time
                %请假人员已回，不影响基线中已分配好的活动
                continue
            end

        end

    end

    %     else %请假员工不执行该活动，继续循环下一个活动，查看！整个项目一定会找到某员工在执行活动，即员工一定会被分配！
    timeoff.leave_time = leave_time;
    timeoff.return_time = timeoff.leave_time + timeoff.leave_duration;

    if to_schedule
        timeoff.leave_activity_infos.skill_value = iter_eachtime_acts_info.skill_value;
        timeoff.leave_activity_infos.allocated_resource_num = iter_eachtime_acts_info.allocated_resource_num;
        timeoff.leave_activity_infos.project_and_activity = iter_eachtime_acts_info.project_and_activity;
        timeoff.leave_activity_infos.activity_start_time = iter_eachtime_acts_info.activity_start_time;
        timeoff.leave_activity_infos.activity_end_time = iter_eachtime_acts_info.activity_end_time;
        timeoff.leave_activity_infos.performing_time = iter_eachtime_acts_info.performing_time;
    else
        timeoff.leave_activity_infos = {};
    end

    count = 0;
    performing_acts_infos = {}; %储存time时刻正在执行的活动信息

    for i = 1:length(iter_allocated_acts_information)
        eachtime_acts_info = iter_allocated_acts_information{i};

        if eachtime_acts_info.performing_time == timeoff.leave_time %找到了请假时刻的活动信息，一定会找到每个时刻都有在执行的活动
            %         1.先记录time 时刻正在执行所有活动的信息
            count = count + 1;
            performing_acts_infos{count} = eachtime_acts_info;
        end

    end

    %遍历请假时刻的活动信息
    %     if eachtime_acts_info.performing_time == timeoff.leave_time %找到了请假时刻的活动信息，一定会找到每个时刻都有在执行的活动
    %         %         1.先记录time 时刻正在执行所有活动的信息
    %         count = count + 1;
    %         performing_acts_infos{count} = eachtime_acts_info;
    %
    %         %2.再找请假时刻请假员工正在执行的活动信息
    %         %2.1请假时并未在执行活动,更新Lgs,skill_num
    % %         if eachtime_variables_info.Lgs(:,timeoff.leave_staff)~=0 %请假员工列b不为0，说明请假时并未在执行活动，更新Lgs,skill_num
    % %             eachtime_variables_info.Lgs(:, timeoff.leave_staff) = 0;
    % %             eachtime_variables_info.skill_num = (sum(eachtime_variables_info.Lgs ~= 0, 2))';
    % %             iter_allocated_variables_information{timeoff.leave_time} = eachtime_variables_info;
    % %         else %2.2请假时在执行活动的信息,就不需要 更新了，因为分配时已经更新了
    %             %如果该时刻有多个活动同时进行，及时改员工请假也不一定在执行
    %             [~, index_leave] = ismember( timeoff.leave_staff,eachtime_acts_info.allocated_resource_num);
    %             if index_leave ~= 0%说明该活动为请假活动,即请假时员工在执行活动
    %                 timeoff.leave_activity_infos.skill_value = eachtime_acts_info.skill_value;
    %                 timeoff.leave_activity_infos.allocated_resource_num = eachtime_acts_info.allocated_resource_num;
    %                 timeoff.leave_activity_infos.project_and_activity = eachtime_acts_info.project_and_activity;
    %                 timeoff.leave_activity_infos.activity_start_time = eachtime_acts_info.activity_start_time;
    %                 timeoff.leave_activity_infos.activity_end_time = eachtime_acts_info.activity_end_time;
    %                 timeoff.leave_activity_infos.performing_time = eachtime_acts_info.performing_time;
    %             else %请假员工在请假时刻没有在执行活动
    %                 %后续判断其返回时刻之前是否在执行活动，如果执行，记录请假活动
    %                 timeoff.leave_activity_infos = {}; %    else timeoff.leave_activity_infos 为空集
    %             end
    %     end%else performing_acts_infos 为空集，不可能出现

    %             timeoff.unallocated_resource_num = eachtime_act_info.unallocated_resource_num
