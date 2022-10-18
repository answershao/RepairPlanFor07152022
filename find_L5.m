function [L5] = find_L5(L2, LP, yb)
    global max_iteration
    % yb = [3,4]
    % order = [1: length(yb)];
    iterations = factorial(length(yb));
    order = [1:length(yb)];
    % L3 = perms(order);
    if length(order) > 10
        iter_order = order(1:2:end); %��2����ȡ1��ֵ
        L3 = perms(iter_order);
    else
        L3 = perms(order);
    end

    L4 = L3(1:min(iterations, max_iteration), :); %ȡ���׳˺�Ԥ��̸����С����Ϊ����̸�д���
    L5 = cell(size(L4, 1), size(L4, 1) * length(L2)); %������PA���û˳��������������ĸ�����Ŀ�ִ��˳��
    %L6 = cell(size(L4,1),length(L2));
    for hang = 1:size(L4, 1)

        for lie = 1:size(L4, 2)
            L5(hang, (lie - 1) * length(L2) + 1:lie * length(L2)) = LP(L4(hang, lie), :); %1-6���ڶ������ķŵ�7-12,13-18
        end

    end

    % for ha = 1:size(L5,1)
    %     for li = 1:size(L5,2)
    %        if L5(ha, li) ~=[]  %���ζ�L5��ĳ���е�ÿһ�У�������Ƿǿգ����ȡ��Ŀ���ͻ��
    %            n = 0;
    %            n = n+1;
    %            L6 (ha,n) = L5(ha,li);
    %
    %
    %        end
    %       %�������ǿո�������������
    %     end
    % end

    %L5(cellfun(@isempty,L5)) = [];  %��������Ŀ�ĳ�ͻ�����һ�£�����ά�Ȳ�һʱ���ո���ֻ���
    %L6 =  reshape(L5, size(L4,1),length(L2));
