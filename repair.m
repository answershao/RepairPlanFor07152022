clear; clc;
% ���߽��ȼƻ���,cpm��uf���ռ�¼����
% ���ȷ�����ʱ��㣺���ɷֲ��� ��ֵΪǰһ�����ȼƻ�����Ŀ���ڵ�һ��,ÿ�ν����޸�ǰ,��Ҫȷ��һ����ٵ�Ա��,
%���t=��ʱ��,��ʼѭ��, �������ֵP,����0.5�ļ�¼Ϊ���ʱ��,�����ʱ��������ѡ��һ��Ա����ټ���,����ѡ��������ͼ����ʱ��
%������һ�ε��޸����ȼƻ��е����ʱ���ظ�,����һ��,���t=5ʱ�����,����ѡ��Ա��2��٣���һ�μ�ʹ���5��ȻΪ���ʱ��,Ҳ����һ���趨�õ���ٵ�Ա��Ϊ׼,��Ա��2����T=5���
%ѭ������һ�εõ�����Ŀ����ʱ��Ϊ׼

% 2. %��ٵ�,��t=0��ʼѭ��,�Ƿ���Ա�����
% 3. %����,��t1ʱ�̵�һ��Ա�����,�жϵ�ǰ����Ա���ɷ�����ִ��Ҫ��
% 4.%������,��Ϊ�������Դ
% 5. %��,����һ,�ȴ���һʱ�̼����ж�

% %������,��ǰʱ���������ڽ��еĻ��ͣ,ͨ����������е���,���·�����Դ

% 6.%��ε�����
% 7.%�����ǰ���ٵĻ�����ڽ��еĻ������һ��,softmax����,������Դͬ���߽��ȼƻ�

%�Ҹ�Ա����ٵĻ

%Ϊ�û���·�����Դ

%1.ʣ��Ա���д��ڿ���Ա�������ܡ����������㣩
%allocate_resource ������Դ
%2. ʣ��Ա���в����ڿ���Ա�������ܡ�������һ�����㣩
%����һ, wait for solving

%������, ��������е�����Դ, ������ִ�еĻ����ͣ,����Դ���ͷ�,������Դ���·���
%1.������ͬ�ȼ��ܵ���
%2.ȥ����ٵ���
%3.�ҵ����ϼ���Ҫ�����,����¼��ǰʱ��������ִ�еĻ
%4. Ϊ��ٻ���������Ļ��������Դ

% 8.%�������ӵ�ǰʱ�̿�ʼѭ��,t = t1+1,ע������뷵��ʱ��Գ���,��Դ���¿��ǣ�����+������ͷţ�;
% 9.%����ͬ���߼ƻ�,��ɺ�,�õ�Ŀ��ֵ�� ƽ����Ŀ����APD+���ʼʱ��ƫ�� +��Ա����ʱ��仯ƫ��
% 10.%�жϷ���һ�Ͷ���Ŀ��ֵ,��Сѡ��һ

% 10. %��t1��ʼѭ��,����һ���жϵ�,��Ա�����,�ظ���������

% 11.%ÿ�����ߵ㶯̬����ѡ�����ŷ���,ֱ��������л�ĵ���

% default file readed
config()

% define num_j, L,
project_para.num_j = 5; % �ܻ��
project_para.L = 2; % ��Ŀ����
project_para.resource_cate = 4; % ��Դ������
project_para.skill_count = 3; % ����������
project_para.T = 500; % ��ʱ��
project_para.cycles = 1; % 10��
project_para.people = 5;

for cycle = 1:project_para.cycles

    [data_set, leave_infos] = read_data(project_para);
    % schedule_solution: start_time, end_time, resource_assignment
    [schedule_solution, constant_variables] = baseline_schedule(project_para, data_set, cycle);
    % schedule_solution.variables_with_time = variables_with_time;%����ʱ�̵Ļִ����Ϣ
    % schedule_solution.conflict_acts_info = conflict_acts_info;%ÿ��ʱ�̻������Դ����Ϣ
    % constant_variables ���ߵ��ȼƻ������ɵĶ�����һ�����ɾ�����

    %%����Ա������ʱ���ƫ��=�޸���ÿ��Ա������ʱ��-�޸�ǰÿ������ʱ��
    % output :
    %% ����repair_schedule_plan;
    %��Ҫ����baseline���ɵ�repairʱ����Ȼ���ֲ������������Ҫ������������
    % project.para�����ֲ���
    %forward_set\cpmҲ���ֲ���
    %global_schedule_plan��baseline���ɵ�ԭʼ���ݣ�һ���洢Ҳ���ֲ��䣬��߼����õ�
    %iter_variables������Ա����ٷ����仯��
    %���У���result�з����仯���ǣ�resource_num��iter_variables��finally_total_duration��APD�� time����APD��λ��Ӧ��Ϊ�޸�Ŀ��ֵobjective
    %���ֲ������ad
    %������global_schedule_plan���ݸ�iter_variables,����iter_variables�м����������Ǽ���ֵskill_value,��Դ���resource_num,����ʱ��end_times,��ʼʱ��start_times,

    %% 1. ���ݵ�һ�����ʱ�̵���Ϣ����Դ���䣬�Ӷ��޸���������Ѱ�Һ��������ʱ��

    % data_set

    % constant_variables

    % iter_variables.R = global_schedule_plan.R; % �ֲ���Դ������
    % iter_variables.d = global_schedule_plan.d; % ���ڱ仯����
    % iter_variables.Lgs = global_schedule_plan.Lgs;
    % iter_variables.skill_num = global_schedule_plan.skill_num; %���ܿ�����
    % iter_variables.local_start_times = global_schedule_plan.local_start_times; %��ʼ�ֲ���ʼʱ��
    % iter_variables.local_end_times = global_schedule_plan.local_end_times; %��ʼ�ֲ�����ʱ��
    % iter_variables.allocated_acts_information = global_schedule_plan.allocated_acts_information;
    % iter_variables.resource_num = global_schedule_plan.resource_num;
    % iter_variables.makespan = global_schedule_plan.makespan;
    % iter_variables.APD = global_schedule_plan.APD;
    % iter_variables.resource_worktime = schedule_solution.result_saves_all{2}; % ����ÿ��Ա���Ĺ���ʱ��

    % schedule_solution
    % time��ʼ�����л��Ϣ �����������Ϣ
    % iter_schedule_solution.variables_with_time;%R,d,start,end,APD,makespan, allocated_set
    % Lgs,skill_num,resource_worktime,skill_value,allocated_resource_num,project_and_activity,start,end,unallocated_resource_num

    % iter
    iter_schedule_solution = schedule_solution;
    % iter_schedule_solution.variables_with_time
    % iter_schedule_solution.conflict_acts_info
    iter_schedule_solution.allocated_acts_information = all_act_infos(iter_schedule_solution);
    iter_schedule_solution.allocated_variables_information = all_variables_infos(iter_schedule_solution);

    iter_variables_with_time = iter_schedule_solution.variables_with_time;
    iter_conflict_acts_info = iter_schedule_solution.conflict_acts_info; % �ڴ洢��9������+performing_time
    iter_allocated_acts_information = iter_schedule_solution.allocated_acts_information; %���ݻ˳���ŵģ�����Ҫ����ִ��ʱ��
    iter_allocated_variables_information = iter_schedule_solution.allocated_variables_information; %�Ѹ���ʱ��˳���ź���

    %% repair plan
    for time = 1:project_para.T
        % 1 ������Դ
        % 1.1 ���
        % �Ƿ�Ϊ��ٵ� ���ȸ���Lgs,skill_num, ���������и���allocated_set
        [~, index_leave] = ismember(time, leave_infos.leave_time);
        %%  �����ʱ��
        if index_leave ~= 0 %˵����time�����ʱ��
            timeoff.leave_time = leave_infos.leave_time(index_leave);
            timeoff.leave_staff = leave_infos.leave_staff(index_leave);
            timeoff.leave_duration = leave_infos.leave_duration(index_leave);
            timeoff.return_time = leave_infos.return_time(index_leave);

            %% save���ʱ������ִ�еĻ��Ϣ�����Ա����ִ�еĻ��Ϣ
            [timeoff, performing_acts_infos] = find_staff_doing_activity(iter_allocated_variables_information, iter_allocated_acts_information, timeoff);
            timeoff = parse_timeoff(data_set, timeoff); %���ʱ�����Ա����ִ�еĻ��Ϣ
            performing_acts_infos = parse_performing_acts(data_set, performing_acts_infos, time);

            pro = timeoff.leave_activity_infos.pro; %Ա������뿪�� ���ʣ�๤����Ҫ����
            act = timeoff.leave_activity_infos.act;

            iter_variables.R = iter_allocated_variables_information{timeoff.leave_time}.R;
            iter_allocated_variables_information{timeoff.leave_time}.d(act, :, pro) = timeoff.leave_activity_infos.unalready_duration;
            iter_variables.d = iter_allocated_variables_information{timeoff.leave_time}.d; %Ա������뿪�� ���ʣ�๤����Ҫ����
            iter_variables.local_start_times = iter_allocated_variables_information{timeoff.leave_time}.local_start_times;
            iter_variables.local_end_times = iter_allocated_variables_information{timeoff.leave_time}.local_end_times;
            iter_variables.allocated_set = iter_allocated_variables_information{timeoff.leave_time}.allocated_set;
            iter_variables.objective = iter_allocated_variables_information{timeoff.leave_time}.objective;
            iter_variables.makespan = iter_allocated_variables_information{timeoff.leave_time}.makespan;
            iter_variables.Lgs = iter_allocated_variables_information{timeoff.leave_time}.Lgs;
            iter_variables.skill_num = iter_allocated_variables_information{timeoff.leave_time}.skill_num; %���ܿ�����
            iter_variables.resource_worktime = iter_allocated_variables_information{timeoff.leave_time}.resource_worktime;

            %% 2.1 ��������Դ�����ã����ȡ��̬����
            %             %����һ:������һʱ�̼����ж�+���ߵ��ȼƻ�
            %              [temp_schedule_solution1,objective1] = wait_for_sloving(project_para, data_set, constant_variables, iter_variables, timeoff, iter_variables_with_time(1:timeoff.leave_time-1), iter_conflict_acts_info(1:timeoff.leave_time));
            %              temp_schedule_solution = temp_schedule_solution1;%�����һ�����Ժã������˵�һ������
            %             iter_schedule_solution = temp_schedule_solution;
            %% 2.2 ���Զ�:���л��ͣ, �ӻδ��ɲ��ֿ�ʼ
            [temp_schedule_solution2, objective2] = adjust_sloving(project_para, data_set, constant_variables, iter_variables, timeoff, performing_acts_infos, iter_variables_with_time(1:timeoff.leave_time - 1), iter_conflict_acts_info(1:timeoff.leave_time));
            temp_schedule_solution = temp_schedule_solution2; %�����һ�����Ժã������˵�һ������
            iter_schedule_solution = temp_schedule_solution;

            % if objective1 < objective2
            %     temp_schedule_solution = ?;
            % else
            %     temp_schedule_solution = ?;
            % end

        end

        iter_schedule_solution.allocated_acts_information = all_act_infos(iter_schedule_solution);
        iter_schedule_solution.allocated_variables_information = all_variables_infos(iter_schedule_solution);

        iter_conflict_acts_info = iter_schedule_solution.conflict_acts_info; % �ڴ洢��9������+performing_time
        iter_allocated_acts_information = iter_schedule_solution.allocated_acts_information; %���ݻ˳���ŵģ�����Ҫ����ִ��ʱ��
        iter_allocated_variables_information = iter_schedule_solution.allocated_variables_information; %�Ѹ���ʱ��˳���ź���

    end

end

% 1.2 ����
%1.�Ƿ�Ϊ����ʱ��㣬����Lgs��skill_num,
%         [~, index_return] = ismember(time, leave_infos.return_time);
%
%         if index_return ~= 0 %˵����time��Ա������ʱ��
%             timeoff.return_time = leave_infos.return_time(index_return);
%             timeoff.return_staff = leave_infos.leave_staff(index_return); %Ա������ٺͷ��أ���Գ��֣����ĸ�Ա���߶�Ӧ�����ϵ��ĸ�Ա������һ��ʱ�䷵��
%
%             %�����ҷ���ʱ�̵Ļ��Ϣ
%             for i = 1:length(iter_allocated_acts_information)
%                 eachtime_act_info = iter_allocated_acts_information{i};
%
%                 if eachtime_act_info.performing_time == timeoff.return_time %�ҵ��˷���ʱ�̵Ļ��Ϣ
%                     %Ա����ְ
%                     eachtime_act_info.Lgs(:, timeoff.return_staff) = data_set.Lgs(1:end, timeoff.return_staff);
%                     eachtime_act_info.skill_num(1, :) = (sum(eachtime_act_info.Lgs ~= 0, 2))';
%                     iter_allocated_acts_information{i} = eachtime_act_info;
%                 end
%
%             end
%
