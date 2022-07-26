function [timeoff, performing_acts_infos] = cal_timeoff(iter_variables, leave_infos, time)

    % TIMEOFF �˴���ʾ�йش˺�����ժҪ
    % timeoff.time
    % timeoff.staff
    % timeoff.duration
    % timeoff.activity

    % ����ٵ� %leave_infos.leave_time��ÿ���޸��ƻ�����֮����
    [~, index] = ismember(time, leave_infos.leave_time);

    if index ~= 0
        timeoff.time = leave_infos.leave_time(index);
        timeoff.staff = leave_infos.leave_staff(index);
        timeoff.duration = leave_infos.duration(index);

        % �����Ƕ��ֵ
        [timeoff, performing_acts_infos] = find_staff_doing_activity(iter_variables, timeoff);
    else
        %��ǰʱ�̲������ʱ�̣�Ӧ��ѭ������һʱ��
    end

    %�����ǰʱ�̲������ʱ�̣����޷����timeoff
end
