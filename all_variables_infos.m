function [allocated_variables_information]=all_variables_infos(schedule_solution)

variables_with_time = schedule_solution.variables_with_time;

allocated_variables_information = {}; %储存所有活动所有执行时间的信息

last_time_information = variables_with_time(length(variables_with_time));%最后一个活动后所有信息
last_act_endtime_info =max(max(last_time_information{1}.local_end_times));%最后一个活动的结束时间
allocated_variables_information(1:length(variables_with_time)) = variables_with_time;%如1-6均为variables_with_time

for count = length(variables_with_time)+1:last_act_endtime_info%7-终的结束时间，均为最后一刻的信息last_time_information
    allocated_variables_information(count) = last_time_information;
end







%
% for order = 1:length(variables_with_time)
%     each_act = variables_with_time{order}; %遍历每个时刻的活动
%
%     %     for conflict_number = 1:length(each_act) %从第一个活动开始调取基本信息
%     %         each_act_info = each_act{conflict_number}; %获得该活动的所有信息：{技能值，资源序号，项目活动[i, j]，结束时间 temp_variables.local_end_times，开始时间 temp_variables.local_start_times}
%  %先把4个虚拟活动表示出来，反正与顺序无关
% %       allocated_variables_information{1} = each_act;
% %        allocated_variables_information{2} = each_act;
% %         allocated_variables_information{3} = each_act;
% %          allocated_variables_information{4} = each_act;
%     for pro = 1: project_para.L
%         for act = 2: project_para.num_j-1
%             head = each_act.local_start_times(pro,act);
%             tail = each_act.local_end_times(pro,act);
%
%             for performing_time = head:tail - 1 %每个活动allocated_acts{1}{conflict_number}信息的第5项为开始时间，第四项为结束时间
%                 count = count +1;
%                 each_act.performing_time = performing_time;
%                 allocated_variables_information{count} = each_act;
% %                 variables_with_time{order} = allocated_variables_information;
%                 % allocated_acts_information (count, 1:6) = [each_act_infos(1:5), {performing_time}]; %转存每个活动的前五项信息为cell,第六项为执行时间
%
%             end
%
%         end
%     end
% %      variables_with_time{order} = allocated_variables_information;
% end
%

