function [] = config()
    global DataSet LeaveInfo
    DataSetPath = '..\ʾ��_���⼯';
    LeaveInfoPath = '..\leave';

    DataSet = read_folder(DataSetPath, "rcp"); % []
    LeaveInfo = read_folder(LeaveInfoPath, "txt"); % []

end
