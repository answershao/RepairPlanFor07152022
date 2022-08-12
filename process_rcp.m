function [delay, ad, R, r, d, E] = process_rcp(filepath, resource_cate, num_j)
    %process_rcp ��ȡrcp�ļ�
    %filepath = 'C:\\Users\\shpf_\\Desktop\\YU\\code\\\Ran\\10-10-0.5-0.5\\Pat1.rcp'
    %re=double(zeros(14,10));  %Ԥ�������,�ӿ��ٶ�
    re = double(zeros(num_j * 2 + 2, 10));
    fid = fopen(filepath); %���ı��ļ�
    INDEX = 0;
    count = 1;

    while ~feof(fid) % �ж��Ƿ�Ϊ�ļ�ĩβ
        INDEX = INDEX + 1;
        str = fgetl(fid); % ���ļ�����

        if INDEX == 15
            x = str2num(str(1:end));
            re(count, 1:size(x, 2)) = x;
            count = count + 1;
        end

        if INDEX >= 19 && INDEX <= 18 + num_j
            x = str2num(str(1:end));
            re(count, 1:size(x, 2)) = x;
            count = count + 1;
        end

        if INDEX >= 23 + num_j && INDEX <= 22 + num_j * 2
            x = str2num(str(1:end));
            re(count, 1:size(x, 2)) = x;
            count = count + 1;
        end

        if INDEX == 26 + num_j * 2
            x = str2num(str(1:end));
            re(count, 1:size(x, 2)) = x;
            count = count + 1;
        end

    end

    fclose(fid); %close�ı��ļ�

    delay = re (1, 5); %��Ŀ��λ���ڳɱ�
    ad = re(1, 3); %��Ŀ����ʱ��
    R = re(num_j * 2 + 2, 1:resource_cate); % ��Դ������
    r = re(num_j + 2:2 * num_j + 1, resource_cate:resource_cate + 3); %��Դ������
    d = re(num_j + 2:2 * num_j + 1, 3); % ��ƻ�����
    E = re(2:num_j + 1, resource_cate:end); % ����  ���������������0
    E = [E, zeros(num_j, num_j - 2 - size(E, 2))];
