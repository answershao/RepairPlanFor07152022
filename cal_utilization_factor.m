function [util_factor] = cal_utilization_factor(project_para, data_set, cpm)
    %   求多项目资源利用系数 util_factor
    % used para
    L = project_para.L;
    num_j = project_para.num_j;
    GlobalSourceRequest = data_set.GlobalSourceRequest;
    skill_count = project_para.skill_count;
    skill_cate = data_set.skill_cate;
    d = data_set.d;

    Lgs = data_set.Lgs;
    CPM = cpm.CPM;
    cpm_start_time = cpm.start_time;
    cpm_end_time = cpm.end_time;

    EveryTime_GS = zeros(1, max(cpm_end_time(:))); %每个时间段全�?资源�?求量之和(1*26)

    for i = 1:L

        for j = 1:num_j

            for time = cpm_start_time(i, j) + 1:cpm_end_time(i, j)
                EveryTime_GS(1, time) = EveryTime_GS(1, time) + GlobalSourceRequest(i, j);
            end

        end

    end

    %全局资源�?求量矩阵里所有元素的�?大�??
    %取出每个时段全局�?求量之和的最大�??
    % GlobalSourceTotal =randi([max(max(GlobalSourceRequest)),max(EveryTime_GS)],1,1) ;%全局资源可用量（总人数）,从a到b 中随机�?�取�?个整数即�?
    % 分母
    GCPD = max(CPM); % 输入CPM�?大�??,关键路径工期
    % 分子
    %     ES = sum(EveryTime_GS); %每个时段全局�?求量之和
    % average utilization factor
    %% ��UF
    %1.����
    only_skill_num = [];
    all_skill_num = [];

    for i = 1:skill_count
        [a, index1] = find(skill_cate == i);

        for i1 = 1:length(a)
            only_skill_num(i1) = (GlobalSourceRequest(a(i1), index1(i1))) .* (d(index1(i1), :, a(i1)));
        end

        all_skill_num(i) = sum(only_skill_num);
    end

    %2.UF��ʽ
    util_factor = [];
    util_factors = [];

    EverySkill(1, :) = (sum(Lgs ~= 0, 2))'; %每种�?能可用量

    for j = 1:length(EverySkill)
        util_factor(j) = double(all_skill_num(1, j)) / (EverySkill(1, j) * GCPD);
        util_factors = [util_factors; util_factor(j)];
    end

    util_factor = max(util_factors);
end
