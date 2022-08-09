function [data_set, leave_infos] = read_data(project_para)
    global DataSet LeaveInfos

    num_j = project_para.num_j;
    L = project_para.L;
    resource_cate = project_para.resource_cate;

    % read dataset
    R = zeros(1, resource_cate, L); %局部资源可用量
    r = zeros(num_j, resource_cate, L); %局部资源需求量
    d = zeros(num_j, 1, L); %计划工期
    E = zeros(num_j, num_j - 2, L); %紧后活动集合

    for i = 1:L
        [R1, r1, d1, E1] = process_rcp(DataSet(i, :), resource_cate, num_j); %使用问题库算例时候，数据提取需要补充
        R(:, :, i) = R1; % 第三个维度表示项目数
        r(:, :, i) = r1; % 第三个维度表示项目数
        d(:, :, i) = d1; % 第三个维度表示项目数
        E(:, :, i) = E1;
    end

    % 私自修改数据R，r
    for i = 1:size(r, 3) % i活动数
        r(:, 4, i) = 0; % 使得r的第四列均为0 （即最后一列）
        R(1, 4, i) = 0; % 使得R的第四列为0即不需要第四类局部资源，因为下面需要把第四类局部资源改为需要全局资源
    end

    GlobalSourceRequest = [0, 1, 2, 3, 0; 0, 2, 1, 1, 0];
    skill_cate = [0, 1, 2, 3, 0; 0, 1, 2, 3, 0];
    %3.2 随机生成3、4   Lgs技能资源矩阵
    Lgs = [1, 0.8, 0, 0.6, 0; 0.8, 0, 1, 0.8, 0.6; 0.6, 0.6, 0.8, 0, 1];
    original_skill_num = sum(Lgs ~= 0, 2)';
    ad = [0, 2];

    data_set.R = R;
    data_set.r = r;
    data_set.d = d;
    data_set.E = E;
    data_set.GlobalSourceRequest = GlobalSourceRequest;
    data_set.skill_cate = skill_cate;
    data_set.Lgs = Lgs;
    data_set.original_skill_num = original_skill_num;
    data_set.ad = ad;

    % read leave info
    for idx = 1:L
        leave_infos = LeaveInfos;
    end

    leave_infos.leave_staff = [1, 4];
    leave_infos.leave_duration = [2, 2];
    leave_infos.leave_time = [3, 6];
    leave_infos.return_time = [5, 8];
end
