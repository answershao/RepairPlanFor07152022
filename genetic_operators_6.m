function POP1=genetic_operators_6(parent_chromosome,num_j,E,forward_set,original_local_start_times,original_local_end_times,resource_cate,R,r,d,crossoverpro,multationpro)
k=1;   %累计子代染色体个数parent_chromosome=1*65
[N,~]=size(parent_chromosome);
 U=[];
for j=1:N/2     %pop/2为父代染色体个数，对pop/2个父代染色体进行交叉，产生pop个子代染色体！
        child1_chromosome=[];
        child2_chromosome=[];
    fatherindex=randi(N,1,1);
    while ismember(fatherindex,U)   %如果fatherindex和motherindex相等，则执行循环操作；若不相等，则退出循环，保证选出的父代和母代染色体不同
          fatherindex=randi(N,1,1);
    end
    U=[U fatherindex];
    motherindex=randi(N,1,1);
    while ismember(motherindex,U)   %如果fatherindex和motherindex相等，则执行循环操作；若不相等，则退出循环，保证选出的父代和母代染色体不同
          motherindex=randi(N,1,1);
    end
    U=[U motherindex];  %交叉
     father_chromosome=parent_chromosome(fatherindex,1:num_j);  %father_chromosome=1*32
     mother_chromosome=parent_chromosome(motherindex,1:num_j);
    if rand(1)<=crossoverpro   %如果随机的一个数小于交叉概率
    child1_chromosome(1:num_j)=crossover_7(father_chromosome,mother_chromosome,num_j);%？？？
    child2_chromosome(1:num_j)=crossover_7(mother_chromosome,father_chromosome,num_j);
    child(k,1:num_j)=child1_chromosome;
    child(k+1,1:num_j)=child2_chromosome;
    else
        child(k,1:num_j)=father_chromosome; %为什么第一次 30*32，第二次30*65了
        child(k+1,1:num_j)=mother_chromosome;
    end
         k=k+2;
end
 [M,~]=size(child);
for j=1:M
if rand(1)<=multationpro %变异
    child(j,:)=multation_8(child(j,:),E,num_j);%1*32，第二次30*65了？
else
    child(j,:)=child(j,:);%同上
end
end
for q=1:M
child(q,num_j+1:num_j+1+num_j)=evaluate_objective_4_9(child(q,:),num_j,E,forward_set,original_local_start_times,original_local_end_times,resource_cate,R,r,d);%对子代种群再进行正向逆向调度
end
POP1=child;







% for wnn=1:nn
% for q=1:p
% k=1;   %累计子代染色体个数
% [N,~]=size(parent_chromosome{wnn,q});
%  U=[];
% for j=1:N/2     %pop/2为父代染色体个数，对pop/2个父代染色体进行交叉，产生pop个子代染色体！
%         child1_chromosome=[];
%         child2_chromosome=[];
%     fatherindex=randi(N,1,1);
%     while ismember(fatherindex,U)   %如果fatherindex和motherindex相等，则执行循环操作；若不相等，则退出循环，保证选出的父代和母代染色体不同
%           fatherindex=randi(N,1,1);
%     end
%     U=[U fatherindex];
%     motherindex=randi(N,1,1);
%     while ismember(motherindex,U)   %如果fatherindex和motherindex相等，则执行循环操作；若不相等，则退出循环，保证选出的父代和母代染色体不同
%           motherindex=randi(N,1,1);
%     end
%     U=[U motherindex];
%      father_chromosome=parent_chromosome{wnn,q}(fatherindex,1:m);
%      mother_chromosome=parent_chromosome{wnn,q}(motherindex,1:m);
%     if rand(1)<=crossoverpro
%     child1_chromosome(1:m)=crossover(father_chromosome,mother_chromosome,m);
%     child2_chromosome(1:m)=crossover(mother_chromosome,father_chromosome,m);
%     child(k,1:m)=child1_chromosome;
%     child(k+1,1:m)=child2_chromosome;
%     else
%         child(k,1:m)=father_chromosome;
%         child(k+1,1:m)=mother_chromosome;
%     end
%          k=k+2;
% end
% [M,~]=size(child);
% for j=1:M
% if rand(1)<=multationpro 
%     child(j,:)=multation(child(j,:),succeedset,m,q,wnn,p);
% else
%     child(j,:)=child(j,:);
% end
% end
% for j=1:M
% child(j,m+1:m+1+m)=evaluate_objective(child(j,:),succeedset,foreset,m,E1,q,l_resource_number1,l_resource_ava1,wnn,p);
% end
% POP1{wnn,q}=child;
% end
% end