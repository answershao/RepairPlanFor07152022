function [local_start_time, local_end_time] = cplex(project_para, data_set, i)
    % related to project L

    % used para
    L = project_para.L;
    num_j = project_para.num_j;
    resource_cate = project_para.resource_cate;

    % used data_set
    R = data_set.R(:, :, i);
    r = data_set.r(:, :, i);
    d = data_set.d(:, :, i);
    E = data_set.E(:, :, i);
    ad = data_set.ad(:, i);

    % new defined
    original_local_start_times = zeros(L, num_j);
    original_local_end_times = zeros(L, num_j);

    forward_set = cal_forward_set(E, length(d)); %��ǰ�����

    %cplex �˴���ʾ�йش˺�����ժҪ

    T = 100; %ʱ���
    J = length(d); %���
    t = (1:1:T)'; %tΪʱ���ȡ����
    K = length(R);
    time = 1; %????ģ��ϵͳ������cplex���
    Real_update_local = zeros(L, num_j, T);
    % ���߱���
    x = binvar(J, T, 'full'); % xΪ0,1����

    %Ŀ�� % 1ʽ
    z = sum(x * t); %j*t*t*1
    %Լ�����
    C = [];
    %%  2ʽ  12��Լ�� + 12
    for j = 1:J
        s = sum(x(j, :));
        C = [C, s == 1];
    end

    %%  3ʽ  21��Լ�� ��������
    for j = 1:num_j

        for index = 1:length(forward_set(1, :))

            if forward_set(j, index) ~= 0
                h = forward_set(j, index);
                s1 = x(h, :) * t;
                d1 = double(repmat(d(j), 1, T)');
                s2 = x(j, :) * (t - d1);
                C = [C, s2 - s1 >= 0];
            end

        end

    end

    %%  4ʽ K*T ��Լ��
    for k = 1:K % K��Լ��

        for q = 1:T % T��Լ��
            sleft = 0;

            for j = 2:J - 1 % ��β�� �����  J-2 Լ��

                if q + d(j) - 1 <= T
                    sleft = sleft + sum(x(j, q:q + d(j) - 1)) * r(j, k);
                else
                    sleft = sleft + sum(x(j, q:T)) * r(j, k);
                end

            end

            sr = R(k);
            C = [C, sr - sleft >= 0];
        end

    end

    col_x = [];

    if max(max(Real_update_local(1, :, time))) ~= 0
        [row, col] = find(Real_update_local(1, :, time) ~= 0);

        if time > 1

            for i = 1:length(col)

                if Real_update_local(1, col(i), time - 1) ~= Real_update_local(1, col(i), time)
                    col_x = [col_x, col(i)];
                else
                    tc = original_local_start_times(1, col(i)) + d(col(i), 1, 1);
                    s = sum(x(col(i), tc:end));
                    C = [C, s == 1];
                end

            end

        else
            col_x = col;
        end

        for i = 1:length(col_x)
            tc = 1 + time + d(col_x(i), 1, 1);
            s = sum(x(col_x(i), tc:end));
            C = [C, s == 1];
        end

    end

    %��������
    ops = sdpsettings('verbose', 0, 'solver', 'cplex');
    %���
    result = optimize(C, z);

    if result.problem == 0
        a = value(x);
        value(z);
    else
        disp('�����̳���');
    end

    %% ��ȡÿ��������ʱ��
    local_end_time = [];

    for i = 1:size(a, 1)
        %Ѱ�ҵ�ǰ��k�е�1���ڵ�λ��
        for j = 1:size(a, 2)

            if (a(i, j) ~= 0)
                local_end_time = [local_end_time, j + ad]; %Ϊʲôj+ad
                break;
            end

        end

    end

    %% ��ȡÿ����Ŀ�ʼʱ��
    local_start_time = local_end_time - d';
end
