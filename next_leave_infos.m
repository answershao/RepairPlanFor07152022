% ���t=��ʱ��,��ʼѭ��, �������ֵP,����0.5�ļ�¼Ϊ���ʱ��,

% ���ȷ�����ʱ��㣺���ɷֲ��� ��ֵΪǰһ�����ȼƻ�����Ŀ���ڵ�һ��,ÿ�ν����޸�ǰ,��Ҫȷ��һ����ٵ�Ա��,
%�����ʱ��������ѡ��һ��Ա����ټ���,����ѡ��������ͼ����ʱ��
% ������һ�ε��޸����ȼƻ��е����ʱ���ظ�,����һ��,���t=5ʱ�����,����ѡ��Ա��2��٣���һ�μ�ʹ���5��ȻΪ���ʱ��,Ҳ����һ���趨�õ���ٵ�Ա��Ϊ׼,��Ա��2����T=5���
% ѭ������һ�εõ�����Ŀ����ʱ��Ϊ׼

% ÿ��Ա��������ٶ�Σ�����������и����ޣ�
%��Ա���������Ϊ�¼٣������¼�������������Ա���������Ϊ���٣����ղ�������������

%��ÿ��ʱ��ֻ����һ��Ա����٣�ÿ���ֻ����һ��ʱ��Ϊ��������ÿ���ֻ����һ��Ա�����һ��

%һ��Ա��������ٶ�Σ��������ʱ������,ÿ�����и��������������һ��������������������ǰһ�����ȼƻ����������£����������¼���

%% ������ٹ���leave_duration
%1.�¼�[0.5,4],һ�������4�죬һ�겻����30��
%�������ڳ����У���������ĩ��һ���Թ���20����㣬ÿ20�����4����٣�max(makespan)����20��20���㣬һ����20*12=240���㣬240�ڲ���30��
%2.����[0.5,10],һ�������10�죬һ�겻����15��------����

function [leave_infos, save_staff_leave_totaltime] = next_leave_infos(project_para, schedule_solution, timeoff, iter_variables_with_time, iter_allocated_variables_information, iter_allocated_acts_information, save_leave_time, save_staff_leave_totaltime)
    save_pro_act_infos = {};
    count = 0;
    resource_serial = [];

    %% һ.�������ʱ��iter_prepare_leave_time
    makespan = iter_allocated_variables_information{length(iter_allocated_variables_information)}.makespan; %��һ���ʱ�̵Ĺ���
    LAMBDA = max(makespan) / 2;
    leave_time = intmax('uint64');

    while leave_time >= length(iter_variables_with_time)
        % sprintf('leave time :%d', leave_time)
        prepare_leave_time = poissrnd(LAMBDA, 1, 1); % ������LambdaΪƽ��ֵ��m��n��Poisson �������
        leave_time = save_leave_time + prepare_leave_time; %���ʱ�̣���ǰһ�����ʱ��֮�󣬱�֤��ʱ��������
        %% �����������ʱ�̵�Ӱ�����ؼ�����
        %������һ��������꣬iter_variables_with_time�д�ŵ����һ����ķ���ʱ�̣���Ϊ���ȫ����������ֹͣ�ˣ�allocated_set������
        %����û�и����Ա��returnʱ���ͷ���Դ����Ϊ��Ϊ��Ѿ�ȫ��ִ�����ˣ��ͽ�����
        %������Ҫ������һ�����ȼƻ�������һ�ε����ʱ�̣������һ�����ʱ�������һ����ķ���֮����У�
        %����֮ǰû����������Ļ�δreturn�����Ա���ͷţ�������©����Դ
        %���ϣ�����1����������Ҳ��δδreturn�����Ա���ͷţ����������ʱ��
        %����2�������ʱ�̿�����length(iter_variables_with_time)֮�ڣ�֮��Ͳ�������
    end

    baseline_makespan = max(schedule_solution.variables_with_time{length(schedule_solution.variables_with_time)}.makespan);

    %% ��.�������Ա��leave_staff
    staff_qualified = 0;
    scaned_staffs = zeros(1, project_para.people);

    while ~staff_qualified

        % ��������Ա�����������㣬���˳�ѭ��
        if sum(save_staff_leave_totaltime) >= project_para.timeoff_level * baseline_makespan || all(scaned_staffs)
            break
        end

        leave_staff = randperm(project_para.people, 1); %��ԭ����Դ����ѡ��һ��Ϊ���Ա��
        scaned_staffs(leave_staff) = 1;

        % condition1
        months = ceil(baseline_makespan / 20);

        if save_staff_leave_totaltime(1, leave_staff) < (4 * months)
            %�¼٣��������0.5����1��ʼ��������㣬��1-4��ѡ��1������
            leave_duration = randperm(min(4, min(30 - save_staff_leave_totaltime(1, leave_staff), project_para.timeoff_level * baseline_makespan - sum(save_staff_leave_totaltime))), 1);

            %condition2--- if leave_staff ��������
            for i = 1:length(iter_allocated_acts_information)
                each_allocated_act_info = iter_allocated_acts_information{i};

                if ~isempty(timeoff) && ~isempty(timeoff.leave_activity_infos)

                    if each_allocated_act_info.project_and_activity == timeoff.leave_activity_infos.project_and_activity %��α����ظ��ң���Ϊ�����Ǹ���Performing�洢��
                        count = count + 1;
                        save_pro_act_infos{count}.project_and_activity = each_allocated_act_info.project_and_activity;
                        save_pro_act_infos{count}.allocated_resource_num = each_allocated_act_info.allocated_resource_num; %����Դ2,4
                        save_pro_act_infos{count}.activity_start_time = each_allocated_act_info.activity_start_time;
                        save_pro_act_infos{count}.activity_end_time = each_allocated_act_info.activity_end_time;
                        %ѡ������ʱ��leavetime�������ʱ����ִ�л����Ҫ��֤�û����֮ǰ����ٻ

                        %1.���leavetime����һ�����ʱ������ٻ�Ľ���֮�䣬����Ҫ��Ϊ��һ��ٻ�ķ�����Դɾ��������ʣ����Դѡ���Ա�������ж���������Ƿ���������
                        %2.���leavetime����һ����ٻ�Ľ���֮����ֻ��Ҫ�������Ա���Ƿ���������������޼���
                        for resource = 1:people
                            resource_serial(resource) = resource; %����Դ�����
                        end

                        if save_pro_act_infos{count}.activity_start_time <= leave_time <= save_pro_act_infos{count}.activity_end_time

                            [~, index_leave_staff] = ismember(leave_staff, save_pro_act_infos{count}.allocated_resource_num);

                            if index_leave_staff == 0 %˵��leave_staff��ִ����һ��ٻ������
                                staff_qualified = 1;
                                break
                                %                         else %leave_staff��ִ����һ��ٻ��������
                            end

                        else %iter_prepare_leave_timeҲһ������save_leave_time��˵���ϴε���ٻ�Ѿ�������ֻ�迼����������Ƿ���������
                            staff_qualified = 1;
                            break
                        end

                    end

                else
                    staff_qualified = 1;
                    break
                end

            end

        end

    end

    if staff_qualified
        leave_infos.leave_staff = leave_staff;
        leave_infos.leave_duration = leave_duration;
        save_staff_leave_totaltime(1, leave_infos.leave_staff) = save_staff_leave_totaltime(1, leave_infos.leave_staff) + leave_infos.leave_duration;
        leave_infos.leave_time = leave_time;
        leave_infos.return_time = leave_infos.leave_time + leave_infos.leave_duration;
    else
        leave_infos = {};
    end

end
