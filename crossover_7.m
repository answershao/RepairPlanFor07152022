function f = crossover_7(p1, p2, num_j)
    %p1��p2�ֱ��������ĸ��Ⱦɫ��orĸ��������
    gen = zeros(1, num_j);
    K = randperm(num_j);
    K1 = min(K(1, 1:2));
    K2 = max(K(1, 1:2)); %K1��K2Ϊ��б�����������
    count = 0;
    count1 = 1;
    count2 = K1 + 1;
    %�Ӵ�Ⱦɫ��Ļ�б�
    while count < num_j

        if count < K1 % ��λ��С�ڵ�һ��������λ��ʱ���̳и���Ⱦɫ��Ļ���
            count = count + 1;
            gen(1, count) = p1(1, count);
            continue %��������ʣ�µ���䣬ִ����һ��ѭ��
        end

        if (count < K2) && (count >= K1) %��λ��������������λ��֮��ʱ���̳�ĸ��Ⱦɫ�����

            for j = count1:num_j

                if ~ismember(p2(1, j), gen(1, 1:count)) %ע���˴�������֮ǰ�̳еĸ���Ⱦɫ�������δ���ֹ��Ļ���
                    count = count + 1;
                    gen(1, count) = p2(1, j);
                end

                count1 = j + 1;
                break % ����forѭ����ִ��ѭ����������
            end

            continue % �����������䣬ִ��if(count<K2)&&(count>=K1) ѭ��
        end

        if count >= K2 % ��λ�ô��ڵڶ���������λ��ʱ���̳и���Ⱦɫ��Ļ���

            for j = count2:num_j

                if ~ismember(p1(1, j), gen(1, 1:count))
                    count = count + 1;
                    gen(1, count) = p1(1, j);
                end

                count2 = j + 1;
                break
            end

            continue
        end

    end

    f = gen; %1*32
end
