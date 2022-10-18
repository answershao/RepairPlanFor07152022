function [DataSet, project_para] = config(project_para, OS, RF, RS)
    L = project_para.L;

    DataSetPath = strcat('F:\\YuYining\\Code\\DataSet\\RanGenËãÀı¼¯\\', num2str(L), '-10\\', num2str(L), '-', num2str(OS), '-', num2str(RF), '-', num2str(RS));

    FileNames = read_folder(DataSetPath, "rcp"); % []

    [DataSet] = read_data_large(project_para, FileNames);

end
