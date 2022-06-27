function [] = config()
    global DataSet LeaveInfo
    DataSetPath = '..\示例_问题集';
    LeaveInfoPath = '..\leave';

    DataSet = read_folder(DataSetPath, "rcp"); % []
    LeaveInfo = read_folder(LeaveInfoPath, "txt"); % []

end
