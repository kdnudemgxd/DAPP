%% 计算所拟合参数与计算时间之间的关系
% Filename_Coor = {'PBS_CalTime_r_22_c_22.mat'};
% Filename_Coor = {'PBS_CalTime_r_34_c_26.mat'};
Filename_Coor = {'PBS_CalTime_r_70_c_38.mat'};
Data_Corr = [];
for i = 1:length(Filename_Coor)
    load(Filename_Coor{i});
    Data_Corr = [Data_Corr ; Data([1:4 6],:)'];
end
%% 各种相关系数
[R1,P1] = corrcoef(Data_Corr);
[R2,P2] = corr(Data_Corr,'type','Kendall');
[R3,P3] = corr(Data_Corr,'type','Spearman');
[R4,P4] = partialcorr(Data_Corr);