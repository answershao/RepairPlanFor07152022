function [timeoff, performing_acts_infos] = cal_timeoff(iter_variables, leave_infos, time)

    % TIMEOFF 此处显示有关此函数的摘要
    % timeoff.time
    % timeoff.staff
    % timeoff.duration
    % timeoff.activity

    % 是请假点 %leave_infos.leave_time需每次修复计划后随之更新
    [~, index] = ismember(time, leave_infos.leave_time);

    if index ~= 0
        timeoff.time = leave_infos.leave_time(index);
        timeoff.staff = leave_infos.leave_staff(index);
        timeoff.duration = leave_infos.duration(index);

        % 可能是多个值
        [timeoff, performing_acts_infos] = find_staff_doing_activity(iter_variables, timeoff);
    else
        %当前时刻不是请假时刻，应该循环到下一时刻
    end

    %如果当前时刻不是请假时刻，则无法输出timeoff
end
