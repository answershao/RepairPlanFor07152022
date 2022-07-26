function [iter_variables, objective] = wait_for_sloving(project_para, data_set,original_variables, conflict_acts_info, iter_variables, constant_variables, timeoff)

%constant_variables
cpm =  constant_variables.cpm;
forward_set = constant_variables.forward_set;

% timeoff
leave_time = timeoff.leave_time;
pro = timeoff.leave_activity_infos.pro;
act = timeoff.leave_activity_infos.act;

% iter_variables
temp_variables = iter_variables;

 %% �����Ա���뿪��������Դ�������û����ִ�У��� ����һ�� ��ǰʱ�̵�allocated_set����£��Ƴ����Ա�����ڵĻ
%     allocated_set = [allocated_set, project_and_activity]; %�ҵ���Щ��Ŀ�ʼʱ��
 for i = 1:length( iter_variables.allocated_set)
     assigned_pro_and_act =  iter_variables.allocated_set {i} ;
     assigned_pro = assigned_pro_and_act(1);
     assigned_act = assigned_pro_and_act(2);
     if assigned_pro == pro && assigned_act ==act
     iter_variables.allocated_set(i) = [];
     end
 end

%����һ����������Դ���Ƶ���һʱ��
temp_variables.local_start_times(pro, act) = temp_variables.local_start_times(pro, act) + 1;
temp_variables.local_end_times(pro, act) = temp_variables.local_end_times(pro, act) +1;

%���½����Ŀ�ʼʱ�䡢����ʱ�䣬���ƾֲ�����
%%  �ֲ�����update_clpex_option (���ȹ�ϵԼ������ԴԼ�����оֲ����£�
%6.1  ͨ����ǰ���������ʱ��--ȷ��δ���Ż��ʼʱ��
temp_variables = reschedule_local_time(temp_variables,forward_set, leave_time);
%6.2  ȷ��δ���Ż������ԴԼ��
temp_variables = reschedule_local_resource(project_para, data_set, temp_variables, leave_time);

%% ��.�ͷź���
%% ����ȫ��Э�����߹���-�ж����õ�ȫ����Դ��һʱ���Ƿ���ͷ�
% allocated_acts_information = temp_variables.allocated_acts_information;

for i = leave_time:length(conflict_acts_info)
    temp0 = conflict_acts_info{i};
    for j = 1:length(temp0)
        temp = temp0{j};
        
        if ~isempty(temp)
            allocated_resource_num = temp.allocated_resource_num; %resource_num
%             project_and_activity = temp.project_and_activity; % ����
            released_time = temp.activity_end_time; % �ͷ�ʱ��
            
            if released_time ==  leave_time  + 1 % ����ͷ�ʱ����ڵ�ǰʱ��
                iter_variables.Lgs(:, allocated_resource_num) = data_set.Lgs(1:end, allocated_resource_num);
                iter_variables.skill_num(1, :) = (sum(iter_variables.Lgs ~= 0, 2))';
            end
            
            %��¼ÿ��ʱ��ʣ�����Դ��ţ����в�ȫΪ0�����Ϊ��Դ���
            temp_variables.resource_num = find(sum(temp_variables.Lgs, 1) ~= 0);
        end
        
    end
end   
    
    % repair schedule
    %�����ʱ��+1��ʼ��������ѭ����ֱ���������ʱ�̵ĵ��ȼƻ��������ƻ����������Ա�����ȵģ�
    [iter_variables,objective] = repair_schedule1(project_para, data_set,original_variables, temp_variables, forward_set ,cpm,leave_time);
end

% if length(allocated_set) == length(need_global_activity) || max(max(iter_variables.local_start_times)) <= time
%     break
% end

%% save
% result_save = {iter_variables.skill_num, UF, CPM, original_total_duration, finally_total_duration, APD, ad, time};
% result_save = {resource_number, iter_variables, finally_total_duration, APD, ad, time};
% toc
% seq = seq + 1;
% result_saves(seq, :) = result_save;

% temp_R = iter_variables.R; % �ֲ���Դ������
% temp_d = iter_variables.d; % ���ڱ仯����
% temp_Lgs = iter_variables.Lgs;
% temp_skill_num = iter_variables.skill_num; %���ܿ�����
% temp_local_start_times = iter_variables.local_start_times; %��ʼ�ֲ���ʼʱ��
% temp_local_end_times = iter_variables.local_end_times; %��ʼ�ֲ�����ʱ��
% temp_allocated_acts_information = iter_variables.allocated_acts_information;
% temp_resource_num = iter_variables.resource_num;
% temp_makespan = iter_variables.makespan;
% temp_APD = iter_variables.APD;
% temp_ad = iter_variables.ad;
% temp_resource_worktime = zeros(1, project_para.people);

%6.3  ����
% iter_variables = temp_variables;

% temp_total_duration = max(temp2_local_end_times, [], 2);  % ÿ����Ŀ����=ÿ����Ŀ�Ļ����ʱ������ֵ2��*1��
% finally_start_times = temp_variables.local_start_times - 1;
% finally_end_times = temp_variables.local_end_times - 1;
% finally_total_duration = max(finally_end_times, [], 2);

% APD = sum(finally_total_duration - ad' - CPM') / L; %1.ƽ����Ŀ����
% objective_act = APD + abs(finally_start_times - iter_variables.local_start_times) / L; %�޸�Ŀ��ֵf1�����й�
% objective_staff = abs(iter_variables.resource_worktime - temp_variables.resource_worktime); %�޸�Ŀ��ֵf2����Դ����ʱ��֮��ƫ���iter_variables.resource_worktime��
% objective = (1/2) * objective_act + (1/2) * objective_staff;
