function Y1 = Get_Y1_PBS_SVM(S,N_Opt_Temp,FittingModel)
% 通过SVM进行最优性值的预测
% 添加对Y1的存储
%% 装在拟合模型
%load F:\MATLAB_File\PreMFN-DDM-HeatSec\MFN_Prediction_SetStep_Split\Fitting\ExpectedStep_Setting\PBS_Opt_Fit\OptModel_4PBS_r_22_c_22_SVM.mat
%load .\OptModel_4PBS_r_70_c_38_SVM.mat
load(FittingModel.OptModel);
%对步数列表进行预测
%N_Opt_Temp = 1:200;%10:10:200; %考虑最优性的任务数（临时）
%N_Opt_Temp = 10:10:1000;
YFIT1 = zeros(length(N_Opt_Temp),length(S));
%% 拟合Y1
if exist(FittingModel.Y1Model,'file') == 0
    Attribution = [N_Opt_Temp(1),S(1)]; %得到预测所需参数
    for i = 1:length(N_Opt_Temp)
        for j = 1:length(S)
            Attribution(1:2) = [N_Opt_Temp(i),S(j)];
            AttritutionNormal = mapminmax('apply',Attribution',inputps);
            [Predict_1,error_1,dec_value1] = svmpredict(0,AttritutionNormal',model);
            Predict_Time1 = abs(mapminmax('reverse',Predict_1,outputps));
            %最优性结果
            YFIT1(i,j) = Predict_Time1; %得到规划1到最大步数所对应的计算时间
        end
    end
    YFIT1(YFIT1<1) = 1;
    save(FittingModel.Y1Model);
else
    %存在的情况下，直接装载即可
    load(FittingModel.Y1Model);
end

%% 输出结果
Y1 = YFIT1;
% 显示拟合结果和原数据
% load PBS_OptValue
% mesh(Y1);
% hold on;
% scatter3(Data_Save(2,:),Data_Save(1,:),Data_Save(3,:),'r');
end

