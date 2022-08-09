function [data_set, leave_infos] = read_data(project_para)
    global DataSet LeaveInfos

    num_j = project_para.num_j;
    L = project_para.L;
    resource_cate = project_para.resource_cate;

    % read dataset
    R = zeros(1, resource_cate, L); %�ֲ���Դ������
    r = zeros(num_j, resource_cate, L); %�ֲ���Դ������
    d = zeros(num_j, 1, L); %�ƻ�����
    E = zeros(num_j, num_j - 2, L); %��������

    for i = 1:L
        [R1, r1, d1, E1] = process_rcp(DataSet(i, :), resource_cate, num_j); %ʹ�����������ʱ��������ȡ��Ҫ����
        R(:, :, i) = R1; % ������ά�ȱ�ʾ��Ŀ��
        r(:, :, i) = r1; % ������ά�ȱ�ʾ��Ŀ��
        d(:, :, i) = d1; % ������ά�ȱ�ʾ��Ŀ��
        E(:, :, i) = E1;
    end

    % ˽���޸�����R��r
    for i = 1:size(r, 3) % i���
        r(:, 4, i) = 0; % ʹ��r�ĵ����о�Ϊ0 �������һ�У�
        R(1, 4, i) = 0; % ʹ��R�ĵ�����Ϊ0������Ҫ������ֲ���Դ����Ϊ������Ҫ�ѵ�����ֲ���Դ��Ϊ��Ҫȫ����Դ
    end

    GlobalSourceRequest = [0, 1, 2, 3, 0; 0, 2, 1, 1, 0];
    skill_cate = [0, 1, 2, 3, 0; 0, 1, 2, 3, 0];
    %3.2 �������3��4   Lgs������Դ����
    Lgs = [1, 0.8, 0, 0.6, 0; 0.8, 0, 1, 0.8, 0.6; 0.6, 0.6, 0.8, 0, 1];
    original_skill_num = sum(Lgs ~= 0, 2)';
    ad = [0, 2];

    data_set.R = R;
    data_set.r = r;
    data_set.d = d;
    data_set.E = E;
    data_set.GlobalSourceRequest = GlobalSourceRequest;
    data_set.skill_cate = skill_cate;
    data_set.Lgs = Lgs;
    data_set.original_skill_num = original_skill_num;
    data_set.ad = ad;

    % read leave info
    for idx = 1:L
        leave_infos = LeaveInfos;
    end

    leave_infos.leave_staff = [1, 4];
    leave_infos.leave_duration = [2, 2];
    leave_infos.leave_time = [3, 6];
    leave_infos.return_time = [5, 8];
end
