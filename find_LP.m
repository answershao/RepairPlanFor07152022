function [LP, yb, box_pro] = find_LP(L2) %把L2中的项目分组放在一个大的元胞中
    box_pro = []; %存放L2中的项目数，

    for xb = 1:length(L2)
        pro = L2{1, xb}(1, 1); %取出L2中第xb个数组的行作为项目数，
        box_pro(xb) = pro;
    end

    [yb, pro_index] = unique(box_pro); %找到box_pro中不重复的项目数，yb为项目数，index为项目数所在的位置

    %确定各项目中出现的冲突活动个数
    LP = cell(length(yb), length(L2)); %储存当前冲突时刻下的各活动

    for zb = 1:length(yb)
        [ub, un] = find(box_pro == yb(zb)); %找到box_pro中等于项目 的位置un,length(un)<length(L2)
        % if wb>1 %如果大于1 ，则提取项目数均为zb的几个活动

        for yyy = 1:length(un)
            LP{zb, yyy} = L2{1, un(1, yyy)};
        end

    end

    %过滤掉空的元胞数组
