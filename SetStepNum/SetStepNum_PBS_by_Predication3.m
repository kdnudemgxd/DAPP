function [Para_StepNum,Shrink_Factor] = SetStepNum_PBS_by_Predication3(Row,Column,StepTime,TaskSetNum,RouteNow,TaskNowLoc,TaskNowDes,TaskGroup,Index_Task,EntrancePoints,SignTaskComplete,ExpectedSteps,SystemTime,FittingModel,CalTime,Shrink_Factor)
%% ͨ��Ԥ�ڵ����߲������趨�˴μ���ʱ�Ĳ���������֮�����ʱĿ��ѡ��
% ��TaskGroup_T�滻ΪTaskGroup��Ӧ�µ�ģʽ
% ΪPBS�㷨������
%% ����˵��
%   �˴���ʾ��ϸ˵��
%StepTime ÿ��һ������Ҫ��ʱ��
%LoadPlace װ�ص�λ��
%TaskNowNum Ϊ�����ѹ滮������ı��
%RouteNowΪ �ѹ滮���������·��
%TaskNowLoc �ѹ滮��·���ĳ����������ڵ�λ��
%TaskNowDes Ϊ�ѹ滮��·���ĳ�����Ŀ�ĵ�ַ
%TaskSetNum2 �������ڹ滮��������Ϣ����һ�б�ʾ��ڱ�ţ���2�б�ʾ������
%SignOfTaskAssign �ѷ�������ı�־
%SignOfTaskAssign2 �ѷ��������ı�־2
%Task ��������
%ExpectedSteps Ԥ�ڲ��������ڿ��ƺ���������ʱ��Ĳ�������Ԥ�ڲ����ܱ����������¾�������ÿ�μ���ʱ��Ŀ��㳤��

%T���ո����Ĺ���ʱ��
%% �Ľ�
% ��ѡ���Ƿ�Ԥ��һ���̶ȵĳ��ȣ���20%
% ʱ�����޴�0.8�ۣ����ⳬʱ���⣬�ڶ���������
% 220506������������Shrink_Factor���0.8������,��ֵΪ0.8,�޸�Ϊ��Ԥ�ó�����������
% �������У�����ϴ�ʵ�ʼ���ʱ��������ڳ��ȣ����С�������ӣ�
% ���С��0.5�������ڳ��ȣ��������������ӡ�
%% ����
%load F:\MATLAB_File\PreMFN-DDM-HeatSec\MFN_Prediction_SetStep_Split\Fitting\CalTime_Prediction\PBS_CalTime\CalTimeModel_4PBS_r_70_c_38_SVM.mat %װ��svmԤ��ģ��
load(FittingModel.CalModel);
% AddTask = zeros(1,size(SignOfTaskAssign2,1)); %��Ҫ����ӵ�����
%% ���ҳ���������ӵ������Լ������������һ��Ŀ��㣨���������ڵ�λ�ã�
AddTask = [];
AddTaskLoc = zeros(0,2);
AddTaskDes = zeros(0,2);
NextTaskDes = zeros(length(TaskSetNum),2); %�Ѵ����������һ��Ŀ���
% ��������ӵ�����
for i = 1:size(EntrancePoints,1)
    Index_Undistributed = find(TaskGroup.TempGoalNum == 0); %δ��������񼯺�
    Index_Arrived = find(TaskGroup.ArriveTimes < SystemTime); %�ѵ�������񼯺�
    Index_Itsc = intersect(Index_Undistributed,Index_Arrived); %��Ӧ��ڵ����񼯺�
    Index_Itsc = intersect(Index_Itsc,Index_Task{i}); %����Ҫ��ļ��ϣ�����ڴ��Ķ���
    if ~isempty(Index_Itsc)
        %������Ϸǿգ�����ڷ���Ҫ������񣬿�������������伯����
        AddTask = [AddTask Index_Itsc(1)]; %��¼�������ı��
        AddTaskLoc = [AddTaskLoc ; TaskGroup.StartPoints(Index_Itsc(1),:)];
        AddTaskDes = [AddTaskDes ; TaskGroup.GoalPoints(Index_Itsc(1),:)];
    end
end
%�����������һ��Ŀ���
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
%% ����ExpectedSteps����Ԥ�����
%����Ŀ�ĵ�ľ��룬�����ж�
LengthToDes = sum(abs(TaskNowDes-TaskNowLoc),2);

%Ԥ��������������·������С���Ⱥ���󳤶�֮�䣬��Ҫ�жϣ�
%1����Щ������Ҫ����Ŀ�ĵ�
%2����Щ������Ҫ����
TaskNowNum2 = [];
TaskNowLoc2 = [];
TaskNowDes2 = [];
for i = 1:length(TaskSetNum)
    if LengthToDes(i) > ExpectedSteps %����Ŀ���Զ�ı���
        TaskNowNum2 = [TaskNowNum2 TaskSetNum(i)];
        TaskNowLoc2 = [TaskNowLoc2 ; RouteNow(ExpectedSteps+1,:,i)]; %�������λ��
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
%�޳���������񣨾�Ŀ������С��Ԥ�ھ��룩
x = find(PredicateTaskDes(:,1)==0);
PredicateTaskLoc(x,:) = [];
PredicateTaskDes(x,:) = [];
PredicateTaskNum(x) = [];

%AttrTimeΪ���Ŀ�����룬AttributionΪԤ�����������
AttrTime = max(sum(abs(PredicateTaskDes-PredicateTaskLoc),2));%���������
%Attribution = [Row,Column,length(PredicateTaskNum),AttrTime]; %�õ�Ԥ���������
Attribution = [length(PredicateTaskNum),AttrTime]; %�õ�Ԥ���������
%% ����ExpectedSteps����ǰ����������
StepList = 1:AttrTime; %��1�������룬������Ԥ��
PredTimeList = zeros(1,length(StepList));
%�Բ����б����Ԥ��
for i = 1:length(StepList)
    %Attribution(4) = StepList(i);
    Attribution(2) = StepList(i);
    AttritutionNormal = mapminmax('apply',Attribution',inputps);
    [Predict_1,error_1,dec_value1] = svmpredict(0,AttritutionNormal',model);
    Predict_Time1 = abs(mapminmax('reverse',Predict_1,outputps));
    PredTimeList(i) = Predict_Time1; %�õ��滮1�����������Ӧ�ļ���ʱ��
end

%ͨ���Ա�ExpectedTime�õ����ʵĲ���,�ҵ��������ɽ�����С��ExpectedTime�����ֵ
ExpectedTime = StepTime*ExpectedSteps; %Ԥ�����ʱ��
Para_StepNum = 1;
for i = 1:length(StepList)
    % ʱ�����޴�0.8�ۣ����ⳬʱ����
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
Para_StepNum = floor(Para_StepNum*Shrink_Factor); %����·������
Para_StepNum = max([Para_StepNum ExpectedSteps]); %��С����Ԥ�ڲ���

%% ��¼Ԥ��ʱ��,T2��ʾ��ģʱʱ��ά���ϵ���չ�������һ��������ɵ�ʱ��
filename1 = '.\PredicateTime_Mindistance.csv';
fid1 = fopen(filename1, 'a');
fprintf(fid1,'R ,%d ,C ,%d ,N ,%d ,PreTime ,%f ,T2 ,%d ,\n',Row,Column,size(PredicateTaskNum,2),ExpectedTime,Para_StepNum);
fclose(fid1);
end
