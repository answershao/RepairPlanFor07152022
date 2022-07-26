function [iter_variables] = prepare_global_schedule_resource(project_para, schedule_solution, leave_infos)
    %PREPARE_GLOBAL_SCHEDULE_RESOURCE �˴���ʾ�йش˺�����ժҪ
    %   �˴���ʾ��ϸ˵��

    for time = 1:project_para.T
        %�жϸõ��Ƿ�Ϊ��ٵ�,,index1Ϊ��ٵ��λ��,����Ѱ�Ҷ�Ӧ�����Ա�������ʱ��
        [~, index] = ismember(time, leave_infos.leave_time);

        if index ~= 0 % ����ٵ� %leave_infos.leave_time��ÿ���޸��ƻ�����֮����
            first_timeoff_time = leave_infos.leave_time(index);
            break
        end

    end

    iter_variables = schedule_solution.global_schedule_plan{first_timeoff_time}; %�ҵ���һ����ٵ�ʱ������Ϣ{resource_number, iter_variables, finally_total_duration, APD, ad, time};
    iter_variables.allocated_acts_information = all_act_infos(schedule_solution);

end

%global_schedule_plan.resource_num = iter_variables_all{1};
%iter_variables = iter_variables_all{2}; %�ҵ���һ����ٵ�ʱ���ĵ�����Ϣ iter_variables
%global_schedule_plan.makespan = iter_variables_all{3};
%global_schedule_plan.APD = iter_variables_all{4};
%global_schedule_plan.ad = iter_variables_all{5};

%global_schedule_plan.R = iter_variables.R;
%global_schedule_plan.d = iter_variables.d;
%global_schedule_plan.Lgs = iter_variables.Lgs;
% global_schedule_plan.skill_num = iter_variables.skill_num;
%global_schedule_plan.local_start_times = iter_variables.local_start_times;
%global_schedule_plan.local_end_times = iter_variables.local_end_times;

%global_schedule_plan.forward_set = schedule_solution.forward_set;
%global_schedule_plan.cpm = schedule_solution.cpm;
