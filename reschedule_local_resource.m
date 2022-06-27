function [temp_variables] = reschedule_local_resource(project_para, data_set, temp_variables, time)
    T = project_para.T;
    r = data_set.r;
    temp_R = temp_variables.R; %�ֲ���Դ������
    temp_d = temp_variables.d;
    temp_local_start_times = temp_variables.local_start_times;
    temp_local_end_times = temp_variables.local_end_times;
    [L, num_j] = size(temp_local_end_times);

    %% ���� ����ʱ��� temp2_R�ֲ���Դ������
    for t = 1:T
        temp2_R(:, :, :, t) = temp_R;
    end

    for t = 1:time
        [row, col] = find(temp_local_start_times == t);

        for i = 1:length(row)

            for tt = t:t + temp_d(col(i), 1, row(i)) - 1
                temp2_R(:, :, row(i), tt) = temp2_R(:, :, row(i), tt) - r(col(i), :, row(i)); %�����ʱ��ʣ��ֲ���Դ������ % �Ѱ��������е�ǰʱ�估��֮ǰ�Ļ
            end

        end

    end

    for i = 1:L
        temp = temp_local_start_times(i, :); % �ٴ�ȷ��ÿһ���Ļ��˳���жϿ�ʼʱ����ڵ�ǰʱ��time�Ļ
        [value, index] = sort(temp); %value ��Ŀ�ʼʱ�� %index ����

        for act = 1:length(value)

            if value(act) > time
                t = value(act);

                while t < 1000 % ��ѭ������ѭ��
                    count = 0;

                    if temp_d(index(act), 1, i) == 0
                        break
                    end

                    for tt = t:t + temp_d(index(act), 1, i) - 1 % ��ѭ����������ѭ��

                        if (r(index(act), 1, i) <= temp2_R(1, 1, i, tt)) && (r(index(act), 2, i) <= temp2_R(1, 2, i, tt)) && (r(index(act), 3, i) <= temp2_R(1, 3, i, tt)) %������Դ
                            count = count + 1;
                        else
                            break
                        end

                        if count == temp_d(index(act), 1, i) % �ж��Ƿ���Ҫ������Դ

                            for ttx = t:t + temp_d(index(act), 1, i) - 1
                                temp2_R(:, :, i, ttx) = temp2_R(:, :, i, ttx) - r(index(act), :, i);
                            end

                            temp_local_start_times(i, index(act)) = t;
                            temp_local_end_times(i, index(act)) = t + temp_d(index(act), 1, i);
                            t = 1000;
                        end

                    end

                    t = t + 1;
                end

            end

        end

    end

    temp_variables.local_start_times = temp_local_start_times;
    temp_variables.local_end_times = temp_local_end_times;
end
