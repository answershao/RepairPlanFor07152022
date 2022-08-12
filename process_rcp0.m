function [people] = process_rcp0(FileName, L)
    fid = fopen(FileName(L + 1, :)); %打开文本文件
    str = fgetl(fid);
    % re = double(zeros(1,length(str)));
    % for i = 1:length(str)
    %    re(i) = str2num(str(i));
    % end
    %re_s = [re_s;re];
    %项目到达时间
    people = str2num(str);
end
