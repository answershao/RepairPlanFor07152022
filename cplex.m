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

    forward_set = cal_forward_set(E, length(d)); %紧前活动集合

    %cplex 此处显示有关此函数的摘要

    T = 100; %时间段
    J = length(d); %活动数
    t = (1:1:T)'; %t为时间段取整数
    K = length(R);
    time = 1; %????模仿系统工程中cplex里的
    Real_update_local = zeros(L, num_j, T);
    % 决策变量
    x = binvar(J, T, 'full'); % x为0,1变量

    %目标 % 1式
    z = sum(x * t); %j*t*t*1
    %约束添加
    C = [];
    %%  2式  12个约束 + 12
    for j = 1:J
        s = sum(x(j, :));
        C = [C, s == 1];
    end

    %%  3式  21个约束 紧后活动集合
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

    %%  4式 K*T 个约束
    for k = 1:K % K个约束

        for q = 1:T % T个约束
            sleft = 0;

            for j = 2:J - 1 % 首尾虚 活动跳过  J-2 约束

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

    %参数设置
    ops = sdpsettings('verbose', 0, 'solver', 'cplex');
    %求解
    result = optimize(C, z);

    if result.problem == 0
        a = value(x);
        value(z);
    else
        disp('求解过程出错');
    end

    %% 获取每个活动的完成时间
    local_end_time = [];

    for i = 1:size(a, 1)
        %寻找当前行k中的1所在的位置
        for j = 1:size(a, 2)

            if (a(i, j) ~= 0)
                local_end_time = [local_end_time, j + ad]; %为什么j+ad
                break;
            end

        end

    end

    %% 获取每个活动的开始时间
    local_start_time = local_end_time - d';
end
