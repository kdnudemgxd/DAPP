%% 通过各种随机任务，测试并记录在计算机上，地图大小、最大距离、任务数对计算时间的影响
% longtask 以比较长的任务为基准，但是所规划的路径长度要小于初始任务长度
% standardtask 按照需要规划的路径长度设计初始任务
% 用于C++程序测试
clear all;
%Set_Num_Tasks =  [10:10:100 120:20:300 350:50:500];
Set_Num_Tasks =  [10:10:100 120:20:300 350:50:1000];
Set_MaxDis_Tasks = [1 2 3 4 5 6 8 10 12 14 16 18 20:5:30];

% Set_MaxDis_Tasks = [1 2];
% Set_Num_Tasks = 200;
%  Set_MaxDis_Tasks = [25 30];
% Set_Num_Tasks = 10:10:30;
% Set_MaxDis_Tasks = [2 4 6 8 10 12 14 20];
Row = 8;
Column = 5;
Num_Tasks = 200;  %任务数
MaxDis_Tasks = 10; %任务最大距离
test_tpye = 'longtask'; %选项：'standardtask','longtask'
    

for Num_Tasks = Set_Num_Tasks
    Sign_Succ_Vector = ones(1,2);%用于记录连续两次的求解成功
    for MaxDis_Tasks = Set_MaxDis_Tasks
%         %依照分拣窗格行列创建地图
%         [MAP,EntrancePoints,ExitPoints] = CreateExperimentMAP(Row,Column);
        % movingai的地图
        map_file = 'F:\MATLAB_File\PrePBS-DDM-RHCR\PrePBS\MovingAI\random-64-64-10\random-64-64-10.mat';
        %map_file = 'F:\MATLAB_File\PrePBS-DDM-RHCR\PrePBS\MovingAI\den312d\den312d.mat';
        load(map_file);
        MAP = mapMatrix;
        EntrancePoints = [1 1]; %将入口和出口设置为空
        ExitPoints = [1 2];
        
        %创建测试用的任务集
        %TaskSet = CreateTestTasks(MAP,EntrancePoints,ExitPoints,Num_Tasks,MaxDis_Tasks);
        %设定所生成的任务距离
        
        if strcmp(test_tpye,'standardtask')
            TaskDisSetting = MaxDis_Tasks;
        elseif strcmp(test_tpye,'longtask')
            TaskDisSetting = 60;
        end
        TaskSet = CreateTestTasks_PBS(MAP,EntrancePoints,ExitPoints,Num_Tasks,TaskDisSetting);
        
        %计算并记录时间
        %[RouteNow,CalTime,Sign_Succ,Path_Length_Set] = Solved_by_C(MAP,MaxDis_Tasks,TaskSet(:,1:2),TaskSet(:,3:6));
        [RouteNow,CalTime,Sign_Succ,Path_Length_Set] = Solved_by_C(MAP,MaxDis_Tasks,TaskSet(:,1:2),TaskSet(:,3:6),MaxDis_Tasks);
        %记录数据
        %记录时间
        Sign_Succ_Vector(2) = Sign_Succ_Vector(1);
        Sign_Succ_Vector(1) = Sign_Succ;
        if all(Sign_Succ_Vector == 0)
            break;
        end
        if Sign_Succ
            %distance = sum(abs(TaskSet(:,1:2)-TaskSet(:,3:4)),2)+sum(abs(TaskSet(:,5:6)-TaskSet(:,3:4)),2);
            % 改为单个任务后，不需要
            %distance = sum(abs(TaskSet(:,1:2)-TaskSet(:,3:4)),2);
            distance = Sum_Dis_by_A_Star(MAP,TaskSet);
            filename2 = sprintf('CalTime_4_PBS_random-64-64-10_%s.csv',test_tpye);
            Distance_Rate = sum(Path_Length_Set)/sum(distance);
            fid2 = fopen(filename2, 'a');
            % T3 表示最终的计算次数
            fprintf(fid2,'R ,%d ,C ,%d ,N ,%d ,D ,%d,Rate ,%f,T ,%f ,\n',size(MAP,1),size(MAP,2),size(TaskSet,1),MaxDis_Tasks,Distance_Rate,CalTime);
            fclose(fid2);
        end
        % 整理内存,可能原因是持久变量导致内存持续增加，但无法找到是在哪个函数中定义的持久变量
%         save ('.\TemporyMemory.mat');
%         clear functions
%         load ('.\TemporyMemory.mat');
    end
end