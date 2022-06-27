function parent_chromosome = select_chromosome_5(POP0, pop, num_j) % %通过函数select_chromosome选出父代染色体
    pool_size = round(pop / 2); %取出近似popsize/2个父代染色体，即 为了得出数字50个染色体
    % tour_size=2;               %竞赛规模为2，为二元锦标赛选择策略
    J = [];

    for inter_select = 1:pool_size %选50次，一次选两个染色体，再取适应度值最大的一个
        j1 = randi(pop, 1, 1); %从初始种群中任选第一个整数，即任选一条染色体

        while ismember(j1, J) %判断新随机产生的染色体是否属于之前已经选过的染色体J中
            j1 = randi(pop, 1, 1); %如果属于，就对j1再随机一下，
        end

        candidate_chromosome(1, :) = POP0(j1, :); %选出j1这条染色体
        J = [J, j1]; %放入J中，作为记录
        j2 = randi(pop, 1, 1); %再选一个

        while ismember(j2, J)
            j2 = randi(pop, 1, 1);
        end

        candidate_chromosome(2, :) = POP0(j2, :);
        J = [J, j2];

        if candidate_chromosome(1, num_j + 1) <= candidate_chromosome(2, num_j + 1) %比较两条染色体的目标值大小
            parent_chromosome(inter_select, :) = candidate_chromosome(1, :); %选择值小的那个？
        else
            parent_chromosome(inter_select, :) = candidate_chromosome(2, :);
        end

    end

    % function parent_chromosome=select_chromosome(chromosome,pop,p,m,nn) %%通过函数select_chromosome选出父代染色体
    % for wwe=1:nn
    % for q=1:p
    % pool_size=round(pop/2);    %取出近似pop/2个父代染色体
    % % tour_size=2;               %竞赛规模为2，为二元锦标赛选择策略
    % J=[];
    % for i=1:pool_size
    %          j1=randi(pop,1,1);
    %          while ismember(j1,J)
    %              j1=randi(pop,1,1);
    %          end
    %         candidate_chromosome{wwe,q}(1,:)=chromosome{wwe,q}(j1,:);
    %         J=[J,j1];
    %         j2=randi(pop,1,1);
    %         while ismember(j2,J)
    %             j2=randi(pop,1,1);
    %         end
    %         candidate_chromosome{wwe,q}(2,:)=chromosome{wwe,q}(j2,:);
    %         J=[J,j2];
    %      if candidate_chromosome{wwe,q}(1,m+1)<=candidate_chromosome{wwe,q}(2,m+1)
    %          parent_chromosome{wwe,q}(i,:)=candidate_chromosome{wwe,q}(1,:);
    %      else
    %          parent_chromosome{wwe,q}(i,:)=candidate_chromosome{wwe,q}(2,:);
    %      end
    % end
    % end
    % end
