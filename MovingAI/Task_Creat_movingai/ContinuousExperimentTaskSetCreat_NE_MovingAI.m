function [TaskGroup] = ContinuousExperimentTaskSetCreat_NE_MovingAI(map_name,V_prod,T_ex,Length_Task)
%UNTITLED10 ����ʵ���������������������ʱ�䣬����������ʵ�����
% ���������
% TaskSet.StartPoints ,������㣬�����λ��
% TaskSet.GoalPoints ,����Ŀ���
% TaskSet.ExitPoints ,�����뿪��
% �������ʱ��
% ���������
% ����������ʲ�����ȡ����ת��Ϊlambda���Բ��ɷֲ������������� V_prod
% ʵ��ʱ�� T_ex

%% �汾
% NE ����ڣ����ڣ������������������������ѡȡ���Ͼ����Ŀ�����뿪��

%% ׼������
% װ�ؾ������
reachable_points = 0;
distance_matrix = 0;
load(strcat('F:\MATLAB_File\PrePBS-DDM-RHCR\PrePBS\MovingAI\',map_name,'\distance_matrix_',map_name,'.mat'));

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
tasks = cell(1, length(T_arri));
for i = 1:length(T_arri)
    startPoint = reachable_points(randi(size(reachable_points, 1)), :);
    startPoint_line_num = find(all(reachable_points == startPoint, 2));
    
    % Generate total distance according to Gaussian distribution
    total_dist = round(normrnd(Length_Task, 0.05 * Length_Task));
    
    % Divide the total distance into dist1 and dist2
    dist1 = round((0.3 + 0.4*rand(1)) * total_dist); %��ֹ���������1��0�������м��Ŀ����ǰ��һ��
    dist2 = total_dist - dist1;
    
    % Find goal and exit points at the given distances
    goalPoint_candidate = find(distance_matrix(startPoint_line_num,:) == dist1);
    goalPoint_line_num = goalPoint_candidate(randi(length(goalPoint_candidate)));
    goalPoint = reachable_points(goalPoint_line_num,:);
    exitPoint_candidate = find(distance_matrix(goalPoint_line_num,:) == dist2);
    exitPoint_line_num = exitPoint_candidate(randi(length(exitPoint_candidate)));
    exitPoint = reachable_points(exitPoint_line_num,:);
    
    task.startPoint = startPoint;
    task.goalPoint = goalPoint;
    task.exitPoint = exitPoint;
    tasks{i} = task;
end

for i = 1:length(T_arri)
    TaskGroup.StartPoints(i,:) = tasks{i}.startPoint;
    TaskGroup.GoalPoints(i,:) = tasks{i}.goalPoint;
    TaskGroup.ExitPoints(i,:) = tasks{i}.exitPoint;
end

end
