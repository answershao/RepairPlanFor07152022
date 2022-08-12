function [FileName] = read_folder(FolderPath, file_type)
    % read_folder
    % file_type: rcp
    % 输出 FileName 数组 存放文件名地址
    FolderPath1 = strcat(FolderPath, '\\*.', file_type);
    Content = dir(FolderPath1);
    NumOfFile = size(Content, 1);
    FileName = [];

    for i = 1:NumOfFile
        str = strcat(FolderPath, '\\', Content(i).name);
        FileName = [FileName; str];
    end

end

% function [FileName] = read_folder(FolderPath)
% %read_folder 此处显示有关此函数的摘要
% %   此处显示详细说明
% % 输出 FileName 数组 存放文件名地址
% FolderPath1 = strcat(FolderPath, '\\*.sm');
% Content=dir(FolderPath1);
% NumOfFile=size(Content,1);
% FileName = [];
% for i=1:NumOfFile
%     str=strcat(FolderPath,'\\',Content(i).name);
%     FileName = [FileName; str];
% end
% end
