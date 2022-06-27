function POP0=initpop_2(num_j,E,forward_set,pop,original_local_start_times,original_local_end_times,resource_cate,R,r,d) %生成初始种群的函数initialize
%基于活动列表进行染色体编码
%根据活动优先关系确定活动列表gen，即染色体
       POP0 = ones(pop,num_j+1+num_j);%项目i的初始种群为popsize行num_j+1列的矩阵,种群大小为popsize，每个染色体由num_j个活动组成的一条列表链构成，第num_j+1列为目标函数值（工期）,后面的num_j代表num_j个活动的开始时间
       for np = 1:pop  %每个初始种群序号即每条染色体
            candidate=1;
            gen=zeros(1,num_j);    %初始化活动列表链，即染色体
            for j=1:num_j
                [gen,candidate]=selectcandidate_3(j,candidate,E,forward_set,gen);%选择活动，根据优先关系构成序列-染色体编码
            end
            POP0(np,1:num_j)=gen;%把编码好的染色体放入，即活动序列安排
            POP0(np,num_j+1:num_j+1+num_j) = evaluate_objective_4_9(gen,num_j,E,forward_set,original_local_start_times,original_local_end_times,resource_cate,R,r,d);
            %POP0(np,1:num_j+1+num_j) = evaluate_objective_4_9(gen,POP0(np,1:num_j+1+num_j),np,i,num_j,forward_set,original_local_start_times,original_local_end_times,resource_cate,R,r,d,ad);
            %对已经安排好的活动序列分配局部资源，解码的内容，考虑局部资源约束，使用正向逆向调度，
            %输出目标函数值-工期，及一列活动的开始时间
        end

  
     
