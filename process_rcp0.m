function [people] = process_rcp0(FileName, L)
    fid = fopen(FileName(L + 1, :)); %���ı��ļ�
    str = fgetl(fid);
    % re = double(zeros(1,length(str)));
    % for i = 1:length(str)
    %    re(i) = str2num(str(i));
    % end
    %re_s = [re_s;re];
    %��Ŀ����ʱ��
    people = str2num(str);
end
