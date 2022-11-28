%function [local_start_time, local_end_time] = find_PR(num_j,R, r, d, E, cpm_start_time, cpm_end_time,resource_cate,ad)
function [original_local_start_time,original_local_end_time] = find_PR(num_j,R, r, d, E, cpm_end_time,resource_cate,forestset,ad)
%1.制定优先规则-活动执行顺序  (以LFT制定-期望工期）
%LST- 最晚开始时间，CPM的逆向调度的开始时间为最晚开始时间
%LFT-最晚结束时间，min{所有紧后活动中LST}
%LST(end)=EST(end）（因为终点一定在关键路径上，关键路径上的点最早开始时间等于最晚开始时间，不是关键路径上的点不一定）
%然后依次逆推，求最晚开始时间LST。

f=zeros(1,num_j+1);  %间接储存original_local_start_time
LST = zeros(1,num_j); %预生成各个活动的最晚开始时间
%LFT = zeros(1,num_j); %预生成各个活动的最晚结束时间
act_number = []; %储存活动序号

local_start_time = zeros(1,num_j);
local_end_time = zeros(1,num_j);
T = 500;


%根据CPM得到的活动列表，开始逆向调度
%  [new_local_end_times(1,:),index] = sort(cpm_end_time(1,:),'descend');
for  act = 1: num_j
    act_number(act)= act;
end

AA= [-cpm_end_time(1,:);-act_number];
[BB,indexB] = sortrows(AA');   
BB(:,1:2) = - BB(:,1:2);

back_gen  = BB(:,2)';
% new_local_end_times(1,:) = BB(:,1)';
% %把时间顺序上对应的活动标注出来-新的活动列表，位置号即活动号


LST(num_j) = max(cpm_end_time(1,:));  %最后的虚拟活动的活动工期,改
%LFT(num_j) = max(cpm_end_time(1,:));  %最后的虚拟活动的活动工期
for s=2:num_j %按照back_gen中的活动顺序列表确定LST
    activity_choose=back_gen(s);  %安排的活动为activity_choose=29
     sucdecessors=E(activity_choose,:,1);%%%补充所选活动的紧后活动集合
    sucdecessors(find(sucdecessors==0)) = [];
    if length(sucdecessors) ==1
    LST(activity_choose) = LST(sucdecessors) -d(activity_choose);
    else
        LST(activity_choose) = min(LST(sucdecessors)-d(activity_choose));
    end
   % LFT(activity_choose) = min(LST(sucdecessors));
end 

 [new_local_end_times(1,:),index] = sort(LST);%最晚开始时间升序排序

%当LFT一样时，按照min（LFT）为活动分配资源
% [new_local_end_times(1,:),index] = sort(LFT);  %LFT升序排序 index指对应的活动序号,
 %通过LFT，确定活动执行的列表index，最大完工时间最小的先执行，所以升序
 

%2.为安排好的活动分配局部资源
for local_resource=1:resource_cate   %资源种类,只有前三种是局部资源,但是为了保证后续矩阵一致所以最后一种资源为0即可，无需管！
    remaining_resource(local_resource,:) = ones(1,T)*R(1,local_resource,1);
end % 初始化项目工期内的局部可更新资源可用量

original_local_end_time = new_local_end_times(1,:);%传递作用，time1=1就赋值？也不对，会出现

%开始分配资源
for y = 2: num_j
    activity = index(y);
    predecessors=forestset(activity,:,1);  %activity的紧前活动，predecessors_index1表示行数，因为gen只有一行，所以结果肯定都是1111
    predecessors(find(predecessors==0)) = [];
    %[~,predecessors_index2]=ismember(predecessors,index(1:y)); %ismember判断紧前活动中元素属于gen，就为1，不属于则为0
    [~,predecessors_index2]=ismember(predecessors,index); %ismember判断紧前活动中元素属于gen，就为1，不属于则为0
    time1=max(original_local_end_time(1,index(predecessors_index2)));  %紧前活动的最大完工时间?

 for time2 = time1+1 : T
        %for time2 = time11 : T                       %POP0(np,predecessors_index2)该位置上的活动数，找紧前活动完成时间最大的那个
        %判断在time2到time2+d(activity,:,q)-1的时间段内资源约束是否满足
        for time3 = time2 : (time2+d(activity,:,1)-1)
            % for time3 = time2 : (time2+d(activity,:,1))%从该活动的开始时间1到结束时间5的整个执行期间内，局部资源均满足
            if all(remaining_resource(:,time3)>=r(activity,:,1)')%每个time3表示CPM里的一个时段，即资源矩阵的列数
                A=1;   %若该时刻所有种类的局部资源剩余量均大于该活动对所有种类资源的需求量，则A = 1
                continue
            else
                A=0;
                break
            end
        end
        if A==1      %判断A是否为1，即当前时刻，可否给该活动分配局部资源
            original_local_start_time(1,activity)=time2-1;
            original_local_end_time(1,activity) = original_local_start_time(1,activity)+d(activity,:,1);
            % original_local_end_times(1,activity)=original_local_start_times(1,activity)+d(activity,:,1);%活动j的结束时间？还是活动activity
            %f(1+activity) = original_local_start_time(1,activity);
            for time=original_local_start_time(1,activity)+1:original_local_end_time(1,activity)
                remaining_resource(:,time)=remaining_resource(:,time)-r(activity,:,1)';  %更新局部资源的剩余可用量
            end
            break
        else
            continue
        end
 end
     %new_local_end_times = original_local_end_time;
end

original_local_start_time = original_local_start_time +ad;
 original_local_end_time = original_local_end_time + ad;
% 

% 
% 
% 
% %  local_start_time = back_start_time;
% %  local_end_time = back_end_time;
% 
% %排列组合的形式？LST逆推法？
% 
% %LFT(1,j) = min{LST(E(1,j))};
% 
% 
% %先求单个项目的开始结束，最后再加到达时间ad
% 
