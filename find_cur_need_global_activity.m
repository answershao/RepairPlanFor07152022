function [cur_need_global_activity] = find_cur_need_global_activity(iter_variables, NeedGlobal, time, allocated_set )
    local_start_times = iter_variables.local_start_times;

    % Ѱ��L2
    st = zeros(1, length(NeedGlobal));

    for x = 1:length(NeedGlobal) %����NeedGlobal��ÿ������
        i = NeedGlobal{1, x}(1, 1); %ȡ��NeedGlobal�е�x�����������Ϊ��Ŀ����
        j = NeedGlobal{1, x}(1, 2); %ȡ��NeedGlobal�е�x�����������Ϊ�����
        % st(x)= local_start_times(i,j);%�ҵ���Щ��Ŀ�ʼʱ��
        if isempty(allocated_set)
            st(x) = local_start_times(i, j); %�ҵ���Щ��Ŀ�ʼʱ��
        else
            count = 0;
            m = 1;

            while m <= length(allocated_set)
                xx = ([i, j] == allocated_set{1, m});

                if xx(1) == 1 && xx(2) == 1
                    break
                else
                    count = count + 1;
                    m = m + 1;
                end

                if count == length(allocated_set)
                    st(x) = local_start_times(i, j); %�ҵ���Щ��Ŀ�ʼʱ��
                end

            end

        end

    end

    if ismember(time, st)
        [m, n] = find(st == time); %�ҵ�time ֵ��Ӧ��st�е�λ��
        cur_need_global_activity = cell(1, length(n));

        for y = 1:length(n)
            cur_need_global_activity{1, y} = NeedGlobal{1, n(1, y)};
        end

    else
        cur_need_global_activity = [];
    end

end
