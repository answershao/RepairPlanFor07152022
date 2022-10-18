function [L5] = find_L5(L2, LP, yb)
    global max_iteration
    % yb = [3,4]
    % order = [1: length(yb)];
    iterations = factorial(length(yb));
    order = [1:length(yb)];
    % L3 = perms(order);
    if length(order) > 10
        iter_order = order(1:2:end); %等2间距的取1个值
        L3 = perms(iter_order);
    else
        L3 = perms(order);
    end

    L4 = L3(1:min(iterations, max_iteration), :); %取出阶乘和预设谈判最小的作为本次谈判次数
    L5 = cell(size(L4, 1), size(L4, 1) * length(L2)); %当各个PA定好活动顺序后，用来储存具体的各个项目活动执行顺序
    %L6 = cell(size(L4,1),length(L2));
    for hang = 1:size(L4, 1)

        for lie = 1:size(L4, 2)
            L5(hang, (lie - 1) * length(L2) + 1:lie * length(L2)) = LP(L4(hang, lie), :); %1-6，第二个来的放到7-12,13-18
        end

    end

    % for ha = 1:size(L5,1)
    %     for li = 1:size(L5,2)
    %        if L5(ha, li) ~=[]  %依次读L5的某行中的每一列，如果不是非空，则读取项目数和活动数
    %            n = 0;
    %            n = n+1;
    %            L6 (ha,n) = L5(ha,li);
    %
    %
    %        end
    %       %否则若是空格，则跳过，不读
    %     end
    % end

    %L5(cellfun(@isempty,L5)) = [];  %当两个项目的冲突活动数不一致，即不维度不一时，空格出现混乱
    %L6 =  reshape(L5, size(L4,1),length(L2));
