function f = evaluate_objective_4_9(gen, num_j, E, forward_set, original_local_start_times, original_local_end_times, resource_cate, R, r, d)
    %function f = evaluate_objective(gen,forward_set,m,E,resource_number,resource_availability,resource_cost2,resource_lower_bound)
    %f=zeros(1,2);  %�õ�gen��Ŀ�꺯��ֵ
    f = zeros(1, num_j + 1); %��ʼ��gen
    %f=zeros(1,num_j+1+num_j);  %��ʼ��gen
    %end_time=zeros(1,num_j);  %��ʼ����Ŀ�ʼʱ�������ʱ��
    T = 500;

    for local_resource = 1:resource_cate %��Դ����,ֻ��ǰ�����Ǿֲ���Դ,����Ϊ�˱�֤��������һ���������һ����ԴΪ0���ɣ�����ܣ�
        remaining_resource(local_resource, :) = ones(1, T) * R(1, local_resource, 1); %ÿ��ʱ��β�ͬ��Դ�����ʣ����,Ϊ3��*CPM�еľ���24,24,24,.../30,30,30.../25,25,25,...
    end %��ʼ����Ŀ�����ڵ���Դ������

    %�����ѭ�����Ϊ�2��m���������ȹ�ϵԼ������ԴԼ���������°��ſ�ʼʱ�䣬��Ϊ�1Ϊ����������Ҫ��Դ
    for j = 2:num_j
        activity = gen(j); %���ŵĻΪactivity
        % mode=gen(m+j);    %���ģʽΪmode�����ᳬ��������
        predecessors = forward_set(activity, :, 1); %activity�Ľ�ǰ���predecessors_index1��ʾ��������Ϊgenֻ��һ�У����Խ���϶�����1111
        predecessors(find(predecessors == 0)) = [];
        [~, predecessors_index2] = ismember(predecessors, gen(1:j)); %ismember�жϽ�ǰ���Ԫ������gen����Ϊ1����������Ϊ0
        time1 = max(original_local_end_times(1, gen(predecessors_index2))); %��ǰ�������깤ʱ��?,predecessors_index2��ʾ��gen�����������λ��
        % time11 = time1+ad(1);
        for time2 = time1 + 1:T
            %for time2 = time11 : T                       %POP0(np,predecessors_index2)��λ���ϵĻ�����ҽ�ǰ����ʱ�������Ǹ�
            %�ж���time2��time2+d(activity,:,q)-1��ʱ�������ԴԼ���Ƿ�����
            for time3 = time2:(time2 + d(activity, :, 1) - 1)
                % for time3 = time2 : (time2+d(activity,:,1))%�Ӹû�Ŀ�ʼʱ��1������ʱ��5������ִ���ڼ��ڣ��ֲ���Դ������
                if all(remaining_resource(:, time3) >= r(activity, :, 1)') %ÿ��time3��ʾCPM���һ��ʱ�Σ�����Դ���������
                    A = 1; %����ʱ����������ľֲ���Դʣ���������ڸû������������Դ������������A = 1
                    continue
                else
                    A = 0;
                    break
                end

            end

            if A == 1 %�ж�A�Ƿ�Ϊ1������ǰʱ�̣��ɷ���û����ֲ���Դ
                original_local_start_times(1, activity) = time2 - 1;
                original_local_end_times(1, activity) = original_local_start_times(1, activity) + d(activity, :, 1);
                % original_local_end_times(1,activity)=original_local_start_times(1,activity)+d(activity,:,1);%�j�Ľ���ʱ�䣿���ǻactivity
                f(1 + activity) = original_local_start_times(1, activity);

                for time = original_local_start_times(1, activity) + 1:original_local_end_times(1, activity)
                    remaining_resource(:, time) = remaining_resource(:, time) - r(activity, :, 1)'; %���¾ֲ���Դ��ʣ�������
                end

                break
            else
                continue
            end

        end

    end

    % f(1,1:num_j) = gen;
    f(1) = f(num_j + 1); %��һ������Ŀ����ʱ��=��Ŀ����=��Ӧֵ
    %f(1) = original_local_end_times(1,num_j);
    %  f(1,num_j+1)=  original_local_end_times(1,num_j); %��Ӧֵ����,�����һ�������Ŀ�ʼʱ�䣬���������л�����ʱ������
    % f(1,2:num_j+1) =  original_local_start_times(1,:);%�������¶�Ӧ�����л�Ŀ�ʼʱ��

    % %% �±߿�ʼ�������
    % back_POP0 = ones(pop,num_j+1+num_j);
    % %���깤ʱ����������µĻ�б��Ӵ�С����,new��ʾ�µĻ�б�ĳ�������ʱ��
    [new_local_end_times(1, :), index] = sort(original_local_end_times(1, :), 'descend');
    % %��ʱ��˳���϶�Ӧ�Ļ��ע����-�µĻ�б�λ�úż����
    back_gen = index; %�µ������б���������ȼƻ�
    % %new_POP0 = ones(pop,num_j+1+num_j);
    % back_POP0(np,1:num_j) = back_gen;  %����ĳ�ʼ��ȺȾɫ�����
    %
    %
    for local_resource = 1:resource_cate %��Դ����,ֻ��ǰ�����Ǿֲ���Դ,����Ϊ�˱�֤��������һ���������һ����ԴΪ0���ɣ�����ܣ�
        remaining_resource(local_resource, :) = ones(1, T) * R(1, local_resource, 1);
    end % ��ʼ����Ŀ�����ڵľֲ��ɸ�����Դ������

    for j = 1:num_j - 1
        new_local_start_times(index(j)) = new_local_end_times(j) - d(index(j), :, 1); %���깤ʱ�併���������Ӧ�Ļ��ʼʱ��
    end

    new_local_start_times(num_j) = f(1);
    back_end_time = ones(1, num_j) * f(1);
    back_start_time = ones(1, num_j) * f(1);
    aindex = [num_j index];

    for s = 2:num_j %����back_gen�еĻ˳���б����backward����
        activity_choose = back_gen(s); %���ŵĻΪactivity_choose
        %        %% �����������
        sucdecessors = E(activity_choose, :, 1); % % %�����������
        sucdecessors(find(sucdecessors == 0)) = [];
        [~, sucdecessors_index2] = ismember(sucdecessors, back_gen(1:num_j));
        %
        time_1 = min(new_local_start_times(1, back_gen(sucdecessors_index2))); % ���������翪ʼʱ��

        for time_2 = time_1:-1:d(activity_choose, :, 1) %�ж���timetwo��timetwo-E(i,activity_choose).d��ʱ�������ԴԼ���Ƿ�����

            for time_3 = time_2:-1:(time_2 - d(activity_choose, :, 1) + 1) %???//ע��ʱ��仯

                if all(remaining_resource(:, time_3) >= r(activity_choose, :, 1)') %ÿ��time3��ʾCPM���һ��ʱ�Σ�����Դ���������
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
                    remaining_resource(:, time) = remaining_resource(:, time) - r(activity_choose, :, 1)'; %���¾ֲ��ɸ�����Դ��ʣ�������
                end

                break
            else
                continue
            end

        end

    end

    if back_start_time(1) > 0 %����

        for j = 1:num_j
            original_local_start_times(1, j) = back_start_time(j) - back_start_time(1);
            original_local_end_times(1, j) = back_end_time(j) - back_start_time(1);
            f(j + 1) = original_local_start_times(1, j);
        end

        f(1) = f(1 + num_j); %������ȵ�Ŀ�꺯��ֵ
    else
        f(1) = f(1 + num_j); % ������ȵ�Ŀ�꺯��ֵ
        f(j + 1) = original_local_start_times(1, j);
    end

    % sum_resource_cost=0;%������������
    % for k=1:resource_cate-1
    % if all(remaining_resource(k,:)>0)
    %     R(k)=R(k)-min(remaining_resource(k,:));
    % end
    % end
    % %����ѭ��������Դ������С����С��Դ������������������η�������Դ���ý�Ϊ��ֵ
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
    %     f(2)=sum_resource_cost+sum_activity_cost;   %�ڶ���Ŀ�꺯����ֵ
    % end

    % for j=1:num_j
    %     max_duration(j)=max(E(j).d);
    % end
    % sum_duration=sum(max_duration);   %������Ŀ�������  ���ؼ�·������
    % for r=1:resource_number   %��Դ����
    % remaining_resource(r,:) = ones(1,sum_duration)*resource_availability(r); %ÿ��ʱ��β�ͬ��Դ�����ʣ����
    % end   %��ʼ����Ŀ�����ڵ���Դ������
    % %�����ѭ�����Ϊ�2��m���������ȹ�ϵԼ������ԴԼ���������°��ſ�ʼʱ��
    % for j=2:m
    %     activity=gen(j)  %���ŵĻΪactivity
    %     mode=gen(m+j);    %���ģʽΪmode�����ᳬ��������
    %     predecessors=forward_set{activity};  %activity�Ľ�ǰ�
    %     [predecessors_index1,predecessors_index2]=ismember(predecessors,gen(1:m)); %ismember�жϽ�ǰ���Ԫ������gen����Ϊ1����������Ϊ0
    %     time1=max(end_time(1,predecessors_index2));  %��ǰ�������깤ʱ��???�ǹؼ�·���ϵ���
    %     for time2 = time1+1 : sum_duration
    %         %�ж���time2��time2+E(activity).d(mode)��ʱ�������ԴԼ���Ƿ����㣿����������
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
    %             end_time(j)=start_time(j)+E(activity).d(mode)-1;   %�j�Ľ���ʱ��
    %             for time=start_time(j):end_time(j)
    %                 remaining_resource(:,time)=remaining_resource(:,time)-E(activity).r(mode,:)';  %���¿ɸ�����Դ��ʣ�������
    %             end
    %             break
    %         else
    %         continue
    %         end
    %     end
    % end
    % f(1)=f(1+m);
    % [sort_endtime,act_index]=sort(end_time(1:m-1),'descend');   %��������깤ʱ�䰴�������У��깤ʱ��洢��sort_Endtime��,��Ӧ�Ļ��������act_index��
    %   for lr=1:l_resource_number1(wen)
    %     remaining_l_resource(lr,:)=ones(1,sum_duration)*l_resource_ava1(p*wen-p+q).R(lr);
    %   end  % ��ʼ����Ŀ�����ڵľֲ��ɸ�����Դ������
    %    for j=1:m-1
    %        sort_starttime(act_index(j))=sort_endtime(j)-E1(p*wen-p+q,gen(act_index(j))).d;  %���깤ʱ�併���������Ӧ�Ļ��ʼʱ��
    %    end
    %    sort_starttime(m)=f(1);
    %    back_end_time=ones(1,m)*f(1);
    %    back_start_time=ones(1,m)*f(1);
    %    aindex=[m act_index];
    %    for s=2:m %����act_index�еĻ˳���б����backward����
    %        activity_choose=gen(aindex(s));  %���ŵĻΪactivity_choose
    %        sucdecessors=succeedset{p*wen-p+q,activity_choose};
    %            [~,sucdecessors_index2]=ismember(sucdecessors,gen(1:m));
    %            timeone=min(sort_starttime(1,sucdecessors_index2));% ���������翪ʼʱ��
    %            for timetwo=timeone:-1:E1(p*wen-p+q,activity_choose).d   %�ж���timetwo��timetwo-E(i,activity_choose).d��ʱ�������ԴԼ���Ƿ�����
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
    %                        remaining_l_resource(:,time)=remaining_l_resource(:,time)-E1(p*wen-p+q,activity_choose).lr';  %���¾ֲ��ɸ�����Դ��ʣ�������
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
    %        f(1)=f(1+m); %������ȵ�Ŀ�꺯��ֵ
    %    else
    %        f(1)=f(1+m); % ǰ����ȵ�Ŀ�꺯��ֵ
    %        f(j+1)=start_time(j);
    %    end
