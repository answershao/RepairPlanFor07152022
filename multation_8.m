function f = multation_8(gen, E, num_j) %��б����
    t1 = 1 + randi(num_j - 2); %randi(m-2)��ȡֵΪ[1,m-2],t1��ȡֵ��ΧΪ[2,m-1]

    if ~ismember(gen(t1 + 1), E(gen(t1), :, 1)) %���gen(t1+1)����succeed{gen(t1)}�У��򽻻�����λ��
        t2 = gen(t1);
        gen(t1) = gen(t1 + 1);
        gen(t1 + 1) = t2;
    end

    f = gen; %1*32
end

% function f=multation(gen,succeedset,m,q,wnn,p)  %��б����
% t1=1+randi(m-2);              %randi(m-2)��ȡֵΪ[1,m-2],t1��ȡֵ��ΧΪ[2,m-1]
% if ~ismember(gen(t1+1),succeedset{p*wnn-p+q,gen(t1)})  %���gen(t1+1)����succeed{gen(t1)}�У��򽻻�����λ��
%     t2=gen(t1);
%     gen(t1)=gen(t1+1);
%     gen(t1+1)=t2;
% end
% f=gen;
% end
