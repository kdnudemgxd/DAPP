%% InitialAGVpath����
% PBS�汾
% 1��ΪPBS�㷨�޸ĳ���汾
% 2����������׼ȷ����ʱĿ��㣬���ô˴ι滮��·�����ȼ���
% 3��PBS�滮��·��ֻ��ָ���Ĵ����������ͻ������֮��������г�ͻ·��
% 4��220324�����µĽ�����ģʽ�����һ�н����ڣ����Ը����������Ϊ2*(Row+1)
% 5��230521Ϊmovingai��ͼ�޸�
% ʵ��汾
% 1����̬���񣬼����������ʱ�䡢�������������Ϣ
% 2��Ϊÿ��������������У���¼ÿ�����񵽴��ʱ�䣬����ͨ��ʱ���С�ж��Ƿ񵽴�
% 3��ͨ������ʱ���趨�滮���ȣ�ƾ���趨��ʱĿ��㣬��ʱĿ���ͨ����������
% 4��ͨ��ģ�͸�����Բ�ͬ�Ľ�����������Ӧ����Ѳ���
% 5����Ӷ�ǰn�μ���ʱ����жϣ���������ڵ�ǰ���ڣ�������Ԥ�ڲ���
% �޸�bug
% ��TaskSet�����й���������Ϊ1ʱ�����׳��ַ��������ת��Ϊ���򣬴Ӷ�����size(TaskSet,1)����
clear all
%�ּ𴰸�������
% Row = 5;
% Column = 4;
% MAP = CreateExperimentMAP(Row,Column);
% % Obstacle=-1, Target = 0, Robot=1, Space=2, Subgraph = 3
% %����������,����뿪��λ��
% V_prod = 2; %�����������
 N_ex = 1000; %ʵ������������1������Ϊ1000����2������Ϊ10*��Row+Column����ѡ��һ�����ʵ�ֵ
% [TaskGroup,EntrancePoints,ExitPoints] = ContinuousExperimentTaskSetCreat(Row,Column,MAP,V_prod,T_ex);
%% ��������ʵ��
movingai_map = 'random-64-64-10';
% RHCR���ڳ���
MaxGroupNum = 10;

TotalDistance_Set = zeros(10,MaxGroupNum);
Makespan_Set = zeros(10,MaxGroupNum);
TotalCalTime_Set = zeros(10,MaxGroupNum);
SuccSign_Set = zeros(10,MaxGroupNum);

for Task_DirName_Num = 1:MaxGroupNum
    Task_DirName = strcat('.\MovingAI\Task_Creat_movingai\Task_random-64-64-10_Group_230522\Group_',num2str(Task_DirName_Num),'\');
    Index_FileName = 1:10;
    for Index_File = 1:length(Index_FileName)
        %GroupName = strcat('F:\MATLAB_File\PreMFN-DDM-HeatSec\MFN_Prediction_SetStep_Split\TaskCreat\Task_5_4_220303\PreNet220303_r_5_c_4_v_',FileName(Index_File),'_TN_1000.mat');
        FileName = strcat(Task_DirName,'PrePBS_random-64-64-10_NE_v_',num2str(Index_FileName(Index_File),'%.2f'),'_TN_',num2str(N_ex),'.mat');
        %% װ������
        %load('F:\MATLAB_File\PreMFN-DDM-HeatSec\MFN_Prediction_SetStep_Split\TaskCreat\Task_5_4_220303\PreNet210712_r_5_c_4_v_0.25_TN_1000.mat')
        load(FileName);
        %����װ��ģ���ļ���λ��
        FittingModel.CalModel = strcat('F:\MATLAB_File\PrePBS-DDM-RHCR\PrePBS\Fitting\CalTime_Prediction\PBS_CalTime\CalTimeModel_4PBS_random-64-64-10_SVM.mat');
        FittingModel.OptModel = strcat('F:\MATLAB_File\PrePBS-DDM-RHCR\PrePBS\Fitting\ExpectedStep_Setting\PBS_Opt_Fit\OptModel_4PBS_random-64-64-10_SVM.mat');
        FittingModel.Y1Model = strcat('F:\MATLAB_File\PrePBS-DDM-RHCR\PrePBS\Fitting\ExpectedStep_Setting\PBS_Opt_Fit\Y1_random-64-64-10.mat');
        
        %��¼������ɵı�־,0Ϊ��δ���䣬1Ϊ�����е�1�Σ�-1��ʾ���
        SignTaskComplete = zeros(length(TaskGroup.ArriveTimes),1);
        %��·��������¼����·��
        Path.TotalSet = cell(length(TaskGroup.ArriveTimes),1);
        Path.StartTime = ones(length(TaskGroup.ArriveTimes),1);
        %�����н�һ�����赥λʱ�䣬�������н��ٶ�,��sΪʱ�䣬��Ӧ����ʱ��
        StepTime = 2;
        %ϵͳʱ��
        SystemTime = 1;
        SystemTime_Last = 0; %��һ�μ�¼��ϵͳʱ�䣬�����ж����μ�¼ϵͳʱ��֮�䵽�������
        %ȫ��������ɱ�־�������жϳ������
        SymbolofArrival = all(SignTaskComplete == -1,'all');
        
        %����ʱ��
        TotalCalTime = 0;
        PastCalTime = zeros(1,10);
        %Ԥ��ʵ��ǰ������
        ExpectedSteps = Get_RunStep_PBS_220301(MAP,EntrancePoints,ExitPoints,V_prod,StepTime,FittingModel);
        %ExpectedSteps = max(ExpectedSteps,10); %������СΪ2���Ա�����
        %ExpectedSteps = 2; %��ʱ����Ϊ2
        % �������ӣ�����Para_StepNum������
        Shrink_Factor = 0.8;
        %% ��ʼ������
        %��ʼ����ʱ·����
        SystemTime = ExpectedSteps * StepTime;
        if SystemTime < TaskGroup.ArriveTimes(1)+1
            SystemTime = TaskGroup.ArriveTimes(1)+1; %��֤������
        end
        %�˴μ��㵽�������
        %Sign_Arrived = TaskGroup.ArriveTimes >= SystemTime_Last & TaskGroup.ArriveTimes < SystemTime;
        Index_Arrived = find(TaskGroup.ArriveTimes <= SystemTime);
        
        %����ڷ�������
%        Index_Task = cell(size(EntrancePoints,1),1);
         Index_1 = zeros(1,0);
%         for i = 1:size(EntrancePoints,1)
%             %�����������Ϊ��ͬ���
%             Index_Task{i} = find(all(TaskGroup.StartPoints == EntrancePoints(i,:),2));
%             %��һ�ε������ڸ�������У�С��SystemTime�ĵ�һ������
%             Index_1 = [Index_1 min(intersect(Index_Arrived,Index_Task{i}))]; %�������Ҫ��͵���ʱ��Ҫ�����С��������
%         end
        %�����������
        Index_Task = Dividing_Task_Randomly(1:length(TaskGroup.ArriveTimes), size(EntrancePoints,1));
        for i = 1:size(EntrancePoints,1)
            Index_1 = [Index_1 min(intersect(Index_Arrived,Index_Task{i}))]; %�������Ҫ��͵���ʱ��Ҫ�����С��������
        end
        Path.StartTime(Index_1) = SystemTime;
        TaskSet = [TaskGroup.StartPoints(Index_1,:) TaskGroup.GoalPoints(Index_1,:)];
        %�����е���������������е������Ӧ��ϵ�����񵽴�Ŀ��㼰�����뿪��ʱҪ�������״̬
        TaskSetNum = Index_1';
        %TaskSetNum2 = [(1:2*Row)' ones(2*Row,1)]; %��һ�б�ʾ��ڱ�ţ���2�б�ʾ�����ţ�����ڵĵڼ�������
        %��ʱ·����
        PathSet = cell(size(TaskSet,1),1);
        %��ʱ������ɼ�¼
        TempMissionComplete = zeros(length(PathSet),1); %������ɼ�¼��1��ɵ�һ�Σ�2��ɵڶ���
        for i = 1:size(TaskSet,1)
            PathSet{i} = TaskSet(i,1:2);
        end
        CurrentPointLocations = TaskSet(:,1:2);
        GoalPointLocations = TaskSet(:,3:4);
        SignTaskComplete(Index_1) = 1; % 0��ʾδ���䣬1��ʾ�ѷ����ڽ��е�һ�׶Σ�2��ʾ�ѷ����ڽ��еڶ��׶Σ�-1��ʾ�������
        CurrTempGoal = TaskSet(:,3:4); %�״μ��㣬CurrTempGoalԤ���Ŀ����GoalPointLocationsһ��
        IC_CurrTempGoal = 0;
        PredStepNum = 1000; %��ʼֵ�����ڵ�һ�ι滮ȫ��·��
        %% ·���滮����
        while SymbolofArrival ~= 1
           %% �жϹ�ȥʮ�μ���ʱ���Ƿ���������ڳ��ȣ�
                Sign_CalTime = all(PastCalTime > ExpectedSteps*StepTime);
                if Sign_CalTime
                    % �����ȥʮ�εļ���ʱ����������ڳ��ȣ������Ӽ���ʱ��
                    ExpectedSteps = ExpectedSteps + 1;
                    % �����µĲ���������Ѽ�¼��ʱ��
                    PastCalTime = zeros(1,length(PastCalTime));
                    PredStepNum = ExpectedSteps;
                end
           %% 
            IC_CurrTempGoal = IC_CurrTempGoal+1; %ѭ������
            CurrentPointLocations = zeros(length(PathSet),2);
            %��������λ�ü���
            for i = 1:length(PathSet)
                if ~isempty(PathSet{i})
                    %·���ǿգ��Ѿ���ʻһ��ʱ�䣬����λ��Ϊ·���е�ĳ��λ��
                    CurrentPointLocations(i,:) = PathSet{i}((SystemTime-Path.StartTime(TaskSetNum(i)))/StepTime+1,:);
                else
                    %·��Ϊ�գ�˵���տ�ʼ���䣬����λ��Ϊ���
                    CurrentPointLocations(i,:) = TaskSet(i,1:2);
                end
            end
            GoalPointLocations = TaskSet(:,3:4);
            
            %����PBS��ʱĿ���
            TempMissionComplete = Judgment_Completion2(TaskGroup,TaskSetNum,PathSet);
            CurrTempGoal = zeros(length(TaskSetNum),4);
            for i = 1:length(TaskSetNum)
                if TempMissionComplete(i) == 0
                    % δ�����һ��Ŀ���
                    CurrTempGoal(i,1:2) = TaskGroup.GoalPoints(TaskSetNum(i),:);
                    CurrTempGoal(i,3:4) = TaskGroup.ExitPoints(TaskSetNum(i),:);
                else
                    % �����һ��Ŀ��
                    CurrTempGoal(i,1:2) = TaskGroup.ExitPoints(TaskSetNum(i),:);
                    CurrTempGoal(i,3:4) = [0 0];
                end
            end

            %������񣬷���·���ͼ���ʱ�䣬����CurrTempGoal��ΪĿ���
            %[RouteNow,RouteNowLength,CalTime,FinalTime] = NetStream_PTS_SEMV_210628(MAP,TaskSetNum,CurrentPointLocations,...
            %    CurrTempGoal,EntrancePoints,ExitPoints);
            [RouteNow,CalTime,Sign_Succ,Path_Length_Set] = Solved_by_C(MAP,PredStepNum,CurrentPointLocations,CurrTempGoal,ExpectedSteps);
            
            TotalCalTime = TotalCalTime + CalTime;
            %��¼��Ԥ��ļ���ʱ�䣬���ں��ڷ�������
            Record_CalTime(MAP,TaskSetNum,ExpectedSteps,PredStepNum,CalTime);
            PastCalTime(2:end) = PastCalTime(1:end-1);
            PastCalTime(1) = CalTime;
            %�ж�ʵ�ʼ���ʱ����������ʱ���࣬��������Ԥ��ʱ�����Ҫ��ͣ���Ĳ�������ʾΪϵͳʱ�����,ÿһ��ΪStepTime
            if (CalTime > ExpectedSteps*StepTime) && (ExpectedSteps*StepTime ~= 0)
                AddStep = ceil(CalTime/StepTime-ExpectedSteps); %����ʱ�����ÿ��ʱ�䣬�õ���������ȥԤ�ڲ������õ������Ĳ������ȴ�ʱ�䣩
                SystemTime_Last = SystemTime;
                SystemTime = SystemTime + AddStep*StepTime;
                %����ͣ��ʱ�䣬�ڴ��ڼ䣬AGVλ��ԭ�ز���
                for i = 1:length(PathSet)
                    for j = 1:AddStep
                        PathSet{i}(end+1,:) = PathSet{i}(end,:);
                    end
                end
            end
            %Ԥ����ʱĿ���Ĳ���
            [PredStepNum,Shrink_Factor] = SetStepNum_PBS_by_Predication3(size(MAP,1),size(MAP,2),StepTime,TaskSetNum',RouteNow,CurrentPointLocations,...
                GoalPointLocations,TaskGroup,Index_Task,EntrancePoints,SignTaskComplete,ExpectedSteps,SystemTime,FittingModel,CalTime,Shrink_Factor);
            
            %��¼����ExpectedSteps���趨������·��,������ϵͳʱ��
            [PathSet,SystemTime] = RecordPath_PBS(RouteNow,Path_Length_Set,SystemTime,StepTime,ExpectedSteps,TaskGroup,TaskSetNum,...
                SignTaskComplete,PathSet,CurrTempGoal);
            
            for i = 1:length(PathSet)
                CP_I = (SystemTime-Path.StartTime(TaskSetNum(i)))/StepTime+1;
                CP_I = min(CP_I,size(PathSet{i},1)); %����ڴ�ʱSystemTime֮ǰ���Ӧ��
                CurrentPointLocations(i,:) = PathSet{i}(CP_I,:);
            end
            %�ж��Ƿ�����AGV���ѵ��������
            %MissionComplete = zeros(length(TaskSetNum),1); %��������MissionComplete�ĳ���
            TempMissionComplete = Judgment_Completion2(TaskGroup,TaskSetNum,PathSet);
            %    SignTaskComplete(TaskSetNum((all(CurrentPointLocations == ExitPoints(TaskSetNum,:),2)))) = -1;
            %% �Ե���Ŀ�ĵص�������з����жϣ�ִ�����һ�׶ε������Ŀ�ĵص㣬ִ����ڶ��׶εĴ�������ɾ��
            i = 1;
            while i <= length(TempMissionComplete)
                if TempMissionComplete(i) == 1
                    SignTaskComplete(TaskSetNum(i)) = 2;
                    %�������һ�룬���ı������ţ�����Ҫ��¼����·��
                    GoalPointLocations(i,:) = TaskGroup.ExitPoints(TaskSetNum(i),:);
                    %�л�����һ����ʱ����
                    TaskSet(i,:) = [TaskSet(i,3:4) GoalPointLocations(i,:)];
                    %��ż�1
                    i = i+1;
                elseif TempMissionComplete(i) == 2
                    %��ʱ���������Ӧ������������Լ����ּ�¼
                    SignTaskComplete(TaskSetNum(i)) = -1;
                    TaskSet(i,:) = [];%ֱ���޳���Ӱ���������������
                    %����·��
                    Path.TotalSet{TaskSetNum(i)} = DeleteRedundantPath(PathSet{i});
                    PathSet(i) = [];
                    GoalPointLocations(i,:) = [];
                    CurrentPointLocations(i,:) = [];
                    %�޳�����ִ������ı��
                    TaskSetNum(i) = [];
                    %��Ų��Ӳ��޳���ɱ�־
                    TempMissionComplete(i) = [];
                    i;
                else
                    i = i+1;
                end
            end
            %����Ƿ������������
            SymbolofArrival = all(SignTaskComplete == -1,'all');
            if SymbolofArrival == 1
                break;
            end
            %     %���·��������
            %     if TestPathCoherence(PathSet) == 0
            %             pause;
            %     end
            %% ����µ���������ͼ��
            if ~isempty(TaskSetNum) %����Ϊ��ʱ����Ҫ��������
                for i = 1:length(PathSet)
                    CP_I = (SystemTime-Path.StartTime(TaskSetNum(i)))/StepTime+1;
                    CP_I = min(CP_I,size(PathSet{i},1)); %����ڴ�ʱSystemTime֮ǰ���Ӧ��
                    CurrentPointLocations(i,:) = PathSet{i}(CP_I,:);
                    %CurrentPointLocations(i,:) = PathSet{i}((SystemTime-Path.StartTime(TaskSetNum(i)))/StepTime+1,:);
                end
            end
            for i = 1:size(EntrancePoints,1)%�����µĽ�����ģʽ�����һ�н����ڣ����Ը����������Ϊ2*(Row+1),��size(EntrancePoints,1)
                Index_Sys_i = Index_Task{i}(TaskGroup.ArriveTimes(Index_Task{i}) <= SystemTime); %���ڵ�i����ڣ����Թ�ϵͳʱ�����������
                Index_Select_i = Index_Sys_i(SignTaskComplete(Index_Sys_i) == 0); %��ѡ����ѵ��δ�������������
                if ~isempty(Index_Select_i) && ~any(all(TaskGroup.StartPoints(Index_Select_i(1),:) == CurrentPointLocations,2)) %�˴�Ӧ��ʹ��Index_Select_i(1)
                    %SignTaskComplete(Index_Select_i(1)) = 1; %�˴���Ӧ����1
                    TaskSet(end+1,:) = [TaskGroup.StartPoints(Index_Select_i(1),:) TaskGroup.GoalPoints(Index_Select_i(1),:)];
                    GoalPointLocations(end+1,:) = TaskSet(end,3:4);
                    TaskSetNum(end+1) = Index_Select_i(1);
                    SignTaskComplete(TaskSetNum(end)) = 1; %�������񣬽������־��Ϊ1
                    TempMissionComplete(end+1) = 0; %����Ŀ�������״̬
                    Path.StartTime(Index_Select_i(1)) = SystemTime;
                    %������·��
                    PathSet{end+1} = TaskGroup.StartPoints(Index_Select_i(1),:);
                end
            end
            %% �����ڴ�,����ԭ���ǳ־ñ��������ڴ�������ӣ����޷��ҵ������ĸ������ж���ĳ־ñ���
            save ('.\Memory\TemporyMemory.mat');
            clear functions
            load ('.\Memory\TemporyMemory.mat');
        end
        %% ����·������ʱ��
        Path.EndTime = [];
        for i = 1:length(Path.StartTime)
            Path.EndTime(i) = Path.StartTime(i) + size(Path.TotalSet{i},1)-1;
        end
        %% ����·������ʱ����·������
        Path.Length = zeros(length(Path.StartTime),1);
        for i = 1:length(Path.StartTime)
            Path.Length(i) = size(Path.TotalSet{i},1)-1;
            Path.EndTime(i) = Path.StartTime(i) + Path.Length(i)*StepTime;
        end
        %ͳ������
        TotalCalTime;
        TotalDistance = sum(Path.Length);
        Makespan = max(Path.EndTime);
        TotalPath = Path;
        %% save
        % MatName = sprintf('r_%d_c_%d_v_%0.2f_TN_%d_PreNet_FixLen_PBS.mat',size(MAP,1),size(MAP,2),V_prod,TN_ex);
        % MatName = strcat('.\Data\PBSData\70_38_Pre_220308\',MatName);
        % save(MatName,'TotalDistance','Makespan','TotalPath','TotalCalTime','TaskGroup');
        %% save
        SaveFileName = sprintf('r_%d_c_%d_v_%0.2f_TN_%d_PreNet_FixLen_PBS_MovingAI.mat',size(MAP,1),size(MAP,2),V_prod,TN_ex);
        SaveDirName = strcat('.\MovingAI\Data\',movingai_map,'\PrePBS\',...
            'GroupExp\',...
            num2str(size(MAP,1)),'_',num2str(size(MAP,2)),'_',...
            num2str(N_ex),'',...
            '_230522\',...
            'Group_',num2str(Task_DirName_Num),'\');
        if exist(SaveDirName) ~= 7
            mkdir(SaveDirName);
        end
        VarName = strcat(SaveDirName,SaveFileName);
        save(VarName,'TotalDistance','Makespan','TotalPath','TotalCalTime','TaskGroup','ExpectedSteps');
        
        %% �����������
        TotalDistance_Set(Task_DirName_Num,Index_File) = TotalDistance;
        Makespan_Set(Task_DirName_Num,Index_File) = Makespan;
        TotalCalTime_Set(Task_DirName_Num,Index_File) = TotalCalTime;
        SuccSign_Set(Task_DirName_Num,Index_File) = 1;
    end
end
%% ������ʵ����
SaveFileName = sprintf('Group_%s_TN_%d_PBS.mat',movingai_map,TN_ex);
SaveDirName = strcat('.\MovingAI\Data\',movingai_map,'\PrePBS\',...
    'GroupExp\',...
    num2str(size(MAP,1)),'_',num2str(size(MAP,2)),'_',...
    num2str(N_ex),'',...
    '_230522\');
VarName = strcat(SaveDirName,SaveFileName);
save(VarName,'TotalDistance_Set','Makespan_Set','TotalCalTime_Set','SuccSign_Set');
datestr(now)

%% �ռ����ݣ�����ʵ���жϵ��������һ������ʱע�͵�
% MaxGroupNum = 10;
% TotalDistance_Set = zeros(10,MaxGroupNum);
% Makespan_Set = zeros(10,MaxGroupNum);
% TotalCalTime_Set = zeros(10,MaxGroupNum);
% SuccSign_Set = zeros(10,MaxGroupNum);
% for Task_DirName_Num = 1:MaxGroupNum
%     Task_DirName = strcat('.\TaskCreat\Task_5_4_Group_220322\Group_',num2str(Task_DirName_Num),'\');
%     Index_FileName = 0.25:0.25:2.5;
%     for Index_File = 1:length(Index_FileName)
%         % װ������
%         FileName = strcat(Task_DirName,'PreNet220303_r_5_c_4_v_',num2str(Index_FileName(Index_File),'%.2f'),'_TN_1000.mat');
%         load(FileName);
% 
%         % ������Ҫװ�ص������ļ�·��
%         SaveFileName = sprintf('r_%d_c_%d_v_%0.2f_TN_%d_PreNet_FixLen_PBS.mat',size(MAP,1),size(MAP,2),V_prod,TN_ex);
%         SaveDirName = strcat('.\Data\PBSData\',...
%             'GroupExp\',...
%             num2str(size(MAP,1)),'_',num2str(size(MAP,2)),'_',...
%             num2str(N_ex),'',...
%             '_220322\',...
%             'Group_',num2str(Task_DirName_Num),'\');
%         if exist(SaveDirName) ~= 7
%             mkdir(SaveDirName);
%         end
%         VarName = strcat(SaveDirName,SaveFileName);
%         load(VarName);
% 
%         % �����������
%         TotalDistance_Set(Task_DirName_Num,Index_File) = TotalDistance;
%         Makespan_Set(Task_DirName_Num,Index_File) = Makespan;
%         TotalCalTime_Set(Task_DirName_Num,Index_File) = TotalCalTime;
%         SuccSign_Set(Task_DirName_Num,Index_File) = 1;
%     end
% end