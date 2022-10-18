function [LP, yb, box_pro] = find_LP(L2) %��L2�е���Ŀ�������һ�����Ԫ����
    box_pro = []; %���L2�е���Ŀ����

    for xb = 1:length(L2)
        pro = L2{1, xb}(1, 1); %ȡ��L2�е�xb�����������Ϊ��Ŀ����
        box_pro(xb) = pro;
    end

    [yb, pro_index] = unique(box_pro); %�ҵ�box_pro�в��ظ�����Ŀ����ybΪ��Ŀ����indexΪ��Ŀ�����ڵ�λ��

    %ȷ������Ŀ�г��ֵĳ�ͻ�����
    LP = cell(length(yb), length(L2)); %���浱ǰ��ͻʱ���µĸ��

    for zb = 1:length(yb)
        [ub, un] = find(box_pro == yb(zb)); %�ҵ�box_pro�е�����Ŀ ��λ��un,length(un)<length(L2)
        % if wb>1 %�������1 ������ȡ��Ŀ����Ϊzb�ļ����

        for yyy = 1:length(un)
            LP{zb, yyy} = L2{1, un(1, yyy)};
        end

    end

    %���˵��յ�Ԫ������
