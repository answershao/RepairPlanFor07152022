
%project_para
project_para.num_j = 5; % �ܻ��
project_para.L = 2; % ��Ŀ����
project_para.resource_cate = 4; % ��Դ������
project_para.skill_count = 3; % ����������
project_para.T = 500; % ��ʱ��
project_para.cycles = 1; % 10��
project_para.people = 5;

%data_set
data_set.R = R;
data_set.r = r;
data_set.d = d;
data_set.E = E;
data_set.GlobalSourceRequest = GlobalSourceRequest;
data_set.skill_cate = skill_cate;
data_set.Lgs = Lgs;
data_set.original_skill_num = original_skill_num;
data_set.ad = ad;

%timeoff
timeoff.leave_time
timeoff.leave_staff
timeoff.leave_duration
timeoff.leave_activity_infos.pro = pro;
timeoff.leave_activity_infos.act = act;
timeoff.leave_activity_infos.already_duration = already_duration;
timeoff.leave_activity_infos.already_workload = already_workload;
timeoff.leave_activity_infos.unalready_duration = unalready_duration;
timeoff.leave_activity_infos.unalready_workload = unalready_workload;

 timeoff.leave_activity_infos.skill_value = performing_acts_infos{count, 1};
                    timeoff.leave_activity_infos.resource_num = performing_acts_infos{count, 2};
                    timeoff.leave_activity_infos.project_and_activity = performing_acts_infos{count, 3};
                    timeoff.leave_activity_infos.end_time_in_baseline = performing_acts_infos{count, 4};
                    timeoff.leave_activity_infos.start_time_in_baseline = performing_acts_infos{count, 5};
                    timeoff.leave_activity_infos.time = performing_acts_infos{count, 6};
                    
 % schedule_solution.result_saves_all
    %   {resource_number, iter_variables, finally_total_duration,     APD,        ad,         time};
    %   (ʣ����Դ��,       iter,            ��Ŀ����,                 ƽ����Ŀ����,   ����ʱ��,   ��ǰʱ��)
    % schedule_solution.global_schedule_plan
    %   {����ֵ, ��Դ���, ��Ŀ�[i, j], ����ʱ�� temp_variables.local_end_times, temp_variables.local_start_times, time}


%   iter_variables
iter_variables.R = global_schedule_plan.R; % �ֲ���Դ������
iter_variables.d = global_schedule_plan.d; % ���ڱ仯����
iter_variables.Lgs = global_schedule_plan.Lgs;
iter_variables.skill_num = global_schedule_plan.skill_num; %���ܿ�����
iter_variables.local_start_times = global_schedule_plan.local_start_times; %��ʼ�ֲ���ʼʱ��
iter_variables.local_end_times = global_schedule_plan.local_end_times; %��ʼ�ֲ�����ʱ��
iter_variables.allocated_acts_information = global_schedule_plan.allocated_acts_information;
% ���ʣ� iter_variables������Ԫ�ز���һֱ���֣���һ�γ�������iter_variables_all�У��������´��ݣ�
iter_variables.resource_num = global_schedule_plan.resource_num;
iter_variables.makespan = global_schedule_plan.makespan;
iter_variables.APD = global_schedule_plan.APD;
iter_variables.ad = global_schedule_plan.ad;
iter_variables.resource_worktime = schedule_solution.result_saves_all{2}; % ����ÿ��Ա���Ĺ���ʱ��
iter_variables.forward_set = global_schedule_plan.forward_set;
iter_variables.cpm = global_schedule_plan.cpm;