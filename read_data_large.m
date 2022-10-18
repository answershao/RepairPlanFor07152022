function [data_set] = read_data_large(project_para, FileName)

    num_j = project_para.num_j;
    L = project_para.L;
    resource_cate = project_para.resource_cate;
    skill_count = project_para.skill_count;
    people = project_para.people;

    %1.2 算例参数设置
    %1.3 解析文件夹
    %     for file = 1:5
    %FolderPath = strcat('D:\\科研小强\\SCI\\问题集-mpsplip\\j30\\MP30_2\\mp_j30_a2_nr5');
    %10个活动2，5，10，20项目\\',num2str(L),'-10\\',num2str(L),'-', num2str(OS), '-',num2str(RF), '-',num2str(RS));
    %1.4 读取多项目数据
    R = zeros(1, resource_cate, L); %局部资源可用量
    r = zeros(num_j, resource_cate, L); %局部资源需求量
    d = zeros(num_j, 1, L); %计划工期
    E = zeros(num_j, num_j - 2, L); %紧后活动集合

    for i = 1:L
        [R1, r1, d1, E1] = process_rcp(FileName(i, :), resource_cate, num_j); %使用问题库算例时候，数据提取需要补充
        R(:, :, i) = R1; % 第三个维度表示项目数
        r(:, :, i) = r1; % 第三个维度表示项目数
        d(:, :, i) = d1; % 第三个维度表示项目数
        E(:, :, i) = E1;
    end

    %% 二.各PA初始化局部调度准备
    % 2.1 私自修改数据R，r
    for i = 1:size(r, 3) % i活动数
        r(:, 4, i) = 0; %使得 r的第四列均为0 （即最后一列）
        R(1, 4, i) = 0;
        %使得R的第四列为0即不需要第四类局部资源，因为下面需要把第四类局部资源改为需要全局资源
    end

    %2.2 计算紧前活动 forestset
    %         for i=1:L
    %             forestset(:,:,i) = find_forestset(E(:,:,i), num_j);
    %         end
    %2.3 计算关键路径工期CPM
    % CPM                       关键路径工期              1 * L
    % cpm_start_time            活动开始时间              L * num_j
    % cpm_end_time              活动结束时间              L * num_j
    %         parfor i=1:L
    %             sprintf('关键路径工期进度:%d / %d',i, L)
    %             [CPM(i), cpm_start_time(i,:), cpm_end_time(i,:)] = cpm(d(:,:,i), E(:,:,i));
    %         end
    %% 三.CA全局协调决策准备
    %3.1 随机生成1、2  GlobalSourceRequest，skill_cate
    % GlobalSourceRequest---全局资源需求量  L * num_j
    % skill_cate--每个活动需要的技能种类   L * num_j（本文假设每个活动需要1种技能，多人完成）
    rand('seed', 1);
    GlobalSourceRequest = round(rand(L, size(r, 1)) * 3); %全局资源需求量[1,3]随机选取，rand(L, size(r,1))矩阵维度
    GlobalSourceRequest(:, 1) = 0; GlobalSourceRequest(:, num_j) = 0; %保证虚活动需求量均为0
    %GlobalSourceRequest = ceil(3 * rand(L, size(r,1)));%全局资源需求量[1,3]随机选取，rand(L, size(r,1))矩阵维度
    rand('seed', 2);
    skill_cate = ceil(skill_count * rand(L, size(r, 1))); %活动需要的技能种类[1,5]随机选取

    for i = 1:L

        for j = 1:size(r, 1)

            if GlobalSourceRequest(i, j) %若GlobalSourceRequest有数值，即该活动需要全局资源,即需要技能
                continue
            else
                skill_cate(i, j) = 0;
            end

        end

    end

    %3.2 随机生成3、4   Lgs技能资源矩阵
    a = [0.6 0.8 1.0];
    rand('seed', 3);
    Lgs = a(unidrnd(length(a), skill_count, people));

    for j = 1:size(Lgs, 2)

        a = [skill_count - 3, skill_count - 2]; %非零的个数，要么2要么3
        b = randperm(length(a)); %把 1,2随机，只选择第一个，因为有了随机性

        if a(b(1)) ~= 0
            c = randperm(skill_count, a(b(1)));

            for jj = 1:length(c)
                Lgs(c(jj), j) = 0;
            end

        end

        % end
        original_skill_num = sum(Lgs ~= 0, 2)';
    end

    %     end

    data_set.R = R;
    data_set.r = r;
    data_set.d = d;
    data_set.E = E;
    data_set.GlobalSourceRequest = GlobalSourceRequest;
    data_set.skill_cate = skill_cate;
    data_set.Lgs = Lgs;
    data_set.original_skill_num = original_skill_num;
end
