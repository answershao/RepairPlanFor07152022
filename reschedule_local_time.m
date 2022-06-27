function [temp_variables] = reschedule_local_time(temp_variables, time, forward_set)
    temp_d = temp_variables.d;
    % ��Ŀ�ʼʱ�����ʱ��
    temp_local_start_times = temp_variables.local_start_times;
    temp_local_end_times = temp_variables.local_end_times;

    [L, num_j] = size(temp_local_end_times);

    for i = 1:L
        temp = temp_local_start_times(i, :); % ȷ��ÿһ�����˳��
        [value, index] = sort(temp); %��������

        for act = 1:length(value)

            if value(act) >= time
                pro = forward_set(index(act), :, i); % ���pro��Ӧ�����ֵ���Ҹû�Ľ�ǰ�
                pro(find(pro == 0)) = []; % ȥ��Ϊ0��Ԫ��,���½�ǰ�

                if ~isempty(pro)
                    time1 = max(temp_local_end_times(i, pro)); %Ѱ�ҽ�ǰ�����ʱ��
                    temp_local_start_times(i, index(act)) = max(time1, temp_local_start_times(i, index(act))); %����ǰ����ʱ���뵱ǰʱ����ȣ�ȷ������
                    temp_local_end_times(i, index(act)) = temp_local_start_times(i, index(act)) + temp_d(index(act), 1, i);
                end

            end

        end

    end

    temp_variables.local_start_times = temp_local_start_times;
    temp_variables.local_end_times = temp_local_end_times;

end
