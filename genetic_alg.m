% function [local_start_time, local_end_time] = genetic_alg(num_j, R, r, d, E, original_local_start_times, original_local_end_times, resource_cate, ad)
function [local_start_time, local_end_time] = genetic_alg(project_para, data_set, i)
    % related to project L

    % used para
    L = project_para.L;
    num_j = project_para.num_j;
    resource_cate = project_para.resource_cate;

    % used data_set
    R = data_set.R(:, :, i);
    r = data_set.r(:, :, i);
    d = data_set.d(:, :, i);
    E = data_set.E(:, :, i);
    ad = data_set.ad(:, i);

    % new defined
    original_local_start_times = zeros(L, num_j);
    original_local_end_times = zeros(L, num_j);

    forward_set = cal_forward_set(E, length(d)); %紧前活动集合
    pop = 100; % 种群大小设为60，数值可变
    generation_number = 100; % 进化代数设为10，数值可变
    crossoverpro = 0.9; %设置交叉概率
    multationpro = 0.15; %设置变异概率

    %% 1.初始化种群
    POP0 = initpop_2(num_j, E, forward_set, pop, original_local_start_times, original_local_end_times, resource_cate, R, r, d); %初始化种群
    %开始种群的进化过程，首先根据二元锦标赛选择策略选出父代种群，然后进行遗传操作（交叉、变异），然后执行选择操作产生下一代种群
    %% 2.选择
    for iter = 1:generation_number %依据最大种群迭代次数执行循环操作
        parent_chromosome = select_chromosome_5(POP0, pop, num_j); % %通过函数select_chromosome选出父代染色体
        %% 3.交叉、变异
        %下面进行父代种群的交叉、变异等遗传操作，产生pop/2个子代染色体,并求得每个子代染色体的目标函数值
        POP1 = genetic_operators_6(parent_chromosome, num_j, E, forward_set, original_local_start_times, original_local_end_times, resource_cate, R, r, d, crossoverpro, multationpro);
        %% 4.父代子代合并，更新种群
        %下面是合并父代种群parent_chromosome和子代种群POP1,形成中间种群POP0进入下一代循环,大小为nn*p的元胞数组，L为项目数，1行元胞有popsize行，
        POP2(1:pop / 2, :) = parent_chromosome;
        POP2(pop / 2 + 1:pop, :) = POP1;
        POP0 = POP2; %POP0是合并之后的
        %% 5.计算适应度值
        average_fit(iter) = mean(POP0(:, num_j + 1)); %每次迭代中适应值的平均值，因为最后一列num_j+1是最后一个虚拟活动的开始时间即项目工期
    end

    POP0_sort = chrom_sort_10(POP0, parent_chromosome, POP1, num_j, pop);
    solution(1, 1:num_j) = POP0_sort(1, 1:num_j); %活动序号
    solution(1, num_j + 1) = POP0_sort(1, num_j + 1) + ad(1); %工期，到达时间默认为是第2个实活动的到达时间1.所以-1，第一个虚拟活动应该为0，
    solution(1, num_j + 2:num_j + num_j + 1) = POP0_sort(1, num_j + 2:num_j + num_j + 1) + ad(1); %活动开始时间

    [start_sort, start_index] = sort(solution(1, num_j + 2:num_j + 1 + num_j)); % 对各项目的开始时间进行从小到大的排序
    solution_sort(1, num_j + 2:num_j + num_j + 1) = solution(1, start_index); %m+1到m+m列代表开始时间对应的活动序号

    local_start_time(1, :) = start_sort; % solution_sort是nn*p行m+m+1列的数组，行代表的是项目号，前m列代表从小到大的开始时间

    for act_number = 1:length(start_index)
        act = start_index(act_number);
        local_end_time(1, act) = local_start_time(1, act) + d(act, :, 1);
        % solution_sort(1,num_j+1+num_j)=solution(1,num_j+1);   % 最后一列代表的是项目的初始完工时间
    end

end
