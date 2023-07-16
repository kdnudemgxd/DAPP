function Y2 = Get_Y2(S,E_Distance,V_In,N_Opt_Temp)
% 通过SVM进行最优性值的预测
%对步数列表进行预测
%N_Opt_Temp = 1:200;%10:10:200; %考虑最优性的任务数（临时）
 %N_Opt_Temp = 10:10:1000;
%% 拟合Y2
YFIT2 = zeros(length(N_Opt_Temp),length(S));
for i = 1:length(S)
    YFIT2(:,i) = [S(i)*N_Opt_Temp./(V_In(i)*E_Distance)]' ;
end
%YFIT2(YFIT2<1) = 1;
%% 输出结果

Y2 = YFIT2;
end

