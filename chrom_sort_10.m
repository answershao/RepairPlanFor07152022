function POP0_sort = chrom_sort_10(POP0, parent_chromosome, POP1, num_j, pop)
    %ÿ����Ŀ�ֱ������Ӧֵ����
    [F, INDEX] = sort(POP0(:, num_j + 1)); %sortĬ�ϰ���С�����������

    for col = 1:length(INDEX) % % lengthΪpopsize

        if INDEX(col) <= pop / 2 % ˵����parent_chromosome�е�Ⱦɫ��
            POP0_sort(col, 1:num_j) = parent_chromosome(INDEX(col), 1:num_j);
            POP0_sort(col, num_j + 1) = F(col); %����Ⱥ����Ӧ��ֵ
            POP0_sort(col, num_j + 2:num_j + 1 + num_j) = parent_chromosome(INDEX(col), num_j + 2:num_j + 1 + num_j);
        else %˵����POP1�е�Ⱦɫ��
            POP0_sort(col, 1:num_j) = POP1(INDEX(col) - pop / 2, 1:num_j);
            POP0_sort(col, num_j + 1) = F(col);
            POP0_sort(col, num_j + 2:num_j + 1 + num_j) = POP1(INDEX(col) - pop / 2, num_j + 2:num_j + 1 + num_j);
        end

    end

    % function POP0_sort=chrom_sort(POP0,parent_chromosome,POP1,m,p,pop,nn)
    % for www=1:nn
    % for q=1:p        %ÿ����Ŀ�ֱ������Ӧֵ����
    %  [F,INDEX]=sort(POP0{www,q}(:,m+1));  %sortĬ�ϰ���С�����������
    %  for d=1:length(INDEX)       % lengthΪpop
    %      if INDEX(d)<=pop/2  % ˵����parent_chromosome�е�Ⱦɫ��
    %          POP0_sort{www,q}(d,1:m)=parent_chromosome{www,q}(INDEX(d),1:m);
    %          POP0_sort{www,q}(d,m+1)=F(d);
    %          POP0_sort{www,q}(d,m+2:m+1+m)=parent_chromosome{www,q}(INDEX(d),m+2:m+1+m);
    %      else      %˵����POP1�е�Ⱦɫ��
    %          POP0_sort{www,q}(d,1:m)=POP1{www,q}(INDEX(d)-pop/2,1:m);
    %          POP0_sort{www,q}(d,m+1)=F(d);
    %          POP0_sort{www,q}(d,m+2:m+1+m)=POP1{www,q}(INDEX(d)-pop/2,m+2:m+1+m);
    %      end
    %  end
    % end
    % end
