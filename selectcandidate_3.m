function [gen, candidate] = selectcandidate_3(j, candidate, E, forward_set, gen)
    lencan = length(candidate); %lencan为候选集合长度,不断增加的？

    if lencan == 0
        candidate = 1;
    else
        rand_number = randi(lencan, 1, 1); %随机抽取一个小于等于lencan的整数，假设开始只有活动1
        gen(1, j) = candidate(1, rand_number); %将选出的活动放到活动列表的对应位置，想增加项目变三维，想跟紧后活动E一样表示，而不是把项目单独拿出来在前边for i =1:L,
        candidate(rand_number) = []; %从候选活动中删除该活动
        B = E(gen(1, j), :, 1); %B为活动的紧后活动集合
        B1 = length(find(B ~= 0)); %判断B中不为0 的个数
        count = 0;

        for k = 1:B1
            F = forward_set(B(k), :, 1); %F为B中第k个活动的紧前活动集合
            F(find(F == 0)) = [];

            if length(intersect(gen(1:j), F)) == length(F) %B(k)的紧前活动集和已安排活动的交集的个数与B(k)的紧前活动的个数相同
                count = count + 1;
                candidate(1, lencan + count - 1) = B(k); %将满足条件的活动B(k)加入到candidate中,把之前未选择的紧后活动的
            end

        end

    end

    % function [gen,candidate]=selectcandidate(candidate,succeedset,foreset,gen,j,q,wen,p)
    % lencan=length(candidate);  %lencan为候选集合长度
    % r=randi(lencan,1,1);  %随机抽取一个小于等于lencan的整数
    % gen(1,j)=candidate(1,r); %将选出的活动放到活动列表的对应位置
    % candidate(r)=[];  %从候选活动中删除该活动
    % B=succeedset{p*wen-p+q,gen(1,j)};  %B为选中活动的紧后活动集合
    % lenB=length(B);  %紧后活动的个数
    % count=0;
    % for k=1:lenB
    %     F=foreset{p*wen-p+q,B(k)}; %F为B中第k个活动的紧前活动集合
    %     if length(intersect(gen(1:j),F))==length(F)  %B(k)的紧前活动集和已安排活动的交集的个数与B(1，i)的紧前活动的个数相同
    %         count=count+1;
    %         candidate(1,lencan+count-1)=B(k);  %将满足条件的活动B(k)加入到candidate中
    %     end
    % end
    % end
