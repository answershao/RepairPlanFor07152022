function [iter_variables] = repair_schedule2(project_para, data_set, cpm, forward_set,iter_variables, cycle)



allocated_set = {}; %�����Ѿ�������Դ�Ļ


% Ѱ��ȫ����Դ��б�need_global_activity
need_global_activity = find_need_global(GlobalSourceRequest);
seq = 0;

for time =  timeoff.leave_time:T
    sprintf('��ǰѭ��:%d-%d-%d', cycle, seq + 1, time)
    %5.3.1  ȷ����ǰʱ����Ҫȫ����Դ�ĳ�ͻ��б�  cur_need_global_activity
    cur_need_global_activity = find_cur_need_global_activity(iter_variables, need_global_activity, time, allocated_set); % ��ǰʱ����Ҫȫ����Դ�Ļ
    slst = find_slst(project_para, data_set, cpm, iter_variables); %���ɳ�ʱ��
    %5.3.2  ����cur_need_global_activityȷ����ͻ�˳���б�
    %cur_conflict(������ĿȨ�ء�����ڡ�ȫ���������������ȹ���)
    if ~isempty(cur_need_global_activity)
        
        [cur_conflict] = find_cur_conflict(data_set, iter_variables, cur_need_global_activity, slst);
        %5.3.3  ָ����Դallocate_source
        [temp_variables, result] = update_allocate_resource(data_set, iter_variables, timeoff, time);
        %% ��. �ֲ�����update_clpex_option (���ȹ�ϵԼ������ԴԼ�����оֲ����£�
        %6.1  ͨ����ǰ���������ʱ��--ȷ��δ���Ż��ʼʱ��
        temp_variables = reschedule_local_time(temp_variables, forward_set,time);
        %6.2  ȷ��δ���Ż������ԴԼ��
        temp_variables = reschedule_local_resource(project_para, data_set, temp_variables, time);
        % temp_total_duration = max(temp2_local_end_times, [], 2);  % ÿ����Ŀ����=ÿ����Ŀ�Ļ����ʱ������ֵ2��*1��
        finally_start_times = temp_variables.local_start_times - 1;
        finally_end_times = temp_variables.local_end_times - 1;
        finally_total_duration = max(finally_end_times, [], 2);
        
        APD = sum(finally_total_duration - ad' - CPM') / L; %1.ƽ����Ŀ����
        objective_act = APD + abs(finally_start_times - iter_variables.local_start_times) / L; %�޸�Ŀ��ֵf1�����й�
        objective_staff =  abs(iter_variables.resource_worktime-temp_variables.resource_worktime) ; %�޸�Ŀ��ֵf2����Դ����ʱ��֮��ƫ���iter_variables.resource_worktime��
        objective = (1/2) * objective_act + (1/2) * objective_staff;
        
        %6.3  ����
        iter_variables = temp_variables;
        
        iter_variables{time} = result;
        result = {};
    end % ������ǰʱ����Դ���估�ֲ�����
    
    %%  ��.����ȫ��Э�����߹���-�ж����õ�ȫ����Դ��һʱ���Ƿ���ͷ�
    for i = 1:length(global_schedule_plan)
        temp0 = global_schedule_plan{i};
        
        for j = 1:length(temp0)
            temp = temp0(j);
            
            if ~isempty(temp{1})
                temp1 = temp{1};
                temp12 = temp1(2); %Resource_number
                temp13 = temp1(3); % ����
                temp14 = temp1(4); % �ͷ�ʱ��
                
                if isempty(allocated_set)
                    allocated_set = [allocated_set, temp13{1}]; %�ҵ���Щ��Ŀ�ʼʱ��
                else
                    count = 0;
                    m = 1;
                    len = length(allocated_set);
                    
                    while m <= len
                        xx = (temp13{1} == allocated_set{1, m});
                        
                        if xx(1) == 1 && xx(2) == 1
                            break
                        else
                            count = count + 1;
                            m = m + 1;
                        end
                        
                        if count == length(allocated_set)
                            allocated_set = [allocated_set, temp13{1}];
                        end
                        
                    end
                    
                end
                
                if temp14{1} == time + 1 % ����ͷ�ʱ����ڵ�ǰʱ��
                    iter_variables.Lgs(:, temp12{1}) = data_set.Lgs(1:end, temp12{1});
                    iter_variables.skill_num(1, :) = (sum(iter_variables.Lgs ~= 0, 2))';
                end
                
            end
            
        end
        
    end
    
    if length(allocated_set) == length(need_global_activity) || max(max(iter_variables.local_start_times)) <= time
        break
    end
    
    %��¼ÿ��ʱ��ʣ�����Դ��ţ����в�ȫΪ0�����Ϊ��Դ���
    resource_number = find(sum(iter_variables.Lgs, 1) ~= 0);
    %% save
    % result_save = {iter_variables.skill_num, UF, CPM, original_total_duration, finally_total_duration, APD, ad, time};
    result_save = {resource_number, iter_variables, finally_total_duration, APD, ad, time};
    toc
    seq = seq + 1;
    result_saves(seq, :) = result_save;
    
end

result_saves_all(1:seq, :, cycle) = result_saves;