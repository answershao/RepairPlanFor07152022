% �����ʱ���
[~, index1] = ismember(time, leave_infos.leave_time); %�жϸõ��Ƿ�Ϊ��ٵ�,,index1Ϊ��ٵ��λ��,����Ѱ�Ҷ�Ӧ�����Ա�������ʱ��

if index1 ~= 0 % ����ٵ� %leave_infos.leave_time��ÿ���޸��ƻ�����֮����
    iter_variables.Lgs(:, leave_infos.leave_staff(index1)) = 0; %���µ�ǰʱ�̵ļ��ܿ�����
    iter_variables.skill_num = (sum(iter_variables.Lgs ~= 0, 2))';
    % leave_infos.leave_staff(index1)��ʱ�̵����Ա��,%ÿ��ʱ��ֻ���һ��Ա��
    %% 1.�������Ա�������ʱ���Ƿ���ִ�л
    %schedule_solution.result_saves_all�ĵ�һ��Ϊ��Դ��,time�����к����
    [~, index2] = ismember(leave_infos.leave_staff(index1), schedule_solution.result_saves_all{time, 1}); %index2Ϊ���Ա����λ��

    if index2 == 0 %˵�����Ա����ǰ��ִ�л
        % 2.�ҵ���Ա����ǰʱ��timeʱ����ִ�еĻ����,��schedule_solution.global_schedule_plan����,
        %2.1�ҵ����еĻִ��ʱ�̵���Ϣ
        [allocated_acts_information] = all_act_infos(schedule_solution);
        %2.2 �ҵ�time ʱ������ִ�еĻ
        all_time_infos = allocated_acts_information(:, 6); %������-����ʱ���г�
        performing_acts_infos = {}; %����timeʱ������ִ�еĻ��Ϣ
        count = 0;

        for time_order = 1:length(all_time_infos)

            if all_time_infos{time_order} == time %�����,��¼����time_order
                count = count + 1;
                performing_acts_infos(count, :) = allocated_acts_information(time_order, :); %time ʱ������ִ�еĻ����Ϣ
                %��¼�û�Ľ�ֹ����ʱ���Ѿ���ɵĹ���ʱ�䡢ʣ�๤��ʱ�䡢����ɵĹ�������ʣ�๤����

                %[~, index5] = ismember(leave_infos.leave_staff(index1), performing_acts_infos(count,:){2}); %��2��Ϊ��Դ���,�ж����Ա���Ƿ�����ִ��һԱ,����,�ҳ��û

                %                         if index5 ~= 0 %˵�����Ա����ִ�иû
                %                             pro = performing_acts_infos{3}(1); %��Ŀ�ţ���3��Ϊ�û
                %                             act = performing_acts_infos{3}(2); %���
                %                         else
                %                         end

            else
            end

        end

        %2.2 ���Ա��������ִ�еĻ�ļ���

        %% 3.�жϵ�ǰʱ������Ա���пɷ�������Ա��,����û�ļ��������������һ��,��һ�ˣ�

        %3.1 if����,�����,����skill_num.�������ջ��ߵ��ȼƻ���ɸ����ʱ�̵Ķ���Ŀ���ȼƻ�
        if 1 <= iter_variables.skill_num (skill_cate(pro, act)) % ���ʣ�༼�ܿ�����������ٻ��Ҫ��1��,
            [~, index3] = find(iter_variables.Lgs(skill_cate(pro, act), :) ~= 0); %�ҵ�������Щ���ܵ���Դ���,index3������Դ���
            %�ҵ�����Ա���������㼼�ܿ��õ�Ա�����غϲ���
            [avalible_staff, ~] = intersect(schedule_solution.result_saves_all{time, 1}, index3); %resource_num:���㼼�����������Ա�������

            if ~isempty(avalible_staff) %����ǿռ�,˵��������Դ���㼼������
                %����HL&LNָ�ɲ���ָ����Դ,��һ��HL&LN����,ֱ�ӵ���
                lgs_1 = iter_variables.Lgs(skill_cate(pro, act), avalible_staff); %�ҵ�������Щ���ܵ���Դ���
                schedule_solution.result_saves_all{time, 1}; %����Ա��

                for resource = 1:people
                    skill_distribution(resource) = length(find(temp_Lgs(:, resource) ~= 0)); %
                    resource_serial(resource) = resource; %��Դ���
                end

                %HL&LNָ�ɲ��ԣ�����ˮƽ��&�������ٵĲ���
                A = [lgs_1; -skill_distribution; -resource_serial];
                [B, indexb] = sortrows(A');
                B(:, 2:3) = -B(:, 2:3);
                Maxlgs = B(:, 1)';
                skill_number = Maxlgs(1, people - GlobalSourceRequest(pro, act) + 1:end); %ȷ����Դ����ֵ
                resource_number = indexb(people - GlobalSourceRequest(pro, act) + 1:end); % ȷ����Դ���
                temp_d(act, 1, pro) = ceil(GlobalSourceRequest(pro, act) * iter_variables.d(act, 1, pro) / sum(skill_number)); %����

                for k = 1:length(resource_number) %��Դ���
                    temp_resource_worktime(resource_number(k)) = temp_resource_worktime(resource_number(k)) + temp_d(act, 1, pro); %������Դ����ʱ��
                end

                temp_Lgs(:, resource_number) = 0;

                temp_skill_num = (sum(temp_Lgs ~= 0, 2))'; % 每一行不�?0的�?�算�?�? % �?能可用量更新 iter_skill_num

                temp_local_end_times(pro, act) = time + temp_d(act, 1, pro);
                result{v} = {skill_number, resource_number, [pro, act], temp_local_end_times(pro, act), temp_local_start_times(pro, act)};
            else
                temp_local_start_times(pro, act) = temp_local_start_times(pro, act) + 1;
                temp_local_end_times(pro, act) = temp_local_end_times(pro, act) + 1;
            end

            %% 4.������,�ֱ�ִ�в���һ�����Զ�
            %����һ:������һʱ�̼����ж�+���ߵ��ȼƻ�
            repair_solution1 = wait_for_sloving(leave_infos(index), schedule_solution);
            %���Զ�:���л��ͣ,��¼���л����Դ������Ϣ������ʱ�䡢ʣ�๤��ʱ�䡢����ɵĹ�������ʣ�๤����������������
            %����ͻ�����softmax����,��Դָ�ɰ���hl&ln����
            repair_solution2 = adjust_repair(leave_infos(index), schedule_solution);

            if objective1 < objective2
                repair_solution = repair_solution1;
            end

            schedule_solution = repair_solution;

        end

    else
        %% 5.���Ա����ǰ��������״̬,��ס�������ݷ���ʱ�估ʱ���¼����ܿ�����,
        %���ջ��߽��ȼƻ�ִ�м���,���Ե�ǰʱ�̵Ļ���·�����Դ

    end

else
end
