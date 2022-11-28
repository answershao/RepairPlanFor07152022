%function [local_start_time, local_end_time] = find_PR(num_j,R, r, d, E, cpm_start_time, cpm_end_time,resource_cate,ad)
function [original_local_start_time,original_local_end_time] = find_PR(num_j,R, r, d, E, cpm_end_time,resource_cate,forestset,ad)
%1.�ƶ����ȹ���-�ִ��˳��  (��LFT�ƶ�-�������ڣ�
%LST- ����ʼʱ�䣬CPM��������ȵĿ�ʼʱ��Ϊ����ʼʱ��
%LFT-�������ʱ�䣬min{���н�����LST}
%LST(end)=EST(end������Ϊ�յ�һ���ڹؼ�·���ϣ��ؼ�·���ϵĵ����翪ʼʱ���������ʼʱ�䣬���ǹؼ�·���ϵĵ㲻һ����
%Ȼ���������ƣ�������ʼʱ��LST��

f=zeros(1,num_j+1);  %��Ӵ���original_local_start_time
LST = zeros(1,num_j); %Ԥ���ɸ����������ʼʱ��
%LFT = zeros(1,num_j); %Ԥ���ɸ�������������ʱ��
act_number = []; %�������

local_start_time = zeros(1,num_j);
local_end_time = zeros(1,num_j);
T = 500;


%����CPM�õ��Ļ�б���ʼ�������
%  [new_local_end_times(1,:),index] = sort(cpm_end_time(1,:),'descend');
for  act = 1: num_j
    act_number(act)= act;
end

AA= [-cpm_end_time(1,:);-act_number];
[BB,indexB] = sortrows(AA');   
BB(:,1:2) = - BB(:,1:2);

back_gen  = BB(:,2)';
% new_local_end_times(1,:) = BB(:,1)';
% %��ʱ��˳���϶�Ӧ�Ļ��ע����-�µĻ�б�λ�úż����


LST(num_j) = max(cpm_end_time(1,:));  %���������Ļ����,��
%LFT(num_j) = max(cpm_end_time(1,:));  %���������Ļ����
for s=2:num_j %����back_gen�еĻ˳���б�ȷ��LST
    activity_choose=back_gen(s);  %���ŵĻΪactivity_choose=29
     sucdecessors=E(activity_choose,:,1);%%%������ѡ��Ľ�������
    sucdecessors(find(sucdecessors==0)) = [];
    if length(sucdecessors) ==1
    LST(activity_choose) = LST(sucdecessors) -d(activity_choose);
    else
        LST(activity_choose) = min(LST(sucdecessors)-d(activity_choose));
    end
   % LFT(activity_choose) = min(LST(sucdecessors));
end 

 [new_local_end_times(1,:),index] = sort(LST);%����ʼʱ����������

%��LFTһ��ʱ������min��LFT��Ϊ�������Դ
% [new_local_end_times(1,:),index] = sort(LFT);  %LFT�������� indexָ��Ӧ�Ļ���,
 %ͨ��LFT��ȷ���ִ�е��б�index������깤ʱ����С����ִ�У���������
 

%2.Ϊ���źõĻ����ֲ���Դ
for local_resource=1:resource_cate   %��Դ����,ֻ��ǰ�����Ǿֲ���Դ,����Ϊ�˱�֤��������һ���������һ����ԴΪ0���ɣ�����ܣ�
    remaining_resource(local_resource,:) = ones(1,T)*R(1,local_resource,1);
end % ��ʼ����Ŀ�����ڵľֲ��ɸ�����Դ������

original_local_end_time = new_local_end_times(1,:);%�������ã�time1=1�͸�ֵ��Ҳ���ԣ������

%��ʼ������Դ
for y = 2: num_j
    activity = index(y);
    predecessors=forestset(activity,:,1);  %activity�Ľ�ǰ���predecessors_index1��ʾ��������Ϊgenֻ��һ�У����Խ���϶�����1111
    predecessors(find(predecessors==0)) = [];
    %[~,predecessors_index2]=ismember(predecessors,index(1:y)); %ismember�жϽ�ǰ���Ԫ������gen����Ϊ1����������Ϊ0
    [~,predecessors_index2]=ismember(predecessors,index); %ismember�жϽ�ǰ���Ԫ������gen����Ϊ1����������Ϊ0
    time1=max(original_local_end_time(1,index(predecessors_index2)));  %��ǰ�������깤ʱ��?

 for time2 = time1+1 : T
        %for time2 = time11 : T                       %POP0(np,predecessors_index2)��λ���ϵĻ�����ҽ�ǰ����ʱ�������Ǹ�
        %�ж���time2��time2+d(activity,:,q)-1��ʱ�������ԴԼ���Ƿ�����
        for time3 = time2 : (time2+d(activity,:,1)-1)
            % for time3 = time2 : (time2+d(activity,:,1))%�Ӹû�Ŀ�ʼʱ��1������ʱ��5������ִ���ڼ��ڣ��ֲ���Դ������
            if all(remaining_resource(:,time3)>=r(activity,:,1)')%ÿ��time3��ʾCPM���һ��ʱ�Σ�����Դ���������
                A=1;   %����ʱ����������ľֲ���Դʣ���������ڸû������������Դ������������A = 1
                continue
            else
                A=0;
                break
            end
        end
        if A==1      %�ж�A�Ƿ�Ϊ1������ǰʱ�̣��ɷ���û����ֲ���Դ
            original_local_start_time(1,activity)=time2-1;
            original_local_end_time(1,activity) = original_local_start_time(1,activity)+d(activity,:,1);
            % original_local_end_times(1,activity)=original_local_start_times(1,activity)+d(activity,:,1);%�j�Ľ���ʱ�䣿���ǻactivity
            %f(1+activity) = original_local_start_time(1,activity);
            for time=original_local_start_time(1,activity)+1:original_local_end_time(1,activity)
                remaining_resource(:,time)=remaining_resource(:,time)-r(activity,:,1)';  %���¾ֲ���Դ��ʣ�������
            end
            break
        else
            continue
        end
 end
     %new_local_end_times = original_local_end_time;
end

original_local_start_time = original_local_start_time +ad;
 original_local_end_time = original_local_end_time + ad;
% 

% 
% 
% 
% %  local_start_time = back_start_time;
% %  local_end_time = back_end_time;
% 
% %������ϵ���ʽ��LST���Ʒ���
% 
% %LFT(1,j) = min{LST(E(1,j))};
% 
% 
% %���󵥸���Ŀ�Ŀ�ʼ����������ټӵ���ʱ��ad
% 
