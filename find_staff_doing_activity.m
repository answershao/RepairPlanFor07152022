function [timeoff, performing_acts_infos] = find_staff_doing_activity(iter_allocated_acts_information, timeoff)

leave_time = timeoff.leave_time;

   order = 0; save_start_time = []; save_eachtime_acts_info = {};
    for i = 1:length(iter_allocated_acts_information)
        eachtime_acts_info = iter_allocated_acts_information{i};

        [~, index_leave] = ismember(timeoff.leave_staff, eachtime_acts_info.allocated_resource_num); %���ÿ���Ѿ�����Ļ�����Ա���Ƿ�����
        if index_leave ~= 0 %˵�����Ա����������Ŀ������ִ�л
            %�жϸû���������ǰ������С���ٺ�
            order = order + 1;
            %         save_pro_acts{order} =  eachtime_acts_info.project_and_activity;%save��ٻ
            %���Ա��������Ŀ��ִ�л��start-end time
            start_time = eachtime_acts_info.activity_start_time;
            %�ж�leave_time�������
            save_start_time (order) = start_time;
            save_eachtime_acts_info{order} = eachtime_acts_info;
        end

    end

    [~, index_start] = sort(save_start_time); %�������Ա���ڻ�Ŀ�ʼʱ���С��������index_start����ʼʱ���Ӧλ��

    
    sort_eachtime_acts_info = save_eachtime_acts_info(index_start); %����С�Ŀ�ʼʱ��Ļ��¼��������ʼ��

    %% �ҵ����Ա����������Ŀ��ִ�еĻ��
    to_schedule = 0;

    for j = 1:length(sort_eachtime_acts_info)
        iter_eachtime_acts_info = sort_eachtime_acts_info{j};
        start_time = iter_eachtime_acts_info.activity_start_time;
        end_time = iter_eachtime_acts_info.activity_end_time;
        %1.start<=leave_time<=end -1
        if end_time <= leave_time
            %ʱ���ѹ�����Ӱ��������Ѿ�����õĻ��������
            continue
        elseif start_time <= leave_time && leave_time< end_time %˵���ûΪ��ٻ,�����ʱԱ����ִ�л
            %�����Աδ�أ�Ӱ��������ѷ���õĻ����ǰʱ������ٻ��Ӧ����
            to_schedule = 1;
            break
        else
            % leave_time <start_time
            if start_time < timeoff.return_time
                %�����Աδ�أ�Ӱ��������ѷ���õĻ��starttimeʱ�̲�����ٻ��Ӧ����
                to_schedule = 1;
                leave_time = start_time;
                break
            elseif timeoff.return_time <= start_time
                %�����Ա�ѻأ���Ӱ��������ѷ���õĻ
                continue
            end

        end

    end

    %     else %���Ա����ִ�иû������ѭ����һ������鿴��������Ŀһ�����ҵ�ĳԱ����ִ�л����Ա��һ���ᱻ���䣡
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
    performing_acts_infos = {}; %����timeʱ������ִ�еĻ��Ϣ

    for i = 1:length(iter_allocated_acts_information)
        eachtime_acts_info = iter_allocated_acts_information{i};

        if eachtime_acts_info.performing_time == timeoff.leave_time %�ҵ������ʱ�̵Ļ��Ϣ��һ�����ҵ�ÿ��ʱ�̶�����ִ�еĻ
            %         1.�ȼ�¼time ʱ������ִ�����л����Ϣ
            count = count + 1;
            performing_acts_infos{count} = eachtime_acts_info;
        end

    end

    %�������ʱ�̵Ļ��Ϣ
    %     if eachtime_acts_info.performing_time == timeoff.leave_time %�ҵ������ʱ�̵Ļ��Ϣ��һ�����ҵ�ÿ��ʱ�̶�����ִ�еĻ
    %         %         1.�ȼ�¼time ʱ������ִ�����л����Ϣ
    %         count = count + 1;
    %         performing_acts_infos{count} = eachtime_acts_info;
    %
    %         %2.�������ʱ�����Ա������ִ�еĻ��Ϣ
    %         %2.1���ʱ��δ��ִ�л,����Lgs,skill_num
    % %         if eachtime_variables_info.Lgs(:,timeoff.leave_staff)~=0 %���Ա����b��Ϊ0��˵�����ʱ��δ��ִ�л������Lgs,skill_num
    % %             eachtime_variables_info.Lgs(:, timeoff.leave_staff) = 0;
    % %             eachtime_variables_info.skill_num = (sum(eachtime_variables_info.Lgs ~= 0, 2))';
    % %             iter_allocated_variables_information{timeoff.leave_time} = eachtime_variables_info;
    % %         else %2.2���ʱ��ִ�л����Ϣ,�Ͳ���Ҫ �����ˣ���Ϊ����ʱ�Ѿ�������
    %             %�����ʱ���ж���ͬʱ���У���ʱ��Ա�����Ҳ��һ����ִ��
    %             [~, index_leave] = ismember( timeoff.leave_staff,eachtime_acts_info.allocated_resource_num);
    %             if index_leave ~= 0%˵���ûΪ��ٻ,�����ʱԱ����ִ�л
    %                 timeoff.leave_activity_infos.skill_value = eachtime_acts_info.skill_value;
    %                 timeoff.leave_activity_infos.allocated_resource_num = eachtime_acts_info.allocated_resource_num;
    %                 timeoff.leave_activity_infos.project_and_activity = eachtime_acts_info.project_and_activity;
    %                 timeoff.leave_activity_infos.activity_start_time = eachtime_acts_info.activity_start_time;
    %                 timeoff.leave_activity_infos.activity_end_time = eachtime_acts_info.activity_end_time;
    %                 timeoff.leave_activity_infos.performing_time = eachtime_acts_info.performing_time;
    %             else %���Ա�������ʱ��û����ִ�л
    %                 %�����ж��䷵��ʱ��֮ǰ�Ƿ���ִ�л�����ִ�У���¼��ٻ
    %                 timeoff.leave_activity_infos = {}; %    else timeoff.leave_activity_infos Ϊ�ռ�
    %             end
    %     end%else performing_acts_infos Ϊ�ռ��������ܳ���

    %             timeoff.unallocated_resource_num = eachtime_act_info.unallocated_resource_num
