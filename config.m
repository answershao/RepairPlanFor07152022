function [DataSet, project_para] = config(project_para, file)
    num_j = project_para.num_j;
    L = project_para.L;

    DataSetPath = strcat('F:\\YuYining\\Code\\mpsplip_repair\\', 'j', num2str(num_j - 2), '\\', 'MP', num2str(num_j - 2), '_', num2str(L), '\\', 'mp', '_', 'j', num2str(num_j - 2), '_', 'a', num2str(L), '_', 'nr', num2str(file));

    FileNames = read_folder(DataSetPath, "sm"); % []

    [DataSet, people] = read_data_large(project_para, FileNames);
    project_para.people = people;

end
