%1.���߼ƻ���
%���ֲ������
project_para.num_j = 5; % �ܻ��
project_para.L = 2; % ��Ŀ����
project_para.resource_cate = 4; % ��Դ������
project_para.skill_count = 3; % ����������
project_para.T = 500; % ��ʱ��
project_para.cycles = 1; % 10��
project_para.people = 5;
data_set.r = r;
data_set.E = E;
data_set.GlobalSourceRequest = GlobalSourceRequest;
data_set.skill_cate = skill_cate;
data_set.ad = ad;
iter_variables.forward_set = global_schedule_plan.forward_set;
iter_variables.cpm = global_schedule_plan.cpm;

%һֱ�仯�ı�������������ʱ���йأ���ʱ��ά�ȣ�
data_set.R = R;
data_set.d = d;
data_set.Lgs = Lgs;
data_set.original_skill_num = original_skill_num;

% 2.�޸��ƻ��е����仯����
iter_variables.R = global_schedule_plan.R; % �ֲ���Դ������
iter_variables.d = global_schedule_plan.d; % ���ڱ仯����
iter_variables.Lgs = global_schedule_plan.Lgs;
iter_variables.skill_num = global_schedule_plan.skill_num; %���ܿ�����

iter_variables.local_start_times = global_schedule_plan.local_start_times; %���߿�ʼʱ��
iter_variables.local_end_times = global_schedule_plan.local_end_times; %���߽���ʱ��
iter_variables.allocated_acts_information = global_schedule_plan.allocated_acts_information;

iter_variables.resource_num = global_schedule_plan.resource_num;
iter_variables.makespan = global_schedule_plan.makespan;
iter_variables.APD = global_schedule_plan.APD;
iter_variables.resource_worktime = schedule_solution.result_saves_all{2}; % ����ÿ��Ա���Ĺ���ʱ��

%3.�޸��ƻ���
timeoff %�����ʱ�䣬�����Ա�����ʱ��������ʱ���йأ�timeʱ�����Ա������ִ�еĻ
performing_acts_infos %time���ʱ����������ִ�еĻ