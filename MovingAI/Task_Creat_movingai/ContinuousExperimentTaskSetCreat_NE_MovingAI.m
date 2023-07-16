function [TaskGroup] = ContinuousExperimentTaskSetCreat_NE_MovingAI(map_name,V_prod,T_ex,Length_Task)
%UNTITLED10 连续实验任务产生，添加任务产生时间，任务产生速率等属性
% 输出参数：
% TaskSet.StartPoints ,任务起点，即入口位置
% TaskSet.GoalPoints ,任务目标点
% TaskSet.ExitPoints ,任务离开点
% 任务产生时间
% 输入参数：
% 任务产生速率参数（取倒数转换为lambda，以泊松分布产生任务间隔） V_prod
% 实验时间 T_ex

%% 版本
% NE 无入口，出口，任务起点随机；依靠距离矩阵选取符合距离的目标点和离开点

%% 准备参数
% 装载距离矩阵
reachable_points = 0;
distance_matrix = 0;
load(strcat('F:\MATLAB_File\PrePBS-DDM-RHCR\PrePBS\MovingAI\',map_name,'\distance_matrix_',map_name,'.mat'));

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
    startPoint = reachable_points(randi(size(reachable_points, 1)), :);
    startPoint_line_num = find(all(reachable_points == startPoint, 2));
    
    % Generate total distance according to Gaussian distribution
    total_dist = round(normrnd(Length_Task, 0.05 * Length_Task));
    
    % Divide the total distance into dist1 and dist2
    dist1 = round((0.3 + 0.4*rand(1)) * total_dist); %防止出现随机数1或0，导致中间的目标点和前后一样
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
