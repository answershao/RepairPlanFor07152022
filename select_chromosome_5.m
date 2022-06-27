function parent_chromosome = select_chromosome_5(POP0, pop, num_j) % %ͨ������select_chromosomeѡ������Ⱦɫ��
    pool_size = round(pop / 2); %ȡ������popsize/2������Ⱦɫ�壬�� Ϊ�˵ó�����50��Ⱦɫ��
    % tour_size=2;               %������ģΪ2��Ϊ��Ԫ������ѡ�����
    J = [];

    for inter_select = 1:pool_size %ѡ50�Σ�һ��ѡ����Ⱦɫ�壬��ȡ��Ӧ��ֵ����һ��
        j1 = randi(pop, 1, 1); %�ӳ�ʼ��Ⱥ����ѡ��һ������������ѡһ��Ⱦɫ��

        while ismember(j1, J) %�ж������������Ⱦɫ���Ƿ�����֮ǰ�Ѿ�ѡ����Ⱦɫ��J��
            j1 = randi(pop, 1, 1); %������ڣ��Ͷ�j1�����һ�£�
        end

        candidate_chromosome(1, :) = POP0(j1, :); %ѡ��j1����Ⱦɫ��
        J = [J, j1]; %����J�У���Ϊ��¼
        j2 = randi(pop, 1, 1); %��ѡһ��

        while ismember(j2, J)
            j2 = randi(pop, 1, 1);
        end

        candidate_chromosome(2, :) = POP0(j2, :);
        J = [J, j2];

        if candidate_chromosome(1, num_j + 1) <= candidate_chromosome(2, num_j + 1) %�Ƚ�����Ⱦɫ���Ŀ��ֵ��С
            parent_chromosome(inter_select, :) = candidate_chromosome(1, :); %ѡ��ֵС���Ǹ���
        else
            parent_chromosome(inter_select, :) = candidate_chromosome(2, :);
        end

    end

    % function parent_chromosome=select_chromosome(chromosome,pop,p,m,nn) %%ͨ������select_chromosomeѡ������Ⱦɫ��
    % for wwe=1:nn
    % for q=1:p
    % pool_size=round(pop/2);    %ȡ������pop/2������Ⱦɫ��
    % % tour_size=2;               %������ģΪ2��Ϊ��Ԫ������ѡ�����
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
