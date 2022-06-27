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

    forward_set = cal_forward_set(E, length(d)); %��ǰ�����
    pop = 100; % ��Ⱥ��С��Ϊ60����ֵ�ɱ�
    generation_number = 100; % ����������Ϊ10����ֵ�ɱ�
    crossoverpro = 0.9; %���ý������
    multationpro = 0.15; %���ñ������

    %% 1.��ʼ����Ⱥ
    POP0 = initpop_2(num_j, E, forward_set, pop, original_local_start_times, original_local_end_times, resource_cate, R, r, d); %��ʼ����Ⱥ
    %��ʼ��Ⱥ�Ľ������̣����ȸ��ݶ�Ԫ������ѡ�����ѡ��������Ⱥ��Ȼ������Ŵ����������桢���죩��Ȼ��ִ��ѡ�����������һ����Ⱥ
    %% 2.ѡ��
    for iter = 1:generation_number %���������Ⱥ��������ִ��ѭ������
        parent_chromosome = select_chromosome_5(POP0, pop, num_j); % %ͨ������select_chromosomeѡ������Ⱦɫ��
        %% 3.���桢����
        %������и�����Ⱥ�Ľ��桢������Ŵ�����������pop/2���Ӵ�Ⱦɫ��,�����ÿ���Ӵ�Ⱦɫ���Ŀ�꺯��ֵ
        POP1 = genetic_operators_6(parent_chromosome, num_j, E, forward_set, original_local_start_times, original_local_end_times, resource_cate, R, r, d, crossoverpro, multationpro);
        %% 4.�����Ӵ��ϲ���������Ⱥ
        %�����Ǻϲ�������Ⱥparent_chromosome���Ӵ���ȺPOP1,�γ��м���ȺPOP0������һ��ѭ��,��СΪnn*p��Ԫ�����飬LΪ��Ŀ����1��Ԫ����popsize�У�
        POP2(1:pop / 2, :) = parent_chromosome;
        POP2(pop / 2 + 1:pop, :) = POP1;
        POP0 = POP2; %POP0�Ǻϲ�֮���
        %% 5.������Ӧ��ֵ
        average_fit(iter) = mean(POP0(:, num_j + 1)); %ÿ�ε�������Ӧֵ��ƽ��ֵ����Ϊ���һ��num_j+1�����һ�������Ŀ�ʼʱ�伴��Ŀ����
    end

    POP0_sort = chrom_sort_10(POP0, parent_chromosome, POP1, num_j, pop);
    solution(1, 1:num_j) = POP0_sort(1, 1:num_j); %����
    solution(1, num_j + 1) = POP0_sort(1, num_j + 1) + ad(1); %���ڣ�����ʱ��Ĭ��Ϊ�ǵ�2��ʵ��ĵ���ʱ��1.����-1����һ������Ӧ��Ϊ0��
    solution(1, num_j + 2:num_j + num_j + 1) = POP0_sort(1, num_j + 2:num_j + num_j + 1) + ad(1); %���ʼʱ��

    [start_sort, start_index] = sort(solution(1, num_j + 2:num_j + 1 + num_j)); % �Ը���Ŀ�Ŀ�ʼʱ����д�С���������
    solution_sort(1, num_j + 2:num_j + num_j + 1) = solution(1, start_index); %m+1��m+m�д���ʼʱ���Ӧ�Ļ���

    local_start_time(1, :) = start_sort; % solution_sort��nn*p��m+m+1�е����飬�д��������Ŀ�ţ�ǰm�д����С����Ŀ�ʼʱ��

    for act_number = 1:length(start_index)
        act = start_index(act_number);
        local_end_time(1, act) = local_start_time(1, act) + d(act, :, 1);
        % solution_sort(1,num_j+1+num_j)=solution(1,num_j+1);   % ���һ�д��������Ŀ�ĳ�ʼ�깤ʱ��
    end

end
