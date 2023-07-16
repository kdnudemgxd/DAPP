%% 计算所拟合参数与计算时间之间的关系
Filename_Coor = {'PBS_r_22_c_22_OptValue.mat'};
% Filename_Coor = {'PBS_r_34_c_26_OptValue.mat'};
% Filename_Coor = {'PBS_r_70_c_38_OptValue.mat'};
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