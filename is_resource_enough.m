function [bool] = is_resource_enough(project_para, data_set, iter_variables, performing_acts_infos, timeoff, time)
    %IS_RESOURCE_ENOUGH �˴���ʾ�йش˺�����ժҪ
    %   �˴���ʾ��ϸ˵��
    activity_infos = timeoff.activity_infos; %��ǰʱ����ٵĻ
    skill_cate = data_set.skill_cate;
    skill_num = iter_variables.skill_num;
    Lgs = data_set.Lgs;
    bool = 0;

    %�ҵ�timeʱ����ٻ���
    pro = activity_infos{3}(1); %��Ŀ�ţ���3��Ϊ�û
    act = activity_infos{3}(2); %���

    if 1 <= skill_num(skill_cate(pro, act)) % ���ʣ�༼�ܿ�����������ٻ��Ҫ��1��,����Ҫ����3
        bool = 1;
        [~, index3] = find(Lgs (skill_cate(pro, act), :) ~= 0); %�ҵ�������Щ���ܵ���Դ���,index3������Դ���,�����ռ���3��Ϊ��Դ1,2,3,5
        %�ҵ�����Ա���������㼼�ܿ��õ�Ա�����غϲ���
        [avalible_staff, ~] = intersect(schedule_solution.result_saves_all{time, 1}, index3); %avalible_staff:���㼼�����������Ա������ţ��統ǰ����1���������ռ���3������

        if ~isempty(avalible_staff) %����ǿռ�,˵��������Դ���㼼������
            [temp_variables, result] = HL_LN_allocate_staff(data_set, iter_variables, activity, time); %HL&LN ָ�ɲ���
        else
            % body
            %% 4.������,�ֱ�ִ�в���һ�����Զ�
            %����һ:������һʱ�̼����ж�+���ߵ��ȼƻ�
            repair_solution1 = wait_for_repair(leave_infos(index), schedule_solution);
            %���Զ�:���л��ͣ,��¼���л����Դ������Ϣ������ʱ�䡢ʣ�๤��ʱ�䡢����ɵĹ�������ʣ�๤����������������
            %����ͻ�����softmax����,��Դָ�ɰ���hl&ln����
            repair_solution2 = adjust_repair(leave_infos(index), performing_acts_infos);

            if objective1 < objective2
                repair_solution = repair_solution1;
            end

            schedule_solution = repair_solution;
        end

    end

end
