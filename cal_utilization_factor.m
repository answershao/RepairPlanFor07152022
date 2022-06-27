function [util_factor] = cal_utilization_factor(project_para, data_set, cpm)
    %   求多项目资源利用系数 util_factor
    % used para
    L = project_para.L;
    num_j = project_para.num_j;
    GlobalSourceRequest = data_set.GlobalSourceRequest;

    Lgs = data_set.Lgs;
    CPM = cpm.CPM;
    cpm_start_time = cpm.start_time;
    cpm_end_time = cpm.end_time;

    EveryTime_GS = zeros(1, max(cpm_end_time(:))); %每个时间段全局资源需求量之和(1*26)

    for i = 1:L

        for j = 1:num_j

            for time = cpm_start_time(i, j) + 1:cpm_end_time(i, j)
                EveryTime_GS(1, time) = EveryTime_GS(1, time) + GlobalSourceRequest(i, j);
            end

        end

    end

    %全局资源需求量矩阵里所有元素的最大值
    %取出每个时段全局需求量之和的最大值
    % GlobalSourceTotal =randi([max(max(GlobalSourceRequest)),max(EveryTime_GS)],1,1) ;%全局资源可用量（总人数）,从a到b 中随机选取一个整数即可
    % 分母
    GCPD = max(CPM); % 输入CPM最大值,关键路径工期
    % 分子
    ES = sum(EveryTime_GS); %每个时段全局需求量之和
    % average utilization factor
    util_factor = [];
    util_factors = [];

    EverySkill(1, :) = (sum(Lgs ~= 0, 2))'; %每种技能可用量

    for j = 1:length(EverySkill)
        util_factor(j) = double(ES) / (EverySkill(1, j) * GCPD);
        util_factors = [util_factors; util_factor(j)];
    end

    util_factor = max(util_factors);
end
