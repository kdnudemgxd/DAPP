function [TaskGroup] = ContinuousExperimentTaskSetCreat_MovingAI(EntrancePoints,ExitPoints,MAP,V_prod,T_ex,Length_Task)
%UNTITLED10 连续实验任务产生，添加任务产生时间，任务产生速率等属性
% 输出参数：
% TaskSet.StartPoints ,任务起点，即入口位置
% TaskSet.GoalPoints ,任务目标点
% TaskSet.ExitPoints ,任务离开点
% 任务产生时间
% 输入参数：
% 任务产生速率参数（取倒数转换为lambda，以泊松分布产生任务间隔） V_prod
% 实验时间 T_ex

%% 准备参数
% Get the indices of reachable points in MAP
reachable_points = find(MAP == 2);
[reachable_x, reachable_y] = ind2sub(size(MAP), reachable_points);
reachable_coords = [reachable_x, reachable_y];

% 任务产生时间，通过lambda参数产生时间间隔，然后以累积和得到具体时间
lambda = 1/V_prod;
T_arri = random('poisson',lambda,1,ceil(T_ex/lambda));
T_arri = cumsum(T_arri);
%任务结构体
TaskGroup.ArriveTimes = T_arri';
TaskGroup.TempGoalNum = zeros(length(T_arri),1);
TaskGroup.StartPoints = zeros(length(T_arri),2);
TaskGroup.GoalPoints = zeros(length(T_arri),2);
TaskGroup.ExitPoints = zeros(length(T_arri),2);
%% 为每个到达时间产生详细任务
tasks = cell(1, length(T_arri));
for i = 1:length(T_arri)
    startPoint = EntrancePoints(randi(size(EntrancePoints, 1)), :);
    
    % Generate total distance according to Gaussian distribution
    total_dist = round(normrnd(Length_Task, 0.05 * Length_Task));
    
    % Divide the total distance into dist1 and dist2
    dist1 = round((0.3 + 0.4*rand(1)) * total_dist); %防止出现随机数1或0，导致中间的目标点和前后一样
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

