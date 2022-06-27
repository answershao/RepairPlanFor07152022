function f = evaluate_objective_4_9(gen, num_j, E, forward_set, original_local_start_times, original_local_end_times, resource_cate, R, r, d)
    %function f = evaluate_objective(gen,forward_set,m,E,resource_number,resource_availability,resource_cost2,resource_lower_bound)
    %f=zeros(1,2);  %得到gen的目标函数值
    f = zeros(1, num_j + 1); %初始化gen
    %f=zeros(1,num_j+1+num_j);  %初始化gen
    %end_time=zeros(1,num_j);  %初始化活动的开始时间与结束时间
    T = 500;

    for local_resource = 1:resource_cate %资源种类,只有前三种是局部资源,但是为了保证后续矩阵一致所以最后一种资源为0即可，无需管！
        remaining_resource(local_resource, :) = ones(1, T) * R(1, local_resource, 1); %每个时间段不同资源种类的剩余量,为3行*CPM列的矩阵24,24,24,.../30,30,30.../25,25,25,...
    end %初始化项目工期内的资源可用量

    %下面的循环语句为活动2到m在满足优先关系约束和资源约束的条件下安排开始时间，因为活动1为虚拟活动，不需要资源
    for j = 2:num_j
        activity = gen(j); %安排的活动为activity
        % mode=gen(m+j);    %活动的模式为mode？不会超出数组吗？
        predecessors = forward_set(activity, :, 1); %activity的紧前活动，predecessors_index1表示行数，因为gen只有一行，所以结果肯定都是1111
        predecessors(find(predecessors == 0)) = [];
        [~, predecessors_index2] = ismember(predecessors, gen(1:j)); %ismember判断紧前活动中元素属于gen，就为1，不属于则为0
        time1 = max(original_local_end_times(1, gen(predecessors_index2))); %紧前活动的最大完工时间?,predecessors_index2表示在gen里的列数，即位置
        % time11 = time1+ad(1);
        for time2 = time1 + 1:T
            %for time2 = time11 : T                       %POP0(np,predecessors_index2)该位置上的活动数，找紧前活动完成时间最大的那个
            %判断在time2到time2+d(activity,:,q)-1的时间段内资源约束是否满足
            for time3 = time2:(time2 + d(activity, :, 1) - 1)
                % for time3 = time2 : (time2+d(activity,:,1))%从该活动的开始时间1到结束时间5的整个执行期间内，局部资源均满足
                if all(remaining_resource(:, time3) >= r(activity, :, 1)') %每个time3表示CPM里的一个时段，即资源矩阵的列数
                    A = 1; %若该时刻所有种类的局部资源剩余量均大于该活动对所有种类资源的需求量，则A = 1
                    continue
                else
                    A = 0;
                    break
                end

            end

            if A == 1 %判断A是否为1，即当前时刻，可否给该活动分配局部资源
                original_local_start_times(1, activity) = time2 - 1;
                original_local_end_times(1, activity) = original_local_start_times(1, activity) + d(activity, :, 1);
                % original_local_end_times(1,activity)=original_local_start_times(1,activity)+d(activity,:,1);%活动j的结束时间？还是活动activity
                f(1 + activity) = original_local_start_times(1, activity);

                for time = original_local_start_times(1, activity) + 1:original_local_end_times(1, activity)
                    remaining_resource(:, time) = remaining_resource(:, time) - r(activity, :, 1)'; %更新局部资源的剩余可用量
                end

                break
            else
                continue
            end

        end

    end

    % f(1,1:num_j) = gen;
    f(1) = f(num_j + 1); %第一个是项目结束时间=项目工期=适应值
    %f(1) = original_local_end_times(1,num_j);
    %  f(1,num_j+1)=  original_local_end_times(1,num_j); %适应值工期,即最后一个虚拟活动的开始时间，或者是所有活动里结束时间最大的
    % f(1,2:num_j+1) =  original_local_start_times(1,:);%该形势下对应的所有活动的开始时间

    % %% 下边开始逆向调度
    % back_POP0 = ones(pop,num_j+1+num_j);
    % %以完工时间的逆序做新的活动列表，从大到小排列,new表示新的活动列表的初步结束时间
    [new_local_end_times(1, :), index] = sort(original_local_end_times(1, :), 'descend');
    % %把时间顺序上对应的活动标注出来-新的活动列表，位置号即活动号
    back_gen = index; %新的任务列表，即逆向进度计划
    % %new_POP0 = ones(pop,num_j+1+num_j);
    % back_POP0(np,1:num_j) = back_gen;  %逆向的初始种群染色体放入
    %
    %
    for local_resource = 1:resource_cate %资源种类,只有前三种是局部资源,但是为了保证后续矩阵一致所以最后一种资源为0即可，无需管！
        remaining_resource(local_resource, :) = ones(1, T) * R(1, local_resource, 1);
    end % 初始化项目工期内的局部可更新资源可用量

    for j = 1:num_j - 1
        new_local_start_times(index(j)) = new_local_end_times(j) - d(index(j), :, 1); %与完工时间降序排列相对应的活动开始时间
    end

    new_local_start_times(num_j) = f(1);
    back_end_time = ones(1, num_j) * f(1);
    back_start_time = ones(1, num_j) * f(1);
    aindex = [num_j index];

    for s = 2:num_j %按照back_gen中的活动顺序列表进行backward调度
        activity_choose = back_gen(s); %安排的活动为activity_choose
        %        %% 补充紧后活动集合
        sucdecessors = E(activity_choose, :, 1); % % %补充紧后活动集合
        sucdecessors(find(sucdecessors == 0)) = [];
        [~, sucdecessors_index2] = ismember(sucdecessors, back_gen(1:num_j));
        %
        time_1 = min(new_local_start_times(1, back_gen(sucdecessors_index2))); % 紧后活动的最早开始时间

        for time_2 = time_1:-1:d(activity_choose, :, 1) %判断在timetwo到timetwo-E(i,activity_choose).d的时间段内资源约束是否满足

            for time_3 = time_2:-1:(time_2 - d(activity_choose, :, 1) + 1) %???//注意时间变化

                if all(remaining_resource(:, time_3) >= r(activity_choose, :, 1)') %每个time3表示CPM里的一个时段，即资源矩阵的列数
                    A = 1;
                    continue
                else
                    A = 0;
                    break
                end

            end

            if A == 1
                back_end_time(back_gen(s)) = time_2;
                back_start_time(back_gen(s)) = back_end_time(back_gen(s)) - d(activity_choose, :, 1);

                for time = back_start_time(back_gen(s)) + 1:back_end_time(back_gen(s))
                    remaining_resource(:, time) = remaining_resource(:, time) - r(activity_choose, :, 1)'; %更新局部可更新资源的剩余可用量
                end

                break
            else
                continue
            end

        end

    end

    if back_start_time(1) > 0 %虚拟活动

        for j = 1:num_j
            original_local_start_times(1, j) = back_start_time(j) - back_start_time(1);
            original_local_end_times(1, j) = back_end_time(j) - back_start_time(1);
            f(j + 1) = original_local_start_times(1, j);
        end

        f(1) = f(1 + num_j); %后向调度的目标函数值
    else
        f(1) = f(1 + num_j); % 后向调度的目标函数值
        f(j + 1) = original_local_start_times(1, j);
    end

    % sum_resource_cost=0;%？？？？？？
    % for k=1:resource_cate-1
    % if all(remaining_resource(k,:)>0)
    %     R(k)=R(k)-min(remaining_resource(k,:));
    % end
    % end
    % %以下循环避免资源可用量小于最小资源可用量，如果此种情形发生，资源费用将为负值
    % for k=1:resource_cate-1
    % if R(k)<min(remaining_resource(k,:))
    %   R(k)=min(remaining_resource(k,:));%???
    % end
    % end
    % j=1:resource_cate-1;
    % sum_resource_cost=sum(resource_cost2(j).*(R(j)-min(remaining_resource(k,:)).*f(1));%???
    % for j=1:num_j
    %     activity=gen(j);
    %     %mode=gen(num_j+j);%???
    %     activity_cost(j)=E(activity).c(mode);%???
    % end
    %     sum_activity_cost=sum(activity_cost);   %???
    %     f(2)=sum_resource_cost+sum_activity_cost;   %第二个目标函数的值
    % end

    % for j=1:num_j
    %     max_duration(j)=max(E(j).d);
    % end
    % sum_duration=sum(max_duration);   %计算项目的最长工期  ，关键路径工期
    % for r=1:resource_number   %资源种类
    % remaining_resource(r,:) = ones(1,sum_duration)*resource_availability(r); %每个时间段不同资源种类的剩余量
    % end   %初始化项目工期内的资源可用量
    % %下面的循环语句为活动2到m在满足优先关系约束和资源约束的条件下安排开始时间
    % for j=2:m
    %     activity=gen(j)  %安排的活动为activity
    %     mode=gen(m+j);    %活动的模式为mode？不会超出数组吗？
    %     predecessors=forward_set{activity};  %activity的紧前活动
    %     [predecessors_index1,predecessors_index2]=ismember(predecessors,gen(1:m)); %ismember判断紧前活动中元素属于gen，就为1，不属于则为0
    %     time1=max(end_time(1,predecessors_index2));  %紧前活动的最大完工时间???是关键路径上的吗？
    %     for time2 = time1+1 : sum_duration
    %         %判断在time2到time2+E(activity).d(mode)的时间段内资源约束是否满足？？？？？？
    %         for time3 = time2 : (time2+E(activity).d(mode)-1)
    %         if all(remaining_resource(:,time3)>=E(activity).r(mode,:)')
    %             A=1;
    %             continue
    %         else
    %             A=0;
    %             break
    %         end
    %         end
    %         if A==1
    %             start_time(j)=time2;
    %             end_time(j)=start_time(j)+E(activity).d(mode)-1;   %活动j的结束时间
    %             for time=start_time(j):end_time(j)
    %                 remaining_resource(:,time)=remaining_resource(:,time)-E(activity).r(mode,:)';  %更新可更新资源的剩余可用量
    %             end
    %             break
    %         else
    %         continue
    %         end
    %     end
    % end
    % f(1)=f(1+m);
    % [sort_endtime,act_index]=sort(end_time(1:m-1),'descend');   %将各活动的完工时间按降序排列，完工时间存储在sort_Endtime中,相应的活动索引存在act_index中
    %   for lr=1:l_resource_number1(wen)
    %     remaining_l_resource(lr,:)=ones(1,sum_duration)*l_resource_ava1(p*wen-p+q).R(lr);
    %   end  % 初始化项目工期内的局部可更新资源可用量
    %    for j=1:m-1
    %        sort_starttime(act_index(j))=sort_endtime(j)-E1(p*wen-p+q,gen(act_index(j))).d;  %与完工时间降序排列相对应的活动开始时间
    %    end
    %    sort_starttime(m)=f(1);
    %    back_end_time=ones(1,m)*f(1);
    %    back_start_time=ones(1,m)*f(1);
    %    aindex=[m act_index];
    %    for s=2:m %按照act_index中的活动顺序列表进行backward调度
    %        activity_choose=gen(aindex(s));  %安排的活动为activity_choose
    %        sucdecessors=succeedset{p*wen-p+q,activity_choose};
    %            [~,sucdecessors_index2]=ismember(sucdecessors,gen(1:m));
    %            timeone=min(sort_starttime(1,sucdecessors_index2));% 紧后活动的最早开始时间
    %            for timetwo=timeone:-1:E1(p*wen-p+q,activity_choose).d   %判断在timetwo到timetwo-E(i,activity_choose).d的时间段内资源约束是否满足
    %                for timethree=timetwo:-1:(timetwo-E1(p*wen-p+q,activity_choose).d+1)
    %                    if all(remaining_l_resource(:,timethree)>=E1(p*wen-p+q,activity_choose).lr')
    %                        A=1;
    %                        continue
    %                    else
    %                        A=0;
    %                        break
    %                    end
    %                end
    %                if A==1
    %                    back_end_time(aindex(s))=timetwo;
    %                    back_start_time(aindex(s))=back_end_time(aindex(s))-E1(p*wen-p+q,activity_choose).d;
    %                    for time=back_start_time(aindex(s))+1:back_end_time(aindex(s))
    %                        remaining_l_resource(:,time)=remaining_l_resource(:,time)-E1(p*wen-p+q,activity_choose).lr';  %更新局部可更新资源的剩余可用量
    %                    end
    %                    break
    %                else
    %                    continue
    %                end
    %            end
    %    end
    %    if back_end_time(1)>0
    %        for j=1:m
    %        start_time(j)=back_start_time(j)-back_end_time(1);
    %        end_time(j)=back_end_time(j)-back_end_time(1);
    %        f(j+1)=start_time(j);
    %        end
    %        f(1)=f(1+m); %后向调度的目标函数值
    %    else
    %        f(1)=f(1+m); % 前向调度的目标函数值
    %        f(j+1)=start_time(j);
    %    end
