% 展示计算时间拟合模型的拟合结果
%% 装在拟合模型
load CalTimeModel_4PBS_r_22_c_22_SVM
%对步数列表进行预测
%N_Opt_Temp = 1:200;%10:10:200; %考虑最优性的任务数（临时）
%S = 1:sum(size(MAP));
S = 1:26;
N_Cal_Temp = 1:200;
%N_Cal_Temp = 10:10:1000;
%N_Cal_Temp = 10:10:500;
YFIT1 = zeros(length(N_Cal_Temp),length(S));
%% 拟合Y1
Attribution = [N_Cal_Temp(1),S(1)]; %得到预测所需参数
for i = 1:length(N_Cal_Temp)
    for j = 1:length(S)
        Attribution(1:2) = [N_Cal_Temp(i),S(j)];
        AttritutionNormal = mapminmax('apply',Attribution',inputps);
        [Predict_1,error_1,dec_value1] = svmpredict(0,AttritutionNormal',model);
        Predict_CalTime1 = abs(mapminmax('reverse',Predict_1,outputps));
        %最优性结果
        YFIT1(i,j) = Predict_CalTime1; %得到规划1到最大步数所对应的计算时间
    end
end
%YFIT1(YFIT1<1) = 1;

%% 输出结果
Y1 = YFIT1;
% 显示拟合结果和原数据
% load PBS_OptValue
 mesh(Y1);
% hold on;
% scatter3(Data_Save(2,:),Data_Save(1,:),Data_Save(3,:),'r');
%end

  