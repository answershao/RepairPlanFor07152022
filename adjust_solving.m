 function [iter_variables2, objective2] = adjust_solving(project_para, data_set, iter_variables, timeoff, global_schedule_plan, forward_set,performing_acts_infos)
  % timeoff,���Ա�����ڵĻ
    pro = timeoff.leave_activity_infos.pro;
    act = timeoff.leave_activity_infos.act;
 
   %�ж���������Դ�������
    if iter_variables.skill_num(data_set.skill_cate(pro, act)) >= 1
    [temp_variables, result] = update_allocate_resource(data_set, iter_variables, timeoff, time);
   else
    %���Զ�����������Դ�͵���
  %1.����ִ�еĻ��ͣ������Դ���ͷţ�����Ϊ�������Դ
   [performing_acts] = parse_performing_acts(data_set, performing_acts_infos, iter_variables, time);%�����ʱ������ִ�е����л
    
   
     [cur_conflict] = find_cur_conflict(data_set, iter_variables, cur_need_global_activity, slst);%��ǰʱ�̣�ִ�еĻ˳��
  
  
    end
  
  
  
  %��Ҫ������������ִ�еĻ������ɹ���ʱ����δ���ʱ��������ɹ�������δ��ɹ�����
 % [timeoff] = parse_timeoff(data_set, timeoff, global_schedule_plan, time);

    
 %2.�ѻ֮ǰִ�е���Դ�ͷ�
 %�ͷź���
  
    
    
    %�����ʱ�̿�ʼ��������ѭ����ֱ���������ʱ�̵ĵ��ȼƻ��������ƻ����������Ա�����ȵģ�
 [iter_variables] = repair_schedule2(project_para, data_set, cpm, forward_set,iter_variables, cycle);
    
   
    
    