function POP0=initpop_2(num_j,E,forward_set,pop,original_local_start_times,original_local_end_times,resource_cate,R,r,d) %���ɳ�ʼ��Ⱥ�ĺ���initialize
%���ڻ�б����Ⱦɫ�����
%���ݻ���ȹ�ϵȷ����б�gen����Ⱦɫ��
       POP0 = ones(pop,num_j+1+num_j);%��Ŀi�ĳ�ʼ��ȺΪpopsize��num_j+1�еľ���,��Ⱥ��СΪpopsize��ÿ��Ⱦɫ����num_j�����ɵ�һ���б������ɣ���num_j+1��ΪĿ�꺯��ֵ�����ڣ�,�����num_j����num_j����Ŀ�ʼʱ��
       for np = 1:pop  %ÿ����ʼ��Ⱥ��ż�ÿ��Ⱦɫ��
            candidate=1;
            gen=zeros(1,num_j);    %��ʼ����б�������Ⱦɫ��
            for j=1:num_j
                [gen,candidate]=selectcandidate_3(j,candidate,E,forward_set,gen);%ѡ�����������ȹ�ϵ��������-Ⱦɫ�����
            end
            POP0(np,1:num_j)=gen;%�ѱ���õ�Ⱦɫ����룬������а���
            POP0(np,num_j+1:num_j+1+num_j) = evaluate_objective_4_9(gen,num_j,E,forward_set,original_local_start_times,original_local_end_times,resource_cate,R,r,d);
            %POP0(np,1:num_j+1+num_j) = evaluate_objective_4_9(gen,POP0(np,1:num_j+1+num_j),np,i,num_j,forward_set,original_local_start_times,original_local_end_times,resource_cate,R,r,d,ad);
            %���Ѿ����źõĻ���з���ֲ���Դ����������ݣ����Ǿֲ���ԴԼ����ʹ������������ȣ�
            %���Ŀ�꺯��ֵ-���ڣ���һ�л�Ŀ�ʼʱ��
        end

  
     
