function [Y1,Y2] = Get_Y1_Y2_Regress(S,E_Distance,V_In)
%% 通过回归的方式实现对最优性的估计
%   此处显示详细说明
% 装载最优性模型
load OptimalityModel_Regress
%考虑最优性的平均路径长度，考虑最优性以避免路径过小
N_Opt_Temp = 1:200;%10:10:200; %考虑最优性的任务数（临时）
X1FIT = N_Opt_Temp';
X2FIT = S;
%% 拟合Y1
YFIT1 = RegressModel(1) + RegressModel(2)*X1FIT.^2 + RegressModel(3)*X2FIT.^2 + RegressModel(4)*X1FIT + RegressModel(5)*X2FIT + RegressModel(6)*X1FIT.*X2FIT;
YFIT1(YFIT1<1) = 1;
% 拟合出S*N/V_in(s) = Optimality*E_Distance

%% 拟合Y2
YFIT2 = zeros(size(YFIT1));
for i = 1:length(S)
    YFIT2(:,i) = [S(i)*N_Opt_Temp./(V_In(i)*E_Distance)]' ;
end
YFIT2(YFIT2<1) = 1;
%% 输出结果
Y1 = YFIT1;
Y2 = YFIT2;
end

