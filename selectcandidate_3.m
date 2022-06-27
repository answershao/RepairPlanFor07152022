function [gen, candidate] = selectcandidate_3(j, candidate, E, forward_set, gen)
    lencan = length(candidate); %lencanΪ��ѡ���ϳ���,�������ӵģ�

    if lencan == 0
        candidate = 1;
    else
        rand_number = randi(lencan, 1, 1); %�����ȡһ��С�ڵ���lencan�����������迪ʼֻ�л1
        gen(1, j) = candidate(1, rand_number); %��ѡ���Ļ�ŵ���б�Ķ�Ӧλ�ã���������Ŀ����ά���������Eһ����ʾ�������ǰ���Ŀ�����ó�����ǰ��for i =1:L,
        candidate(rand_number) = []; %�Ӻ�ѡ���ɾ���û
        B = E(gen(1, j), :, 1); %BΪ��Ľ�������
        B1 = length(find(B ~= 0)); %�ж�B�в�Ϊ0 �ĸ���
        count = 0;

        for k = 1:B1
            F = forward_set(B(k), :, 1); %FΪB�е�k����Ľ�ǰ�����
            F(find(F == 0)) = [];

            if length(intersect(gen(1:j), F)) == length(F) %B(k)�Ľ�ǰ������Ѱ��Ż�Ľ����ĸ�����B(k)�Ľ�ǰ��ĸ�����ͬ
                count = count + 1;
                candidate(1, lencan + count - 1) = B(k); %�����������ĻB(k)���뵽candidate��,��֮ǰδѡ��Ľ�����
            end

        end

    end

    % function [gen,candidate]=selectcandidate(candidate,succeedset,foreset,gen,j,q,wen,p)
    % lencan=length(candidate);  %lencanΪ��ѡ���ϳ���
    % r=randi(lencan,1,1);  %�����ȡһ��С�ڵ���lencan������
    % gen(1,j)=candidate(1,r); %��ѡ���Ļ�ŵ���б�Ķ�Ӧλ��
    % candidate(r)=[];  %�Ӻ�ѡ���ɾ���û
    % B=succeedset{p*wen-p+q,gen(1,j)};  %BΪѡ�л�Ľ�������
    % lenB=length(B);  %�����ĸ���
    % count=0;
    % for k=1:lenB
    %     F=foreset{p*wen-p+q,B(k)}; %FΪB�е�k����Ľ�ǰ�����
    %     if length(intersect(gen(1:j),F))==length(F)  %B(k)�Ľ�ǰ������Ѱ��Ż�Ľ����ĸ�����B(1��i)�Ľ�ǰ��ĸ�����ͬ
    %         count=count+1;
    %         candidate(1,lencan+count-1)=B(k);  %�����������ĻB(k)���뵽candidate��
    %     end
    % end
    % end
