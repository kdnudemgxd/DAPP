function [TaskGroup,Entrances,Exits] = ContinuousExperimentTaskSetCreat(Row,Column,MAP,V_prod,T_ex)
%UNTITLED10 ����ʵ���������������������ʱ�䣬����������ʵ�����
% ���������
% TaskSet.StartPoints ,������㣬�����λ��
% TaskSet.GoalPoints ,����Ŀ���
% TaskSet.ExitPoints ,�����뿪��
% �������ʱ��
% ���������
% ����������ʲ�����ȡ����ת��Ϊlambda���Բ��ɷֲ������������� V_prod
% ʵ��ʱ�� T_ex

%% ׼������
[m,n] = size(MAP);
ExitPoints = zeros(1,2);
EndPoints = zeros(1,2);
%�ֲ�Ŀ���ѡ�񼯺�
LocalGoalSet = [0 -1;1 -1;2 0;2 1;1 2;0 2;-1 1;-1 0];
%��������
% Entrances = zeros(2*Row,2);
% Exits = zeros(2*Row,2);
% Entrances(1:Row,:) = [(1:Row)'*4-2',ones(Row,1)];
% Entrances(Row+1:2*Row,:) = [(1:Row)'*4-2',ones(Row,1)*n];
% Exits = [Entrances(:,1)-1,Entrances(:,2)];

% ������������ͳ����������Ϸ�����һ��
Entrances = zeros(2*Row+2,2);
Exits = zeros(2*Row+2,2);
Entrances(1:Row+1,:) = [(1:Row+1)'*4-2',ones(Row+1,1)];
Entrances(Row+2:2*Row+2,:) = [(1:Row+1)'*4-2',ones(Row+1,1)*n];
Exits = [Entrances(:,1)-1,Entrances(:,2)];
% �������ʱ�䣬ͨ��lambda��������ʱ������Ȼ�����ۻ��͵õ�����ʱ��
lambda = 1/V_prod;
T_arri = random('poisson',lambda,1,ceil(T_ex/lambda));
T_arri = cumsum(T_arri);
%����ṹ��
TaskGroup.ArriveTimes = T_arri';
TaskGroup.TempGoalNum = zeros(length(T_arri),1);
TaskGroup.StartPoints = zeros(length(T_arri),2);
TaskGroup.GoalPoints = zeros(length(T_arri),2);
TaskGroup.ExitPoints = zeros(length(T_arri),2);
%% Ϊÿ������ʱ�������ϸ����
for i = 1:length(T_arri)
    %��ڴ���ڼ������ѡ��
    TaskGroup.StartPoints(i,:) = Entrances(randi(size(Entrances,1)),:); 
    %ѡ��Ŀ���
    j = randi(8); %�������ѡ��ķּ𴰸���Χѡ��һ��λ     
    EndPoints = [4*randi(Row)-1,4*randi(Column)+1] + LocalGoalSet(j,:);  %�˴�ֱ��ѡ��λ�ã�Ҳ�����ڳ�������ʱѡ�񣬺�������ϸѡ�����˴�δ��֤�Ƿ��غϣ���Ϊ���������޷���֤�غϡ�
    TaskGroup.GoalPoints(i,:) = EndPoints;
    Distance = Exits - EndPoints;
    Distance = sum(abs(Distance),2);
    [~,j] = min(Distance);
    TaskGroup.ExitPoints(i,:) = Exits(j,:);
end

end

