function [R, r, d, E] = process_rcp(filepath, resource_cate, num_j)
    %process_rcp 读取rcp文件
    %filepath = 'C:\\Users\\shpf_\\Desktop\\YU\\code\\\Ran\\10-10-0.5-0.5\\Pat1.rcp'
    re = double(zeros(7, 7)); %预定义矩阵,加快速度 (行：num_j+2,列： resource_cate4+d1+紧后活动个数+紧后活动集合)
    fid = fopen(filepath); %打开文本文件
    INDEX = 0;

    while ~feof(fid)
        str = fgetl(fid); % 读取一行, str是字符串

        if isempty(str)
            continue;
        end

        s = regexp(str, '\s+'); % 找出str中的空格, 以空格作为分割数据的字符
        %s = strsplit(str, ' ');
        %temp=str2num(str(s(end):end));    %找出最后的数据, 作为保存与否的判断条件
        %temp=str2num(str(s(20):s(21)));  %找出某个数据, 作为保存与否的判断条件

        INDEX = INDEX + 1;

        for i = 1:length(s) % 将字符串全部转为数组, 存于re中

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

    R = re(2, 1:resource_cate); % 资源可用量
    r = re(3:end, 2:resource_cate + 1); %资源需求量
    d = re(3:end, 1); % 活动计划工期
    E = re(3:end, resource_cate + 3:end); % 紧后活动  ，不够活动数，补齐0
    E = [E, zeros(num_j, num_j - 2 - size(E, 2))];
end
