function f = multation_8(gen, E, num_j) %活动列表变异
    t1 = 1 + randi(num_j - 2); %randi(m-2)的取值为[1,m-2],t1的取值范围为[2,m-1]

    if ~ismember(gen(t1 + 1), E(gen(t1), :, 1)) %如果gen(t1+1)不在succeed{gen(t1)}中，则交换基因位置
        t2 = gen(t1);
        gen(t1) = gen(t1 + 1);
        gen(t1 + 1) = t2;
    end

    f = gen; %1*32
end

% function f=multation(gen,succeedset,m,q,wnn,p)  %活动列表变异
% t1=1+randi(m-2);              %randi(m-2)的取值为[1,m-2],t1的取值范围为[2,m-1]
% if ~ismember(gen(t1+1),succeedset{p*wnn-p+q,gen(t1)})  %如果gen(t1+1)不在succeed{gen(t1)}中，则交换基因位置
%     t2=gen(t1);
%     gen(t1)=gen(t1+1);
%     gen(t1+1)=t2;
% end
% f=gen;
% end
