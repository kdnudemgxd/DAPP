%% 产生连续任务并记录,固定任务数
% 产生10组连续任务，用于进行多组实验
clear all
%分拣窗格行列数
MaxGroupNum = 10;
% Row = 8;
% Column = 5;
% MAP = CreateExperimentMAP(Row,Column);
map_name = 'random-64-64-10';
load(strcat('F:\MATLAB_File\PrePBS-DDM-RHCR\PrePBS\MovingAI\',map_name,'\',map_name,'.mat'))
MAP = mapMatrix;
En_Num = 30;
Exit_Num = 30;
[EntrancePoints, ExitPoints] = generate_entry_exit_points(MAP, En_Num, Exit_Num);
%任务类型，NE表示无入口，E表示有入口
Task_Type = 'NE';
% Obstacle=-1, Target = 0, Robot=1, Space=2, Subgraph = 3
%创建任务组,获得离开口位置
TN_ex = 1000; %以1000任务数为基准
Length_Task = 60;
V_prod_Set = 1:10; %任务产生速率
%V_prod_Set = [3 3.5 4]; %任务产生速率
for GroupNum = 1:MaxGroupNum
    for i = 1:length(V_prod_Set)
        V_prod = V_prod_Set(i);
        T_ex = TN_ex/V_prod; %实验时间，（1）设置为1000；（2）设置为10*（Row+Column）；选择一个合适的值
        
        %% 任务生成
        if strcmp(Task_Type,'E')
        %有入口
        %TaskGroup = ContinuousExperimentTaskSetCreat_MovingAI(EntrancePoints,ExitPoints,MAP,V_prod,T_ex,Length_Task);
        elseif strcmp(Task_Type,'NE')
        %无入口
        TaskGroup = ContinuousExperimentTaskSetCreat_NE_MovingAI(map_name,V_prod,T_ex,Length_Task);
        end
        
        %% 记录任务
        VarName = sprintf('PrePBS_random-64-64-10_%s_v_%0.2f_TN_%d.mat',Task_Type,V_prod,TN_ex);
        DirName = strcat('.\Task_random-64-64-10_Group_230522','\Group_',num2str(GroupNum),'\');
        if exist(DirName) ~= 7
            mkdir(DirName);
        end
        VarName = strcat(DirName,VarName);
            save(VarName);
    end
end