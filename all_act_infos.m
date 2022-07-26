function [allocated_acts_information] = all_act_infos(schedule_solution)

conflict_acts_info = schedule_solution.conflict_acts_info;

ind = ~cellfun(@isempty, conflict_acts_info); %找到非空cell数组
[~, index3] = find(ind ~= 0); %index3为非空cell所在的位置
%schedule_solution.global_schedule_plan(index3);提取非空cell数组
allocated_acts_information = {}; %储存所有活动所有执行时间的信息
count = 0;
allocated_acts = conflict_acts_info(index3); %遍历所有活动信息

for time = 1:length(allocated_acts)
    each_act = allocated_acts{time}; %遍历每个时刻的活动
    
    for conflict_number = 1:length(each_act) %从第一个活动开始调取基本信息
        each_act_info = each_act{conflict_number}; %获得该活动的所有信息：{技能值，资源序号，项目活动[i, j]，结束时间 temp_variables.local_end_times，开始时间 temp_variables.local_start_times}
        %补充第6个为该活动所有的执行时间（从开始-结束）
        head = each_act_info.activity_start_time;
        tail = each_act_info.activity_end_time;
        
        for performing_time = head:tail - 1 %每个活动allocated_acts{1}{conflict_number}信息的第5项为开始时间，第四项为结束时间
            count = count +1;
            each_act_info.performing_time = performing_time;
            allocated_acts_information{count} = each_act_info;
            % allocated_acts_information (count, 1:6) = [each_act_infos(1:5), {performing_time}]; %转存每个活动的前五项信息为cell,第六项为执行时间
            
        end
        
    end
    
end

end
