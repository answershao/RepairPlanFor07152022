function [cur_conflict] = find_cur_conflict(data_set, iter_variables, cur_need_global_activity, slst) %当前时刻冲突活动列表

    E = data_set.E;
    GlobalSourceRequest = data_set.GlobalSourceRequest;

    iter_d = iter_variables.d;

    A = cur_need_global_activity;
    randIndex_A = randperm(length(A));
    cur_conflict = A(randIndex_A);

end
