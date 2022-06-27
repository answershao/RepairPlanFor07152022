function f = crossover_7(p1, p2, num_j)
    %p1、p2分别代表父代、母代染色体or母代、父代
    gen = zeros(1, num_j);
    K = randperm(num_j);
    K1 = min(K(1, 1:2));
    K2 = max(K(1, 1:2)); %K1和K2为活动列表的两个交叉点
    count = 0;
    count1 = 1;
    count2 = K1 + 1;
    %子代染色体的活动列表
    while count < num_j

        if count < K1 % 当位置小于第一个交叉点的位置时，继承父代染色体的基因
            count = count + 1;
            gen(1, count) = p1(1, count);
            continue %跳过下面剩下的语句，执行下一次循环
        end

        if (count < K2) && (count >= K1) %当位置在两个交叉点的位置之间时，继承母代染色体基因，

            for j = count1:num_j

                if ~ismember(p2(1, j), gen(1, 1:count)) %注，此处基因是之前继承的父代染色体基因中未出现过的基因
                    count = count + 1;
                    gen(1, count) = p2(1, j);
                end

                count1 = j + 1;
                break % 跳出for循环，执行循环下面的语句
            end

            continue % 跳过下面的语句，执行if(count<K2)&&(count>=K1) 循环
        end

        if count >= K2 % 当位置大于第二个交叉点的位置时，继承父代染色体的基因

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
