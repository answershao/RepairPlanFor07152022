function [data_set] = read_data_large(project_para, FileName)

    num_j = project_para.num_j;
    L = project_para.L;
    resource_cate = project_para.resource_cate;
    skill_count = project_para.skill_count;
    people = project_para.people;

    %1.2 ������������
    %1.3 �����ļ���
    %     for file = 1:5
    %FolderPath = strcat('D:\\����Сǿ\\SCI\\���⼯-mpsplip\\j30\\MP30_2\\mp_j30_a2_nr5');
    %10���2��5��10��20��Ŀ\\',num2str(L),'-10\\',num2str(L),'-', num2str(OS), '-',num2str(RF), '-',num2str(RS));
    %1.4 ��ȡ����Ŀ����
    R = zeros(1, resource_cate, L); %�ֲ���Դ������
    r = zeros(num_j, resource_cate, L); %�ֲ���Դ������
    d = zeros(num_j, 1, L); %�ƻ�����
    E = zeros(num_j, num_j - 2, L); %��������

    for i = 1:L
        [R1, r1, d1, E1] = process_rcp(FileName(i, :), resource_cate, num_j); %ʹ�����������ʱ��������ȡ��Ҫ����
        R(:, :, i) = R1; % ������ά�ȱ�ʾ��Ŀ��
        r(:, :, i) = r1; % ������ά�ȱ�ʾ��Ŀ��
        d(:, :, i) = d1; % ������ά�ȱ�ʾ��Ŀ��
        E(:, :, i) = E1;
    end

    %% ��.��PA��ʼ���ֲ�����׼��
    % 2.1 ˽���޸�����R��r
    for i = 1:size(r, 3) % i���
        r(:, 4, i) = 0; %ʹ�� r�ĵ����о�Ϊ0 �������һ�У�
        R(1, 4, i) = 0;
        %ʹ��R�ĵ�����Ϊ0������Ҫ������ֲ���Դ����Ϊ������Ҫ�ѵ�����ֲ���Դ��Ϊ��Ҫȫ����Դ
    end

    %2.2 �����ǰ� forestset
    %         for i=1:L
    %             forestset(:,:,i) = find_forestset(E(:,:,i), num_j);
    %         end
    %2.3 ����ؼ�·������CPM
    % CPM                       �ؼ�·������              1 * L
    % cpm_start_time            ���ʼʱ��              L * num_j
    % cpm_end_time              �����ʱ��              L * num_j
    %         parfor i=1:L
    %             sprintf('�ؼ�·�����ڽ���:%d / %d',i, L)
    %             [CPM(i), cpm_start_time(i,:), cpm_end_time(i,:)] = cpm(d(:,:,i), E(:,:,i));
    %         end
    %% ��.CAȫ��Э������׼��
    %3.1 �������1��2  GlobalSourceRequest��skill_cate
    % GlobalSourceRequest---ȫ����Դ������  L * num_j
    % skill_cate--ÿ�����Ҫ�ļ�������   L * num_j�����ļ���ÿ�����Ҫ1�ּ��ܣ�������ɣ�
    rand('seed', 1);
    GlobalSourceRequest = round(rand(L, size(r, 1)) * 3); %ȫ����Դ������[1,3]���ѡȡ��rand(L, size(r,1))����ά��
    GlobalSourceRequest(:, 1) = 0; GlobalSourceRequest(:, num_j) = 0; %��֤����������Ϊ0
    %GlobalSourceRequest = ceil(3 * rand(L, size(r,1)));%ȫ����Դ������[1,3]���ѡȡ��rand(L, size(r,1))����ά��
    rand('seed', 2);
    skill_cate = ceil(skill_count * rand(L, size(r, 1))); %���Ҫ�ļ�������[1,5]���ѡȡ

    for i = 1:L

        for j = 1:size(r, 1)

            if GlobalSourceRequest(i, j) %��GlobalSourceRequest����ֵ�����û��Ҫȫ����Դ,����Ҫ����
                continue
            else
                skill_cate(i, j) = 0;
            end

        end

    end

    %3.2 �������3��4   Lgs������Դ����
    a = [0.6 0.8 1.0];
    rand('seed', 3);
    Lgs = a(unidrnd(length(a), skill_count, people));

    for j = 1:size(Lgs, 2)

        a = [skill_count - 3, skill_count - 2]; %����ĸ�����Ҫô2Ҫô3
        b = randperm(length(a)); %�� 1,2�����ֻѡ���һ������Ϊ���������

        if a(b(1)) ~= 0
            c = randperm(skill_count, a(b(1)));

            for jj = 1:length(c)
                Lgs(c(jj), j) = 0;
            end

        end

        % end
        original_skill_num = sum(Lgs ~= 0, 2)';
    end

    %     end

    data_set.R = R;
    data_set.r = r;
    data_set.d = d;
    data_set.E = E;
    data_set.GlobalSourceRequest = GlobalSourceRequest;
    data_set.skill_cate = skill_cate;
    data_set.Lgs = Lgs;
    data_set.original_skill_num = original_skill_num;
end
