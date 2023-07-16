function [TaskGroup] = ContinuousExperimentTaskSetCreat_MovingAI(EntrancePoints,ExitPoints,MAP,V_prod,T_ex,Length_Task)
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
% Get the indices of reachable points in MAP
reachable_points = find(MAP == 2);
[reachable_x, reachable_y] = ind2sub(size(MAP), reachable_points);
reachable_coords = [reachable_x, reachable_y];

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
    startPoint = EntrancePoints(randi(size(EntrancePoints, 1)), :);
    
    % Generate total distance according to Gaussian distribution
    total_dist = round(normrnd(Length_Task, 0.05 * Length_Task));
    
    % Divide the total distance into dist1 and dist2
    dist1 = round((0.3 + 0.4*rand(1)) * total_dist); %��ֹ���������1��0�������м��Ŀ����ǰ��һ��
    dist2 = total_dist - dist1;
    
    % Find goal and exit points at the given distances
    goalPoint = get_point_at_distance(MAP, startPoint, dist1);
    exitPoint = get_point_at_distance(MAP, goalPoint, dist2);
    
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

function point = get_random_reachable_point(MAP)
    [rows, cols] = find(MAP == 2);
    index = randi(length(rows));
    point = [rows(index), cols(index)];
end

function point = get_point_at_distance(MAP, source, distance)
    [rows, cols] = find(MAP == 2);
    points = [rows, cols];
    dists = pdist2(source, points, 'cityblock');
    [~, index] = min(abs(dists - distance));
    point = points(index, :);
end

