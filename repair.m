% ���߽��ȼƻ�
% 2. %��ٵ㣬��t=0��ʼѭ�����Ƿ���Ա�����
% 3. %���У���t1ʱ�̵�һ��Ա����٣��жϵ�ǰ����Ա���ɷ�����ִ��Ҫ��
% 4.%�����㣬��Ϊ�������Դ
% 5. %�񣬷���һ���ȴ���һʱ�̼����ж�

% %����������ǰʱ���������ڽ��еĻ��ͣ��ͨ����������е��������·�����Դ

% 6.%��ε�����
% 7.%�����ǰ���ٵĻ�����ڽ��еĻ������һ��softmax���֣�������Դͬ���߽��ȼƻ�

%�Ҹ�Ա����ٵĻ

%Ϊ�û���·�����Դ

%1.ʣ��Ա���д��ڿ���Ա�������ܡ����������㣩
%allocate_resource ������Դ
%2. ʣ��Ա���в����ڿ���Ա�������ܡ�������һ�����㣩
%����һ�� wait for solving

%�������� ��������е�����Դ�� ������ִ�еĻ����ͣ������Դ���ͷţ�������Դ���·���
%1.������ͬ�ȼ��ܵ���
%2.ȥ����ٵ���
%3.�ҵ����ϼ���Ҫ����ˣ�����¼��ǰʱ��������ִ�еĻ
%4. Ϊ��ٻ���������Ļ��������Դ

% 8.%�������ӵ�ǰʱ�̿�ʼѭ����t = t1+1��ע������뷵��ʱ��Գ��֣���Դ���¿��ǣ�����+������ͷţ�;
% 9.%����ͬ���߼ƻ�����ɺ󣬵õ�Ŀ��ֵ�� ƽ����Ŀ����APD+���ʼʱ��ƫ�� +��Ա����ʱ��仯ƫ��
% 10.%�жϷ���һ�Ͷ���Ŀ��ֵ����Сѡ��һ

% 10. %��t1��ʼѭ��������һ���жϵ㣬��Ա����٣��ظ���������

% 11.%ÿ�����ߵ㶯̬����ѡ�����ŷ�����ֱ��������л�ĵ���

% default file readed
config()

% define num_j, L,
project_para.num_j = 5; % �ܻ��
project_para.L = 2; % ��Ŀ����
project_para.resource_cate = 4; % ��Դ������
project_para.skill_count = 3; % ����������
project_para.T = 500; % ��ʱ��
project_para.cycles = 1; % 10��
project_para.people = 5;

for cycle = 1:project_para.cycles

    [data_set, leave_infos] = read_data(project_para);
    % schedule_solution: start_time, end_time, resource_assignment
    schedule_solution = baseline_schedule(project_para, data_set, cycle);

    % repair plan

    %�����ʱ���
    for t1 = 1:length(leave_infos.leave_time)
        leave_infos.staff(t1) ;%
    leave_infos.leave_duration(t1);
    leave_infos.leave_time(t1) ;
        leave_infos.leave_time(t1);%
        %�����ʱ������ִ�еĻ����schedule_solution 
        %�����л��ͣ����Դ�ͷ�


    end

    for index = 1:length(leave_infos)
        % staff = leave_infos(index){1};
        % leave_time = leave_infos(index){2};
        % leave_length = leave_infos(index){3};

        % repair solution: start_time, end_time, resource_assignment, objective
        repair_solution1 = wait_for_sloving(leave_infos(index), schedule_solution);
        repair_solution2 = adjust(leave_infos(index), schedule_solution);

        if objective1 < objective2
            repair_solution = repair_solution1;
        end

        schedule_solution = repair_solution;
    end

end

dynamic_schedule
