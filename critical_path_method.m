function [CPM, cpm_start_time, cpm_end_time] = critical_path_method(d, E)
    %mΪ���
    %LΪ��Ŀ��
    %RΪ�ֲ���Դ��������
    %������succeedset
    %��ǰ���forward_set

    num_j = length(d);
    L = 1; % ֻ����һ����Ŀ�Ĺؼ�·��
    forward_set = cal_forward_set(E, num_j);
    cpm_start_time = zeros(L, num_j);
    cpm_end_time = zeros(L, num_j); %��ʼ����ʼʱ�������ʱ��
    %��CPM����
    for i = 2:num_j
        predecessors = forward_set(i, :); % activity�Ľ�ǰ� [1 0 0 0 0]
        max_endtime = 0;

        for x = 1:length(predecessors) % Ѱ�ҽ�ǰ�������endtime

            if (predecessors(x) ~= 0 && cpm_end_time(predecessors(x)) > max_endtime)
                max_endtime = cpm_end_time(predecessors(x));
            end

        end

        cpm_start_time(i) = max_endtime; %��ǰ�������깤ʱ��
        cpm_end_time(i) = cpm_start_time(i) + d(i);
    end

    CPM = max(cpm_end_time);
end
