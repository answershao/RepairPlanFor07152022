function [FileName] = read_folder(FolderPath, file_type)
    % read_folder
    % file_type: rcp
    % ��� FileName ���� ����ļ�����ַ
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
% %read_folder �˴���ʾ�йش˺�����ժҪ
% %   �˴���ʾ��ϸ˵��
% % ��� FileName ���� ����ļ�����ַ
% FolderPath1 = strcat(FolderPath, '\\*.sm');
% Content=dir(FolderPath1);
% NumOfFile=size(Content,1);
% FileName = [];
% for i=1:NumOfFile
%     str=strcat(FolderPath,'\\',Content(i).name);
%     FileName = [FileName; str];
% end
% end
