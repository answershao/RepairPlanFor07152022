function [lft] = find_lft(project_para, data_set, cpm, iter_variables)

% used parameters
num_j = project_para.num_j;
L = project_para.L;

E = data_set.E;
ad = data_set.ad;

cpm_start_time = cpm.start_time;

iter_d = iter_variables.d;
iter_local_end_times = iter_variables.local_end_times;

est = zeros(L, num_j);

for i = 1:L
    est(i, :) = cpm_start_time(i, :) + ad(i) + 1;
end

lst = zeros(L, num_j); %预生成各个活动的最晚开始时间
lft = zeros(L, num_j); %预生成各个活动的最晚开始时间
slst = zeros(L, num_j); %预生成各个活动的松弛时间

for i = 1:L
    lst(i, num_j) = max(iter_local_end_times (i, :)); %最后的虚拟活动的活动工期,改
    slst(i, num_j) = 0; %虚拟活动的松弛时间为0
    
    for activity_choose = num_j - 1:-1:1
        sucdecessors = E(activity_choose, :, i); % % %补充所选活动的紧后活动集合
        sucdecessors(find(sucdecessors == 0)) = [];
        
        if length(sucdecessors) == 1
            lst(i, activity_choose) = lst(i, sucdecessors) -iter_d(activity_choose, :, i);
        else
            lst(i, activity_choose) = min(lst(i, sucdecessors)) - iter_d (activity_choose, :, i);
        end
        lft(activity_choose) = min(lst(sucdecessors));
        slst (i, activity_choose) = lst(i, activity_choose) - est(i, activity_choose);
    end
    
end

end
