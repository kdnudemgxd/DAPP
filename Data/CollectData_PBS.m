%% 收集PreNet数据，并保存
clc
clear
%%
%FileName = {'0.10','0.20','0.30','0.40','0.50','0.60','0.70','0.80','0.90','1.00'};
FileName = {'0.25','0.50','0.75','1.00','1.25','1.50','1.75','2.00'};
%% 装载
M_LengthSumTotal = [];
M_MakespanMeanTotal = [];
M_TotalCalTimeMeanTotal = [];
xnum1 = [];
xnum2 = [];
xnum3 = [];
xnum4 = [];
xnum5 = [];
xnum6 = [];
xnum7 = [];
for FileNameNum = 1:length(FileName)
    %% 设置文件名
    GroupName1 = strcat('F:\MATLAB_File\PreMFN-DDM-HeatSec\MFN_Prediction_SetStep_Split\Data\PBSData\r_22_c_22_v_',FileName(FileNameNum),'_TN_1000_PreNet_FixLen_PBS.mat');
    % MindistanceName = strcat('MultiQueueTask_',FileName(FileNameNum),'_n_20_mindistance');
    % MinmakespanName = strcat('MultiQueueTask_',FileName(FileNameNum),'_n_20_minmakespan');
    load(GroupName1{1});
    x1 = TotalCalTime;
    x2 = Makespan;
    x3 = TotalDistance;
%    x4 = SuccessRate;
    x5 = GetAveragePathLength(TotalPath); %平均路径长度
    x6 = GetDelayTime(TotalPath,TaskGroup); %任务完成延迟
    x7 = GetOptimality(TotalDistance,TaskGroup); %路径最优性，花费步数与最短距离比值
    
    xnum1 = [xnum1 x1];
    xnum2 = [xnum2 x2];
    xnum3 = [xnum3 x3];
%    xnum4 = [xnum4 x4*0.4+x8*0.6];
    xnum5 = [xnum5 x5];
    xnum6 = [xnum6 x6];
    xnum7 = [xnum7 x7];
end
%% 提取数据
M_TotalCalTimeMeanTotal = xnum1;
M_MakespanMeanTotal = xnum2;
M_LengthSumTotal = xnum3;
%M_SuccessRate = xnum4;
%% 转换数据
RateofTaskcompletion = 1000./M_MakespanMeanTotal;
AverageSteps = M_LengthSumTotal./1000;
AveragePathLength = xnum5;
DelayTime = xnum6;
Optimality = xnum7;
%% save
MatName = sprintf('PreNet_PBS_22_22.mat');
MatName = strcat('.\',MatName);
%save(MatName,'M_TotalCalTimeMeanTotal','M_MakespanMeanTotal','M_LengthSumTotal','M_SuccessRate');
save(MatName,'M_TotalCalTimeMeanTotal','M_MakespanMeanTotal','M_LengthSumTotal');
%save(MatName,'M_MakespanMeanTotal','M_LengthSumTotal');
%% 数据绘图
%Xname = {'0.25','0.50','0.75','1.00','1.25','1.50','1.75','2.00','2.25','2.50','2.75','3.00','4.00','5.00'};
Xname = FileName;
figure
plot(AverageSteps);
set(gca,'xlim',[1 length(Xname)],'XTick',1:length(Xname),'XtickLabel',Xname,'FontSize',10);
axis([1 length(Xname) 0 1.2*max(AverageSteps)]);
title('Average Steps','FontSize',16);
legend('PreNet','Location','NorthWest');
xlabel('V','FontSize',16);
ylabel('Steps','FontSize',16);

figure
plot(RateofTaskcompletion);
set(gca,'xlim',[1 length(Xname)],'XTick',1:length(Xname),'XtickLabel',Xname,'FontSize',10);
axis([1 length(Xname) 0 1.2*max(RateofTaskcompletion)]);
title('Rate','FontSize',16);
legend('PreNet','Location','NorthWest');
xlabel('V','FontSize',16);
ylabel('Rate','FontSize',16);

figure
plot(M_TotalCalTimeMeanTotal);
set(gca,'xlim',[1 length(Xname)],'XTick',1:length(Xname),'XtickLabel',Xname,'FontSize',10);
axis([1 length(Xname) 0 1.2*max(M_TotalCalTimeMeanTotal)]);
title('Rate','FontSize',16);
title('CalTime','FontSize',16);
legend('PreNet','Location','NorthWest');
xlabel('V','FontSize',16);
ylabel('Time(s)','FontSize',16);

figure
plot(AveragePathLength);
set(gca,'xlim',[1 length(Xname)],'XTick',1:length(Xname),'XtickLabel',Xname,'FontSize',10);
axis([1 length(Xname) 0 1.2*max(AveragePathLength)]);
title('AveragePathLength','FontSize',16);
legend('PreNet','Location','NorthWest');
xlabel('V','FontSize',16);
ylabel('Steps','FontSize',16);

figure
plot(DelayTime);
set(gca,'xlim',[1 length(Xname)],'XTick',1:length(Xname),'XtickLabel',Xname,'FontSize',10);
axis([1 length(Xname) 0 1.2*max(DelayTime)]);
title('DelayTime','FontSize',16);
legend('PreNet','Location','NorthWest');
xlabel('V','FontSize',16);
ylabel('Time(s)','FontSize',16);

figure
plot(Optimality);
set(gca,'xlim',[1 length(Xname)],'XTick',1:length(Xname),'XtickLabel',Xname,'FontSize',10);
axis([1 length(Xname) 0 1.2*max(Optimality)]);
title('Optimality','FontSize',16);
legend('PreNet','Location','NorthWest');
xlabel('V','FontSize',16);
ylabel('Rate','FontSize',16);