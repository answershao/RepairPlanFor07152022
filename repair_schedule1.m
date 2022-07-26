function [iter_variables, objective] = repair_schedule1(project_para, data_set,original_variables, iter_variables, forward_set ,cpm,leave_time)

% project_para
T = project_para.T;
num_j = project_para.num_j;
L = project_para.L;
% data_set
GlobalSourceRequest = data_set.GlobalSourceRequest;
ad = data_set.ad;

CPM = cpm.CPM;




% Ѱ��ȫ����Դ��б�need_global_activity
need_global_activity = find_need_global(GlobalSourceRequest);
seq = 0;

% allocated_set_with_time = {};
allocated_set = iter_variables.allocated_set; % �����Ѿ�������Դ�Ļ

variables_with_time = {};
conflict_acts_info = {};


for time = leave_time+1:T
    sprintf('��ǰѭ��:%d-%d-%d', seq + 1, time)
    %5.3.1  ȷ����ǰʱ����Ҫȫ����Դ�ĳ�ͻ��б�  cur_need_global_activity
    cur_need_global_activity = find_cur_need_global_activity(original_variables{time},iter_variables, need_global_activity, time, allocated_set); % ��ǰʱ����Ҫȫ����Դ�Ļ
    slst = find_slst(project_para, data_set, cpm, iter_variables); %���ɳ�ʱ��
    %5.3.2  ����cur_need_global_activityȷ����ͻ�˳���б�
    %cur_conflict(������ĿȨ�ء�����ڡ�ȫ���������������ȹ���)
    if ~isempty(cur_need_global_activity)
        
        [cur_conflict] = find_cur_conflict(data_set, iter_variables, cur_need_global_activity, slst);
        %5.3.3  ָ����Դallocate_source
        [temp_variables, conflict_act_info] = allocate_source(data_set, iter_variables, cur_conflict, time);
        
        %% ��. �ֲ�����update_clpex_option (���ȹ�ϵԼ������ԴԼ�����оֲ����£�
        %6.1  ͨ����ǰ���������ʱ��--ȷ��δ���Ż��ʼʱ��
        temp_variables = reschedule_local_time(temp_variables, forward_set, time);
        %6.2  ȷ��δ���Ż������ԴԼ��
        temp_variables = reschedule_local_resource(project_para, data_set, temp_variables, time);
        % temp_total_duration = max(temp2_local_end_times, [], 2);  % ÿ����Ŀ����=ÿ����Ŀ�Ļ����ʱ������ֵ2��*1��
        finally_start_times = temp_variables.local_start_times - 1;
        finally_end_times = temp_variables.local_end_times - 1;
        makespan = max(finally_end_times, [], 2);
        APD = sum(makespan - ad' - CPM') / L; %1.ƽ����Ŀ����
        
        objective_act = APD + abs(finally_start_times - iter_variables.local_start_times) / L; %�޸�Ŀ��ֵf1�����й�
        objective_staff = abs(iter_variables.resource_worktime - temp_variables.resource_worktime); %�޸�Ŀ��ֵf2����Դ����ʱ��֮��ƫ���iter_variables.resource_worktime��
        objective = (1/2) * objective_act + (1/2) * objective_staff;
        
        %6.3  ����
        
        iter_variables = temp_variables;
        conflict_acts_info{time} = conflict_act_info;
    end % ������ǰʱ����Դ���估�ֲ�����
    
    %%  ��.����ȫ��Э�����߹���-�ж����õ�ȫ����Դ��һʱ���Ƿ���ͷ�
    
    for i = 1:length(conflict_acts_info)
        temp0 = conflict_acts_info{i};
        
        for j = 1:length(temp0)
            temp = temp0{j};
            
            if ~isempty(temp)
                allocated_resource_num = temp.allocated_resource_num; %resource_num
                project_and_activity = temp.project_and_activity; % ����
                released_time = temp.activity_end_time; % �ͷ�ʱ��
                
                if isempty(allocated_set)
                    allocated_set = [allocated_set, project_and_activity]; %�ҵ���Щ��Ŀ�ʼʱ��
                else
                    count = 0;
                    m = 1;
                    len = length(allocated_set);
                    
                    while m <= len
                        xx = (project_and_activity == allocated_set{1, m});
                        
                        if xx(1) == 1 && xx(2) == 1
                            break
                        else
                            count = count + 1;
                            m = m + 1;
                        end
                        
                        if count == length(allocated_set)
                            allocated_set = [allocated_set, project_and_activity];
                        end
                        
                    end
                    
                end
                
                if released_time == time + 1 % ����ͷ�ʱ����ڵ�ǰʱ��
                    iter_variables.Lgs(:, allocated_resource_num) = data_set.Lgs(1:end, allocated_resource_num);
                    iter_variables.skill_num(1, :) = (sum(iter_variables.Lgs ~= 0, 2))';
                end
                
            end
            
        end
        
    end
    
    
    
    if length(allocated_set) == length(need_global_activity) || max(max(iter_variables.local_start_times)) <= time
        break
    end
    
   % allocated_set_with_time{time} = allocated_set;
    %��¼ÿ��ʱ��ʣ�����Դ��ţ����в�ȫΪ0�����Ϊ��Դ���
    resource_number = find(sum(iter_variables.Lgs, 1) ~= 0);
    
    iter_variables.APD = APD;
    iter_variables.resource_num = resource_num;
    iter_variables.makespan = makespan;
     iter_variables.allocated_set = allocated_set;
    
    % save ��ʱ���й�ϵ�ı�������Ҫ����
    variables_with_time{time} = iter_variables;
    
    toc
    seq = seq + 1;
end

end


