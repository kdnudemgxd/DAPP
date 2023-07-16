function [Para_StepNum,Shrink_Factor] = SetStepNum_PBS_by_Predication3(Row,Column,StepTime,TaskSetNum,RouteNow,TaskNowLoc,TaskNowDes,TaskGroup,Index_Task,EntrancePoints,SignTaskComplete,ExpectedSteps,SystemTime,FittingModel,CalTime,Shrink_Factor)
%% 通过预期的行走步数来设定此次计算时的步数，用于之后的临时目标选择
% 将TaskGroup_T替换为TaskGroup适应新的模式
% 为PBS算法所设置
%% 变量说明
%   此处显示详细说明
%StepTime 每走一步所需要的时间
%LoadPlace 装载点位置
%TaskNowNum 为现在已规划的任务的编号
%RouteNow为 已规划出的任务的路径
%TaskNowLoc 已规划出路径的车辆现在所在的位置
%TaskNowDes 为已规划出路径的车辆的目的地址
%TaskSetNum2 现在正在规划的任务信息，第一列表示入口编号，第2列表示任务编号
%SignOfTaskAssign 已分配任务的标志
%SignOfTaskAssign2 已分配的任务的标志2
%Task 所有任务
%ExpectedSteps 预期步数，用于控制后续任务拆分时候的步数，在预期步数能被满足的情况下尽量提升每次计算时的目标点长度

%T最终给出的估计时间
%% 改进
% 可选择是否预留一定程度的长度，如20%
% 时间上限打0.8折，避免超时问题，第二次这样做
% 220506采用收缩因子Shrink_Factor替代0.8的折中,初值为0.8,修改为对预置长度做操作，
% 在运行中，如果上次实际计算时间大于周期长度，则减小收缩因子；
% 如果小于0.5倍的周期长度，则增加收缩因子。
%% 程序
%load F:\MATLAB_File\PreMFN-DDM-HeatSec\MFN_Prediction_SetStep_Split\Fitting\CalTime_Prediction\PBS_CalTime\CalTimeModel_4PBS_r_70_c_38_SVM.mat %装载svm预测模型
load(FittingModel.CalModel);
% AddTask = zeros(1,size(SignOfTaskAssign2,1)); %需要新添加的任务
%% 先找出可能新添加的任务以及已有任务的下一个目标点（即出口所在的位置）
AddTask = [];
AddTaskLoc = zeros(0,2);
AddTaskDes = zeros(0,2);
NextTaskDes = zeros(length(TaskSetNum),2); %已存在任务的下一次目标点
% 可能新添加的任务
for i = 1:size(EntrancePoints,1)
    Index_Undistributed = find(TaskGroup.TempGoalNum == 0); %未分配的任务集合
    Index_Arrived = find(TaskGroup.ArriveTimes < SystemTime); %已到达的任务集合
    Index_Itsc = intersect(Index_Undistributed,Index_Arrived); %对应入口的任务集合
    Index_Itsc = intersect(Index_Itsc,Index_Task{i}); %符合要求的集合，即入口处的队列
    if ~isempty(Index_Itsc)
        %如果集合非空，则存在符合要求的任务，可以添加至待分配集合中
        AddTask = [AddTask Index_Itsc(1)]; %记录添加任务的编号
        AddTaskLoc = [AddTaskLoc ; TaskGroup.StartPoints(Index_Itsc(1),:)];
        AddTaskDes = [AddTaskDes ; TaskGroup.GoalPoints(Index_Itsc(1),:)];
    end
end
%已有任务的下一个目标点
% for i = 1:size(TaskSetNum,1)
%     x = TaskGroup.TempGoalNum(TaskSetNum(i));
%     if x < size(TaskGroup_T(TaskSetNum2(i,1),TaskSetNum2(i,2)).TempGoalPoint{1},1)
%         NextTaskDes(i,:) = TaskGroup_T(TaskSetNum2(i,1),TaskSetNum2(i,2)).TempGoalPoint{1}(x+1);
%     else
%         NextTaskDes(i,:) = [0,0]; %
%     end
% end
for i = 1:length(TaskSetNum)
    if SignTaskComplete(TaskSetNum(i)) == 1
        NextTaskDes(i,:) = TaskGroup.ExitPoints(TaskSetNum(i),:);
    else
        NextTaskDes(i,:) = [0,0]; %
    end
end
%% 依照ExpectedSteps设置预测参数
%到达目的点的距离，用于判断
LengthToDes = sum(abs(TaskNowDes-TaskNowLoc),2);

%预测的最大步数在已有路径的最小长度和最大长度之间，需要判断：
%1、哪些任务需要更换目的地
%2、哪些任务需要结束
TaskNowNum2 = [];
TaskNowLoc2 = [];
TaskNowDes2 = [];
for i = 1:length(TaskSetNum)
    if LengthToDes(i) > ExpectedSteps %距离目标点远的保留
        TaskNowNum2 = [TaskNowNum2 TaskSetNum(i)];
        TaskNowLoc2 = [TaskNowLoc2 ; RouteNow(ExpectedSteps+1,:,i)]; %迭代后的位置
        TaskNowDes2 = [TaskNowDes2 ; TaskNowDes(i,:)];
    else
        TaskNowNum2 = [TaskNowNum2 TaskSetNum(i)];
        TaskNowLoc2 = [TaskNowLoc2 ; TaskNowDes(i,:)];
        TaskNowDes2 = [TaskNowDes2 ; NextTaskDes(i,:)];
    end
end
PredicateTaskLoc = [TaskNowLoc2; AddTaskLoc];
PredicateTaskDes = [TaskNowDes2; AddTaskDes];
PredicateTaskNum = [TaskNowNum2 , AddTask];
%剔除已完成任务（距目标点距离小于预期距离）
x = find(PredicateTaskDes(:,1)==0);
PredicateTaskLoc(x,:) = [];
PredicateTaskDes(x,:) = [];
PredicateTaskNum(x) = [];

%AttrTime为最长距目标点距离，Attribution为预测所需的数据
AttrTime = max(sum(abs(PredicateTaskDes-PredicateTaskLoc),2));%最大距离参数
%Attribution = [Row,Column,length(PredicateTaskNum),AttrTime]; %得到预测所需参数
Attribution = [length(PredicateTaskNum),AttrTime]; %得到预测所需参数
%% 依照ExpectedSteps进行前进步数设置
StepList = 1:AttrTime; %从1到最大距离，均进行预测
PredTimeList = zeros(1,length(StepList));
%对步数列表进行预测
for i = 1:length(StepList)
    %Attribution(4) = StepList(i);
    Attribution(2) = StepList(i);
    AttritutionNormal = mapminmax('apply',Attribution',inputps);
    [Predict_1,error_1,dec_value1] = svmpredict(0,AttritutionNormal',model);
    Predict_Time1 = abs(mapminmax('reverse',Predict_1,outputps));
    PredTimeList(i) = Predict_Time1; %得到规划1到最大步数所对应的计算时间
end

%通过对比ExpectedTime得到合适的步数,找到拟合数据山坡左侧小于ExpectedTime的最大值
ExpectedTime = StepTime*ExpectedSteps; %预期最大时间
Para_StepNum = 1;
for i = 1:length(StepList)
    % 时间上限打0.8折，避免超时问题
    if PredTimeList(i) <= ExpectedTime
        Para_StepNum = i;
    else
        break;
    end
end
if CalTime > ExpectedTime
    Shrink_Factor = Shrink_Factor - 0.1;
    Shrink_Factor = max(Shrink_Factor,0.5);
elseif CalTime < ExpectedTime*0.5
    Shrink_Factor = Shrink_Factor + 0.1;
    Shrink_Factor = min(Shrink_Factor,1);
end
Para_StepNum = floor(Para_StepNum*Shrink_Factor); %收缩路径长度
Para_StepNum = max([Para_StepNum ExpectedSteps]); %最小等于预期步数

%% 记录预测时间,T2表示建模时时间维度上的扩展，即最后一个任务完成的时间
filename1 = '.\PredicateTime_Mindistance.csv';
fid1 = fopen(filename1, 'a');
fprintf(fid1,'R ,%d ,C ,%d ,N ,%d ,PreTime ,%f ,T2 ,%d ,\n',Row,Column,size(PredicateTaskNum,2),ExpectedTime,Para_StepNum);
fclose(fid1);
end
