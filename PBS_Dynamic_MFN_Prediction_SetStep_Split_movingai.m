%% InitialAGVpath测试
% PBS版本
% 1、为PBS算法修改程序版本
% 2、无需设置准确的临时目标点，设置此次规划的路径长度即可
% 3、PBS规划的路径只在指定的窗口内消解冲突，窗口之外可能是有冲突路径
% 4、220324采用新的进出口模式，会多一行进出口，所以更新入口数量为2*(Row+1)
% 5、230521为movingai地图修改
% 实验版本
% 1、动态任务，加入任务产生时间、任务产生速率信息
% 2、为每个入口添加任务队列，记录每个任务到达的时间，或者通过时间大小判断是否到达
% 3、通过行走时间设定规划长度，凭此设定临时目标点，临时目标点通过矩形设置
% 4、通过模型给出针对不同的进车速率所对应的最佳步长
% 5、添加对前n次计算时间的判断，如果均大于当前周期，则增加预期步数
% 修复bug
% 当TaskSet在运行过程中缩减为1时，容易出现方向从纵向转换为横向，从而导致size(TaskSet,1)错误
clear all
%分拣窗格行列数
% Row = 5;
% Column = 4;
% MAP = CreateExperimentMAP(Row,Column);
% % Obstacle=-1, Target = 0, Robot=1, Space=2, Subgraph = 3
% %创建任务组,获得离开口位置
% V_prod = 2; %任务产生速率
 N_ex = 1000; %实验任务数，（1）设置为1000；（2）设置为10*（Row+Column）；选择一个合适的值
% [TaskGroup,EntrancePoints,ExitPoints] = ContinuousExperimentTaskSetCreat(Row,Column,MAP,V_prod,T_ex);
%% 多组任务实验
movingai_map = 'random-64-64-10';
% RHCR窗口长度
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
        %% 装载任务
        %load('F:\MATLAB_File\PreMFN-DDM-HeatSec\MFN_Prediction_SetStep_Split\TaskCreat\Task_5_4_220303\PreNet210712_r_5_c_4_v_0.25_TN_1000.mat')
        load(FileName);
        %设置装载模型文件的位置
        FittingModel.CalModel = strcat('F:\MATLAB_File\PrePBS-DDM-RHCR\PrePBS\Fitting\CalTime_Prediction\PBS_CalTime\CalTimeModel_4PBS_random-64-64-10_SVM.mat');
        FittingModel.OptModel = strcat('F:\MATLAB_File\PrePBS-DDM-RHCR\PrePBS\Fitting\ExpectedStep_Setting\PBS_Opt_Fit\OptModel_4PBS_random-64-64-10_SVM.mat');
        FittingModel.Y1Model = strcat('F:\MATLAB_File\PrePBS-DDM-RHCR\PrePBS\Fitting\ExpectedStep_Setting\PBS_Opt_Fit\Y1_random-64-64-10.mat');
        
        %记录任务完成的标志,0为在未分配，1为在运行第1段，-1表示完成
        SignTaskComplete = zeros(length(TaskGroup.ArriveTimes),1);
        %总路径集，记录最终路径
        Path.TotalSet = cell(length(TaskGroup.ArriveTimes),1);
        Path.StartTime = ones(length(TaskGroup.ArriveTimes),1);
        %车辆行进一格所需单位时间，即车辆行进速度,以s为时间，对应计算时间
        StepTime = 2;
        %系统时间
        SystemTime = 1;
        SystemTime_Last = 0; %上一次记录的系统时间，用于判断两次记录系统时间之间到达的任务
        %全体任务完成标志，用于判断程序结束
        SymbolofArrival = all(SignTaskComplete == -1,'all');
        
        %计算时间
        TotalCalTime = 0;
        PastCalTime = zeros(1,10);
        %预期实际前进步数
        ExpectedSteps = Get_RunStep_PBS_220301(MAP,EntrancePoints,ExitPoints,V_prod,StepTime,FittingModel);
        %ExpectedSteps = max(ExpectedSteps,10); %设置最小为2，以避免振荡
        %ExpectedSteps = 2; %暂时设置为2
        % 收缩因子，用于Para_StepNum的设置
        Shrink_Factor = 0.8;
        %% 初始化数据
        %初始化临时路径集
        SystemTime = ExpectedSteps * StepTime;
        if SystemTime < TaskGroup.ArriveTimes(1)+1
            SystemTime = TaskGroup.ArriveTimes(1)+1; %保证有任务
        end
        %此次计算到达的任务
        %Sign_Arrived = TaskGroup.ArriveTimes >= SystemTime_Last & TaskGroup.ArriveTimes < SystemTime;
        Index_Arrived = find(TaskGroup.ArriveTimes <= SystemTime);
        
        %按入口分配任务
%        Index_Task = cell(size(EntrancePoints,1),1);
         Index_1 = zeros(1,0);
%         for i = 1:size(EntrancePoints,1)
%             %将任务整理分为不同入口
%             Index_Task{i} = find(all(TaskGroup.StartPoints == EntrancePoints(i,:),2));
%             %第一次的任务，在各个入口中，小于SystemTime的第一个任务
%             Index_1 = [Index_1 min(intersect(Index_Arrived,Index_Task{i}))]; %符合入口要求和到达时间要求的最小任务索引
%         end
        %随机分配任务
        Index_Task = Dividing_Task_Randomly(1:length(TaskGroup.ArriveTimes), size(EntrancePoints,1));
        for i = 1:size(EntrancePoints,1)
            Index_1 = [Index_1 min(intersect(Index_Arrived,Index_Task{i}))]; %符合入口要求和到达时间要求的最小任务索引
        end
        Path.StartTime(Index_1) = SystemTime;
        TaskSet = [TaskGroup.StartPoints(Index_1,:) TaskGroup.GoalPoints(Index_1,:)];
        %任务集中的任务与任务分组中的任务对应关系，任务到达目标点及到达离开点时要更新完成状态
        TaskSetNum = Index_1';
        %TaskSetNum2 = [(1:2*Row)' ones(2*Row,1)]; %第一列表示入口编号，第2列表示任务编号（该入口的第几个任务）
        %临时路径集
        PathSet = cell(size(TaskSet,1),1);
        %临时任务完成记录
        TempMissionComplete = zeros(length(PathSet),1); %任务完成记录，1完成第一段，2完成第二段
        for i = 1:size(TaskSet,1)
            PathSet{i} = TaskSet(i,1:2);
        end
        CurrentPointLocations = TaskSet(:,1:2);
        GoalPointLocations = TaskSet(:,3:4);
        SignTaskComplete(Index_1) = 1; % 0表示未分配，1表示已分配在进行第一阶段，2表示已分配在进行第二阶段，-1表示任务完成
        CurrTempGoal = TaskSet(:,3:4); %首次计算，CurrTempGoal预设的目标点和GoalPointLocations一样
        IC_CurrTempGoal = 0;
        PredStepNum = 1000; %初始值，用于第一次规划全部路径
        %% 路径规划过程
        while SymbolofArrival ~= 1
           %% 判断过去十次计算时间是否均超过周期长度，
                Sign_CalTime = all(PastCalTime > ExpectedSteps*StepTime);
                if Sign_CalTime
                    % 如果过去十次的计算时间均超过周期长度，则增加计算时间
                    ExpectedSteps = ExpectedSteps + 1;
                    % 更换新的步长后，清除已记录的时间
                    PastCalTime = zeros(1,length(PastCalTime));
                    PredStepNum = ExpectedSteps;
                end
           %% 
            IC_CurrTempGoal = IC_CurrTempGoal+1; %循环计数
            CurrentPointLocations = zeros(length(PathSet),2);
            %更新现在位置集合
            for i = 1:length(PathSet)
                if ~isempty(PathSet{i})
                    %路径非空，已经行驶一段时间，现在位置为路径中的某个位置
                    CurrentPointLocations(i,:) = PathSet{i}((SystemTime-Path.StartTime(TaskSetNum(i)))/StepTime+1,:);
                else
                    %路径为空，说明刚开始分配，现在位置为起点
                    CurrentPointLocations(i,:) = TaskSet(i,1:2);
                end
            end
            GoalPointLocations = TaskSet(:,3:4);
            
            %设置PBS临时目标点
            TempMissionComplete = Judgment_Completion2(TaskGroup,TaskSetNum,PathSet);
            CurrTempGoal = zeros(length(TaskSetNum),4);
            for i = 1:length(TaskSetNum)
                if TempMissionComplete(i) == 0
                    % 未到达第一个目标点
                    CurrTempGoal(i,1:2) = TaskGroup.GoalPoints(TaskSetNum(i),:);
                    CurrTempGoal(i,3:4) = TaskGroup.ExitPoints(TaskSetNum(i),:);
                else
                    % 到达第一个目标
                    CurrTempGoal(i,1:2) = TaskGroup.ExitPoints(TaskSetNum(i),:);
                    CurrTempGoal(i,3:4) = [0 0];
                end
            end

            %求解任务，返回路径和计算时间，采用CurrTempGoal做为目标点
            %[RouteNow,RouteNowLength,CalTime,FinalTime] = NetStream_PTS_SEMV_210628(MAP,TaskSetNum,CurrentPointLocations,...
            %    CurrTempGoal,EntrancePoints,ExitPoints);
            [RouteNow,CalTime,Sign_Succ,Path_Length_Set] = Solved_by_C(MAP,PredStepNum,CurrentPointLocations,CurrTempGoal,ExpectedSteps);
            
            TotalCalTime = TotalCalTime + CalTime;
            %记录所预测的计算时间，用于后期分析错误
            Record_CalTime(MAP,TaskSetNum,ExpectedSteps,PredStepNum,CalTime);
            PastCalTime(2:end) = PastCalTime(1:end-1);
            PastCalTime(1) = CalTime;
            %判断实际计算时间与所设置时间差距，补上因少预估时间而需要多停留的步数，表示为系统时间后推,每一步为StepTime
            if (CalTime > ExpectedSteps*StepTime) && (ExpectedSteps*StepTime ~= 0)
                AddStep = ceil(CalTime/StepTime-ExpectedSteps); %计算时间除以每步时间，得到步数，减去预期步数，得到超出的步数（等待时间）
                SystemTime_Last = SystemTime;
                SystemTime = SystemTime + AddStep*StepTime;
                %补充停留时间，在此期间，AGV位于原地不动
                for i = 1:length(PathSet)
                    for j = 1:AddStep
                        PathSet{i}(end+1,:) = PathSet{i}(end,:);
                    end
                end
            end
            %预估临时目标点的步数
            [PredStepNum,Shrink_Factor] = SetStepNum_PBS_by_Predication3(size(MAP,1),size(MAP,2),StepTime,TaskSetNum',RouteNow,CurrentPointLocations,...
                GoalPointLocations,TaskGroup,Index_Task,EntrancePoints,SignTaskComplete,ExpectedSteps,SystemTime,FittingModel,CalTime,Shrink_Factor);
            
            %记录依照ExpectedSteps所设定步数的路径,并增加系统时间
            [PathSet,SystemTime] = RecordPath_PBS(RouteNow,Path_Length_Set,SystemTime,StepTime,ExpectedSteps,TaskGroup,TaskSetNum,...
                SignTaskComplete,PathSet,CurrTempGoal);
            
            for i = 1:length(PathSet)
                CP_I = (SystemTime-Path.StartTime(TaskSetNum(i)))/StepTime+1;
                CP_I = min(CP_I,size(PathSet{i},1)); %如果在此时SystemTime之前到达，应该
                CurrentPointLocations(i,:) = PathSet{i}(CP_I,:);
            end
            %判断是否所有AGV均已到达任务点
            %MissionComplete = zeros(length(TaskSetNum),1); %重新设置MissionComplete的长度
            TempMissionComplete = Judgment_Completion2(TaskGroup,TaskSetNum,PathSet);
            %    SignTaskComplete(TaskSetNum((all(CurrentPointLocations == ExitPoints(TaskSetNum,:),2)))) = -1;
            %% 对到达目的地的任务进行分类判断，执行完第一阶段的则更换目的地点，执行完第二阶段的从任务中删除
            i = 1;
            while i <= length(TempMissionComplete)
                if TempMissionComplete(i) == 1
                    SignTaskComplete(TaskSetNum(i)) = 2;
                    %任务完成一半，不改变任务编号，但需要记录已有路径
                    GoalPointLocations(i,:) = TaskGroup.ExitPoints(TaskSetNum(i),:);
                    %切换至下一个临时任务
                    TaskSet(i,:) = [TaskSet(i,3:4) GoalPointLocations(i,:)];
                    %序号加1
                    i = i+1;
                elseif TempMissionComplete(i) == 2
                    %此时已完成任务，应当清除此任务以及各种记录
                    SignTaskComplete(TaskSetNum(i)) = -1;
                    TaskSet(i,:) = [];%直接剔除会影响其余参数！！！
                    %保存路径
                    Path.TotalSet{TaskSetNum(i)} = DeleteRedundantPath(PathSet{i});
                    PathSet(i) = [];
                    GoalPointLocations(i,:) = [];
                    CurrentPointLocations(i,:) = [];
                    %剔除正在执行任务的编号
                    TaskSetNum(i) = [];
                    %序号不加并剔除完成标志
                    TempMissionComplete(i) = [];
                    i;
                else
                    i = i+1;
                end
            end
            %检测是否完成所有任务
            SymbolofArrival = all(SignTaskComplete == -1,'all');
            if SymbolofArrival == 1
                break;
            end
            %     %检测路径连续性
            %     if TestPathCoherence(PathSet) == 0
            %             pause;
            %     end
            %% 添加新的任务至地图中
            if ~isempty(TaskSetNum) %任务为空时不需要更新任务集
                for i = 1:length(PathSet)
                    CP_I = (SystemTime-Path.StartTime(TaskSetNum(i)))/StepTime+1;
                    CP_I = min(CP_I,size(PathSet{i},1)); %如果在此时SystemTime之前到达，应该
                    CurrentPointLocations(i,:) = PathSet{i}(CP_I,:);
                    %CurrentPointLocations(i,:) = PathSet{i}((SystemTime-Path.StartTime(TaskSetNum(i)))/StepTime+1,:);
                end
            end
            for i = 1:size(EntrancePoints,1)%采用新的进出口模式，会多一行进出口，所以更新入口数量为2*(Row+1),或size(EntrancePoints,1)
                Index_Sys_i = Index_Task{i}(TaskGroup.ArriveTimes(Index_Task{i}) <= SystemTime); %属于第i个入口，且以过系统时间的任务索引
                Index_Select_i = Index_Sys_i(SignTaskComplete(Index_Sys_i) == 0); %所选择的已到达，未分配的任务索引
                if ~isempty(Index_Select_i) && ~any(all(TaskGroup.StartPoints(Index_Select_i(1),:) == CurrentPointLocations,2)) %此处应该使用Index_Select_i(1)
                    %SignTaskComplete(Index_Select_i(1)) = 1; %此处不应该用1
                    TaskSet(end+1,:) = [TaskGroup.StartPoints(Index_Select_i(1),:) TaskGroup.GoalPoints(Index_Select_i(1),:)];
                    GoalPointLocations(end+1,:) = TaskSet(end,3:4);
                    TaskSetNum(end+1) = Index_Select_i(1);
                    SignTaskComplete(TaskSetNum(end)) = 1; %分配任务，将任务标志置为1
                    TempMissionComplete(end+1) = 0; %任务目标点的完成状态
                    Path.StartTime(Index_Select_i(1)) = SystemTime;
                    %产生新路径
                    PathSet{end+1} = TaskGroup.StartPoints(Index_Select_i(1),:);
                end
            end
            %% 整理内存,可能原因是持久变量导致内存持续增加，但无法找到是在哪个函数中定义的持久变量
            save ('.\Memory\TemporyMemory.mat');
            clear functions
            load ('.\Memory\TemporyMemory.mat');
        end
        %% 计算路径结束时间
        Path.EndTime = [];
        for i = 1:length(Path.StartTime)
            Path.EndTime(i) = Path.StartTime(i) + size(Path.TotalSet{i},1)-1;
        end
        %% 计算路径结束时间与路径长度
        Path.Length = zeros(length(Path.StartTime),1);
        for i = 1:length(Path.StartTime)
            Path.Length(i) = size(Path.TotalSet{i},1)-1;
            Path.EndTime(i) = Path.StartTime(i) + Path.Length(i)*StepTime;
        end
        %统计数据
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
        
        %% 保存多组数据
        TotalDistance_Set(Task_DirName_Num,Index_File) = TotalDistance;
        Makespan_Set(Task_DirName_Num,Index_File) = Makespan;
        TotalCalTime_Set(Task_DirName_Num,Index_File) = TotalCalTime;
        SuccSign_Set(Task_DirName_Num,Index_File) = 1;
    end
end
%% 保存组实验结果
SaveFileName = sprintf('Group_%s_TN_%d_PBS.mat',movingai_map,TN_ex);
SaveDirName = strcat('.\MovingAI\Data\',movingai_map,'\PrePBS\',...
    'GroupExp\',...
    num2str(size(MAP,1)),'_',num2str(size(MAP,2)),'_',...
    num2str(N_ex),'',...
    '_230522\');
VarName = strcat(SaveDirName,SaveFileName);
save(VarName,'TotalDistance_Set','Makespan_Set','TotalCalTime_Set','SuccSign_Set');
datestr(now)

%% 收集数据（用于实验中断的情况），一般运行时注释掉
% MaxGroupNum = 10;
% TotalDistance_Set = zeros(10,MaxGroupNum);
% Makespan_Set = zeros(10,MaxGroupNum);
% TotalCalTime_Set = zeros(10,MaxGroupNum);
% SuccSign_Set = zeros(10,MaxGroupNum);
% for Task_DirName_Num = 1:MaxGroupNum
%     Task_DirName = strcat('.\TaskCreat\Task_5_4_Group_220322\Group_',num2str(Task_DirName_Num),'\');
%     Index_FileName = 0.25:0.25:2.5;
%     for Index_File = 1:length(Index_FileName)
%         % 装载任务
%         FileName = strcat(Task_DirName,'PreNet220303_r_5_c_4_v_',num2str(Index_FileName(Index_File),'%.2f'),'_TN_1000.mat');
%         load(FileName);
% 
%         % 构建需要装载的任务文件路径
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
%         % 保存多组数据
%         TotalDistance_Set(Task_DirName_Num,Index_File) = TotalDistance;
%         Makespan_Set(Task_DirName_Num,Index_File) = Makespan;
%         TotalCalTime_Set(Task_DirName_Num,Index_File) = TotalCalTime;
%         SuccSign_Set(Task_DirName_Num,Index_File) = 1;
%     end
% end