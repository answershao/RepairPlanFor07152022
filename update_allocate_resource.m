function [temp_variables, conflict_act_info] = update_allocate_resource(data_set, iter_variables, timeoff, cur_conflict, time)


  if time == timeoff.leave_time
       [temp_variables, conflict_act_info] = leavetime_allocate_resource(data_set, iter_variables, timeoff,  time);
  else
      [temp_variables, conflict_act_info] = othertime_allocate_resource(data_set, iter_variables, timeoff, cur_conflict, time);
  end  

