%1.基线计划中
%保持不变的量
project_para.num_j = 5; % 总活动数
project_para.L = 2; % 项目数量
project_para.resource_cate = 4; % 资源种类数
project_para.skill_count = 3; % 技能种类数
project_para.T = 500; % 总时间
project_para.cycles = 1; % 10次
project_para.people = 5;
data_set.r = r;
data_set.E = E;
data_set.GlobalSourceRequest = GlobalSourceRequest;
data_set.skill_cate = skill_cate;
data_set.ad = ad;
iter_variables.forward_set = global_schedule_plan.forward_set;
iter_variables.cpm = global_schedule_plan.cpm;

%一直变化的变量（需设置与时间有关，加时间维度）
data_set.R = R;
data_set.d = d;
data_set.Lgs = Lgs;
data_set.original_skill_num = original_skill_num;

% 2.修复计划中迭代变化的量
iter_variables.R = global_schedule_plan.R; % 局部资源可用量
iter_variables.d = global_schedule_plan.d; % 工期变化储存
iter_variables.Lgs = global_schedule_plan.Lgs;
iter_variables.skill_num = global_schedule_plan.skill_num; %技能可用量

iter_variables.local_start_times = global_schedule_plan.local_start_times; %基线开始时间
iter_variables.local_end_times = global_schedule_plan.local_end_times; %基线结束时间
iter_variables.allocated_acts_information = global_schedule_plan.allocated_acts_information;

iter_variables.resource_num = global_schedule_plan.resource_num;
iter_variables.makespan = global_schedule_plan.makespan;
iter_variables.APD = global_schedule_plan.APD;
iter_variables.resource_worktime = schedule_solution.result_saves_all{2}; % 储存每个员工的工作时间

%3.修复计划中
timeoff %与请假时间，请假人员，请假时长，返回时间有关，time时刻请假员工正在执行的活动
performing_acts_infos %time请假时刻所有正在执行的活动