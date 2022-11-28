function [cur_conflict] = find_cur_conflict(data_set, iter_variables, cur_need_global_activity, lst) %当前时刻冲突活动列表

    E = data_set.E;
    GlobalSourceRequest = data_set.GlobalSourceRequest;

    iter_d = iter_variables.d;

    LST = zeros(1, length(cur_need_global_activity));

    for x = 1:length(cur_need_global_activity)
        program = cur_need_global_activity{1, x}(1, 1);
        activity = cur_need_global_activity{1, x}(1, 2);
        LST(x) = lst(program, activity); %����ʼʱ��
    end

    [D, pos] = sort(-LST, 'descend'); %����ʼʱ�併������

    cur_conflict = cell(1, length(cur_need_global_activity)); %�����ĳ�ͻ�˳��

    for y = 1:length(pos)
        cur_conflict{y} = cur_need_global_activity{1, pos(y)};
    end

end
