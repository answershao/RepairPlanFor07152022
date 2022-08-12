function [delay, ad, R, r, d, E] = process_rcp(filepath, resource_cate, num_j)
    %process_rcp 读取rcp文件
    %filepath = 'C:\\Users\\shpf_\\Desktop\\YU\\code\\\Ran\\10-10-0.5-0.5\\Pat1.rcp'
    %re=double(zeros(14,10));  %预定义矩阵,加快速度
    re = double(zeros(num_j * 2 + 2, 10));
    fid = fopen(filepath); %打开文本文件
    INDEX = 0;
    count = 1;

    while ~feof(fid) % 判断是否为文件末尾
        INDEX = INDEX + 1;
        str = fgetl(fid); % 从文件读行

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

    fclose(fid); %close文本文件

    delay = re (1, 5); %项目单位延期成本
    ad = re(1, 3); %项目到达时间
    R = re(num_j * 2 + 2, 1:resource_cate); % 资源可用量
    r = re(num_j + 2:2 * num_j + 1, resource_cate:resource_cate + 3); %资源需求量
    d = re(num_j + 2:2 * num_j + 1, 3); % 活动计划工期
    E = re(2:num_j + 1, resource_cate:end); % 紧后活动  ，不够活动数，补齐0
    E = [E, zeros(num_j, num_j - 2 - size(E, 2))];
