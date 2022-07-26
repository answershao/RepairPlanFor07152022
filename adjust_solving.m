 function [iter_variables2, objective2] = adjust_solving(project_para, data_set, iter_variables, timeoff, global_schedule_plan, forward_set,performing_acts_infos)
  % timeoff,请假员工所在的活动
    pro = timeoff.leave_activity_infos.pro;
    act = timeoff.leave_activity_infos.act;
 
   %判断有闲置资源，则分配
    if iter_variables.skill_num(data_set.skill_cate(pro, act)) >= 1
    [temp_variables, result] = update_allocate_resource(data_set, iter_variables, timeoff, time);
   else
    %策略二，无闲置资源就调整
  %1.正在执行的活动暂停，且资源均释放，重新为其分配资源
   [performing_acts] = parse_performing_acts(data_set, performing_acts_infos, iter_variables, time);%该请假时刻正在执行的所有活动
    
   
     [cur_conflict] = find_cur_conflict(data_set, iter_variables, cur_need_global_activity, slst);%当前时刻，执行的活动顺序
  
  
    end
  
  
  
  %需要计算所有正在执行的活动的已完成工作时长，未完成时长，已完成工作量，未完成工作量
 % [timeoff] = parse_timeoff(data_set, timeoff, global_schedule_plan, time);

    
 %2.把活动之前执行的资源释放
 %释放函数
  
    
    
    %从请假时刻开始继续往下循环，直到完成所有时刻的调度计划（后续计划按照无请假员工调度的）
 [iter_variables] = repair_schedule2(project_para, data_set, cpm, forward_set,iter_variables, cycle);
    
   
    
    