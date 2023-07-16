%% 产生连续任务并记录,固定任务数
% 产生10组连续任务，用于进行多组实验
clear all
%分拣窗格行列数
MaxGroupNum = 10;
Row = 8;
Column = 5;
MAP = CreateExperimentMAP(Row,Column);
% Obstacle=-1, Target = 0, Robot=1, Space=2, Subgraph = 3
%创建任务组,获得离开口位置
TN_ex = 1000; %以1000任务数为基准
%V_prod_Set = 1:10; %任务产生速率
V_prod_Set = [3 3.5 4]; %任务产生速率
for GroupNum = 1:MaxGroupNum
    for i = 1:length(V_prod_Set)
        V_prod = V_prod_Set(i);
        T_ex = TN_ex/V_prod; %实验时间，（1）设置为1000；（2）设置为10*（Row+Column）；选择一个合适的值
        [TaskGroup,EntrancePoints,ExitPoints] = ContinuousExperimentTaskSetCreat(Row,Column,MAP,V_prod,T_ex);
        
        %% 记录任务
        VarName = sprintf('PreNet220303_r_%d_c_%d_v_%0.2f_TN_%d.mat',Row,Column,V_prod,TN_ex);
        DirName = strcat('.\Task_',num2str(Row),'_',num2str(Column),'_Group_220322\Group_',num2str(GroupNum),'\');
        if exist(DirName) ~= 7
            mkdir(DirName);
        end
        VarName = strcat(DirName,VarName);
            save(VarName);
    end
end