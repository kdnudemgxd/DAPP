%% 测试根据进车速度所形成的步骤设置
%V = 0.25:0.25:2.5;
%V = 2;
V = 1:10;
%V = 1:1:10;%0.1:0.1:1;

%% 分拣地图
Row = 5;
Column = 4;
[MAP,EntrancePoints,ExitPoints] = CreateExperimentMAP(Row,Column);
%设置装载模型文件的位置
FittingModel.CalModel = strcat('F:\MATLAB_File\PreMFN-DDM-HeatSec\MFN_Prediction_SetStep_Split\Fitting\CalTime_Prediction\PBS_CalTime\CalTimeModel_4PBS_r_',...
    num2str(size(MAP,1)),'_c_',num2str(size(MAP,2)),'_SVM.mat');
FittingModel.OptModel = strcat('F:\MATLAB_File\PreMFN-DDM-HeatSec\MFN_Prediction_SetStep_Split\Fitting\ExpectedStep_Setting\PBS_Opt_Fit\OptModel_4PBS_r_',...
    num2str(size(MAP,1)),'_c_',num2str(size(MAP,2)),'_SVM.mat');
FittingModel.Y1Model = strcat('F:\MATLAB_File\PreMFN-DDM-HeatSec\MFN_Prediction_SetStep_Split\Fitting\ExpectedStep_Setting\PBS_Opt_Fit\Y1_r_',...
    num2str(size(MAP,1)),'_c_',num2str(size(MAP,2)),'.mat');


ExpectedSteps = zeros(1,length(V));
for i = 1:length(V)
    ExpectedSteps(i) = Get_RunStep_PBS_220301(MAP,EntrancePoints,ExitPoints,V(i),2,FittingModel);
end
%% 绘图
FileName = {'0.10','0.20','0.30','0.40','0.50','0.60','0.70','0.80','0.90','1.00'};
Xname = FileName;
figure
plot(ExpectedSteps);
set(gca,'xlim',[1 length(Xname)],'XTick',1:length(Xname),'XtickLabel',Xname,'FontSize',10);
axis([1 length(Xname) 0 1.2*max(ExpectedSteps)]);
title('ExpectedSteps','FontSize',16);
legend('PreNet','Location','NorthWest');
xlabel('V','FontSize',16);
ylabel('Time(s)','FontSize',16);