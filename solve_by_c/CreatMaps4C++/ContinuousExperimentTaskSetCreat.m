function [TaskGroup,Entrances,Exits] = ContinuousExperimentTaskSetCreat(Row,Column,MAP,V_prod,T_ex)
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
[m,n] = size(MAP);
ExitPoints = zeros(1,2);
EndPoints = zeros(1,2);
%局部目标点选择集合
LocalGoalSet = [0 -1;1 -1;2 0;2 1;1 2;0 2;-1 1;-1 0];
%入口与出口
% Entrances = zeros(2*Row,2);
% Exits = zeros(2*Row,2);
% Entrances(1:Row,:) = [(1:Row)'*4-2',ones(Row,1)];
% Entrances(Row+1:2*Row,:) = [(1:Row)'*4-2',ones(Row,1)*n];
% Exits = [Entrances(:,1)-1,Entrances(:,2)];

% 产生的入口数和出口数比以上方法多一行
Entrances = zeros(2*Row+2,2);
Exits = zeros(2*Row+2,2);
Entrances(1:Row+1,:) = [(1:Row+1)'*4-2',ones(Row+1,1)];
Entrances(Row+2:2*Row+2,:) = [(1:Row+1)'*4-2',ones(Row+1,1)*n];
Exits = [Entrances(:,1)-1,Entrances(:,2)];
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
for i = 1:length(T_arri)
    %入口从入口集中随机选择
    TaskGroup.StartPoints(i,:) = Entrances(randi(size(Entrances,1)),:); 
    %选择目标点
    j = randi(8); %随机在所选择的分拣窗格周围选择一个位     
    EndPoints = [4*randi(Row)-1,4*randi(Column)+1] + LocalGoalSet(j,:);  %此处直接选好位置，也可以在程序运行时选择，后续再详细选定。此处未验证是否重合，因为连续任务无法验证重合。
    TaskGroup.GoalPoints(i,:) = EndPoints;
    Distance = Exits - EndPoints;
    Distance = sum(abs(Distance),2);
    [~,j] = min(Distance);
    TaskGroup.ExitPoints(i,:) = Exits(j,:);
end

end

