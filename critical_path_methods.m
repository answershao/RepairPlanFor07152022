function [cpm] = critical_path_methods(project_para, data_set)
    %mΪ���
    %LΪ��Ŀ��
    %RΪ�ֲ���Դ��������
    %������succeedset
    %��ǰ���foreset

    % used
    d = data_set.d;
    E = data_set.E;
    L = project_para.L;
    num_j = project_para.num_j;

    % new defined
    CPM = zeros(1, L);
    start_time = zeros(L, num_j);
    end_time = zeros(L, num_j);

    parfor i = 1:L
        sprintf('�ؼ�·�����ڽ���:%d / %d', i, L)
        [CPM(i), start_time(i, :), end_time(i, :)] = critical_path_method(d(:, :, i), E(:, :, i));
    end

    cpm.CPM = CPM;
    cpm.start_time = start_time;
    cpm.end_time = end_time;
end
