function POP1=genetic_operators_6(parent_chromosome,num_j,E,forward_set,original_local_start_times,original_local_end_times,resource_cate,R,r,d,crossoverpro,multationpro)
k=1;   %�ۼ��Ӵ�Ⱦɫ�����parent_chromosome=1*65
[N,~]=size(parent_chromosome);
 U=[];
for j=1:N/2     %pop/2Ϊ����Ⱦɫ���������pop/2������Ⱦɫ����н��棬����pop���Ӵ�Ⱦɫ�壡
        child1_chromosome=[];
        child2_chromosome=[];
    fatherindex=randi(N,1,1);
    while ismember(fatherindex,U)   %���fatherindex��motherindex��ȣ���ִ��ѭ��������������ȣ����˳�ѭ������֤ѡ���ĸ�����ĸ��Ⱦɫ�岻ͬ
          fatherindex=randi(N,1,1);
    end
    U=[U fatherindex];
    motherindex=randi(N,1,1);
    while ismember(motherindex,U)   %���fatherindex��motherindex��ȣ���ִ��ѭ��������������ȣ����˳�ѭ������֤ѡ���ĸ�����ĸ��Ⱦɫ�岻ͬ
          motherindex=randi(N,1,1);
    end
    U=[U motherindex];  %����
     father_chromosome=parent_chromosome(fatherindex,1:num_j);  %father_chromosome=1*32
     mother_chromosome=parent_chromosome(motherindex,1:num_j);
    if rand(1)<=crossoverpro   %��������һ����С�ڽ������
    child1_chromosome(1:num_j)=crossover_7(father_chromosome,mother_chromosome,num_j);%������
    child2_chromosome(1:num_j)=crossover_7(mother_chromosome,father_chromosome,num_j);
    child(k,1:num_j)=child1_chromosome;
    child(k+1,1:num_j)=child2_chromosome;
    else
        child(k,1:num_j)=father_chromosome; %Ϊʲô��һ�� 30*32���ڶ���30*65��
        child(k+1,1:num_j)=mother_chromosome;
    end
         k=k+2;
end
 [M,~]=size(child);
for j=1:M
if rand(1)<=multationpro %����
    child(j,:)=multation_8(child(j,:),E,num_j);%1*32���ڶ���30*65�ˣ�
else
    child(j,:)=child(j,:);%ͬ��
end
end
for q=1:M
child(q,num_j+1:num_j+1+num_j)=evaluate_objective_4_9(child(q,:),num_j,E,forward_set,original_local_start_times,original_local_end_times,resource_cate,R,r,d);%���Ӵ���Ⱥ�ٽ��������������
end
POP1=child;







% for wnn=1:nn
% for q=1:p
% k=1;   %�ۼ��Ӵ�Ⱦɫ�����
% [N,~]=size(parent_chromosome{wnn,q});
%  U=[];
% for j=1:N/2     %pop/2Ϊ����Ⱦɫ���������pop/2������Ⱦɫ����н��棬����pop���Ӵ�Ⱦɫ�壡
%         child1_chromosome=[];
%         child2_chromosome=[];
%     fatherindex=randi(N,1,1);
%     while ismember(fatherindex,U)   %���fatherindex��motherindex��ȣ���ִ��ѭ��������������ȣ����˳�ѭ������֤ѡ���ĸ�����ĸ��Ⱦɫ�岻ͬ
%           fatherindex=randi(N,1,1);
%     end
%     U=[U fatherindex];
%     motherindex=randi(N,1,1);
%     while ismember(motherindex,U)   %���fatherindex��motherindex��ȣ���ִ��ѭ��������������ȣ����˳�ѭ������֤ѡ���ĸ�����ĸ��Ⱦɫ�岻ͬ
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