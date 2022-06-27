function POP0_sort = chrom_sort_10(POP0, parent_chromosome, POP1, num_j, pop)
    %每个项目分别进行适应值排序
    [F, INDEX] = sort(POP0(:, num_j + 1)); %sort默认按从小到大进行排序

    for col = 1:length(INDEX) % % length为popsize

        if INDEX(col) <= pop / 2 % 说明是parent_chromosome中的染色体
            POP0_sort(col, 1:num_j) = parent_chromosome(INDEX(col), 1:num_j);
            POP0_sort(col, num_j + 1) = F(col); %该种群的适应度值
            POP0_sort(col, num_j + 2:num_j + 1 + num_j) = parent_chromosome(INDEX(col), num_j + 2:num_j + 1 + num_j);
        else %说明是POP1中的染色体
            POP0_sort(col, 1:num_j) = POP1(INDEX(col) - pop / 2, 1:num_j);
            POP0_sort(col, num_j + 1) = F(col);
            POP0_sort(col, num_j + 2:num_j + 1 + num_j) = POP1(INDEX(col) - pop / 2, num_j + 2:num_j + 1 + num_j);
        end

    end

    % function POP0_sort=chrom_sort(POP0,parent_chromosome,POP1,m,p,pop,nn)
    % for www=1:nn
    % for q=1:p        %每个项目分别进行适应值排序
    %  [F,INDEX]=sort(POP0{www,q}(:,m+1));  %sort默认按从小到大进行排序
    %  for d=1:length(INDEX)       % length为pop
    %      if INDEX(d)<=pop/2  % 说明是parent_chromosome中的染色体
    %          POP0_sort{www,q}(d,1:m)=parent_chromosome{www,q}(INDEX(d),1:m);
    %          POP0_sort{www,q}(d,m+1)=F(d);
    %          POP0_sort{www,q}(d,m+2:m+1+m)=parent_chromosome{www,q}(INDEX(d),m+2:m+1+m);
    %      else      %说明是POP1中的染色体
    %          POP0_sort{www,q}(d,1:m)=POP1{www,q}(INDEX(d)-pop/2,1:m);
    %          POP0_sort{www,q}(d,m+1)=F(d);
    %          POP0_sort{www,q}(d,m+2:m+1+m)=POP1{www,q}(INDEX(d)-pop/2,m+2:m+1+m);
    %      end
    %  end
    % end
    % end
