function [R, r, d, E] = process_rcp(filepath, resource_cate, num_j)
    %process_rcp ��ȡrcp�ļ�
    %filepath = 'C:\\Users\\shpf_\\Desktop\\YU\\code\\\Ran\\10-10-0.5-0.5\\Pat1.rcp'
    re = double(zeros(7, 7)); %Ԥ�������,�ӿ��ٶ� (�У�num_j+2,�У� resource_cate4+d1+��������+��������)
    fid = fopen(filepath); %���ı��ļ�
    INDEX = 0;

    while ~feof(fid)
        str = fgetl(fid); % ��ȡһ��, str���ַ���

        if isempty(str)
            continue;
        end

        s = regexp(str, '\s+'); % �ҳ�str�еĿո�, �Կո���Ϊ�ָ����ݵ��ַ�
        %s = strsplit(str, ' ');
        %temp=str2num(str(s(end):end));    %�ҳ���������, ��Ϊ���������ж�����
        %temp=str2num(str(s(20):s(21)));  %�ҳ�ĳ������, ��Ϊ���������ж�����

        INDEX = INDEX + 1;

        for i = 1:length(s) % ���ַ���ȫ��תΪ����, ����re��

            if i == length(s)

                if str(s(i):end) == ' '
                    continue;
                end

                re(INDEX, i) = str2num(str(s(i):end));
            else
                re(INDEX, i) = str2num(str(s(i):s(i + 1)));
            end

        end

    end

    fclose(fid);

    R = re(2, 1:resource_cate); % ��Դ������
    r = re(3:end, 2:resource_cate + 1); %��Դ������
    d = re(3:end, 1); % ��ƻ�����
    E = re(3:end, resource_cate + 3:end); % ����  ���������������0
    E = [E, zeros(num_j, num_j - 2 - size(E, 2))];
end
