function Num_Step = Get_RunStep_PBS_220301(MAP,Entrances,Exits,Num_Task_Arrive,T_Step,FittingModel)
%% GET_RUNSTEP 通过方法评估合适的步长
% 输出参数
% Num_Step 通过估计方法得到的步长
% 输入参数
% MAP 地图
% Entrances 入口集合
% Exits 出口集合
% Num_Task_Arrive 任务出现速率
% T_Step 每一步的时间
%% 改进
% 将最后改为选取最大化输出值时，所对应的预期步数中，最大的那一个，这样在保证车辆驶出率的同时，尽量提高路径最优性（上个版本采用最大化输出值的步数中最小那个，这样易导致路径过短，影响最优性）
% 添加最优性的考量，避免路径过小，最优性模型
% 采用SVR回归模型拟合数据
% 添加通过平均任务到达时间，来限制最小步长
%% 程序
% 判断每次进车时车辆进入数
if size(MAP,1) == 81 || size(MAP,1) == 64
    E_Distance = 60; %den312d地图直接设置为60
else
    E_Distance = Get_E_Distance(MAP,Entrances,Exits);
end
V_In = 0; %表示每次车辆进入数
S = 1:ceil(E_Distance);
V_In = Num_Task_Arrive * T_Step * S;
V_In(V_In >= size(Entrances,1)) = size(Entrances,1);

% 平均距离E_Distance

%E_Distance = 53;
% 拟合出最优性曲面
%[YFIT1,YFIT2] = Get_Y1_Y2_Regress(S,E_Distance,V_In); %回归拟合
%对步数列表进行预测
if size(MAP,1) == 22
    N_Opt_Temp = 1:200;%10:10:200; %考虑最优性的任务数（临时）
elseif size(MAP,1) == 70
    N_Opt_Temp = 10:10:1000;
elseif size(MAP,1) == 34
    N_Opt_Temp = 10:10:500;
elseif size(MAP,1) == 81 || size(MAP,1) == 64
    N_Opt_Temp = 10:10:1000; %沿用地图70的任务数
end

YFIT1 = Get_Y1_PBS_SVM(S,N_Opt_Temp,FittingModel);
YFIT2 = Get_Y2(S,E_Distance,V_In,N_Opt_Temp);
%求差值
YFIT3 = YFIT1 - YFIT2;
YFIT4 = YFIT3;
YFIT4(YFIT4<0) = -1;
YFIT4(YFIT4>0) = 1;
YFIT5 = diff(YFIT4,1);
YFIT5(YFIT5 ~= 0)=1;
YFIT5(YFIT4(1:end-1,:) == 0)=1;
YFIT6 = YFIT1(1:end-1,:);
YFIT6(YFIT5 == 0) = 0;



%得到最合适的最优性值
[Optimality_S,Index_Set] = GetOptimality_V_S(YFIT1,YFIT3,YFIT6,S);

% 完成任务需要计算的次数N_c
N_c = ceil(E_Distance.*Optimality_S ./ S);

% 行走时间T_s
T_s = S * T_Step;

% 分拣区域内容纳的车辆数N_A
N_A = N_c .* V_In;
N_A = ceil(N_A*1.5);
%% 预测计算时间T_pre
% 装载预测模型
%load CalTimeModel_4PBS_r_22_c_22_SVM
load(FittingModel.CalModel);

%对步数列表进行预测
T_pre = zeros(1,length(S));

%Attribution = [size(MAP,1),size(MAP,2),N_A(1),S(1)]; %得到预测所需参数
%Attribution = [N_A(1),S(1)]; %得到预测所需参数
for i = 1:length(S)
    Attribution = [N_A(i),S(i)];
    AttritutionNormal = mapminmax('apply',Attribution',inputps);
    [Predict_1,error_1,dec_value1] = svmpredict(0,AttritutionNormal',model);
    Predict_Time1 = abs(mapminmax('reverse',Predict_1,outputps));
    %%
    T_pre(i) = Predict_Time1; %得到规划1到最大步数所对应的计算时间
end

%% 求T_peri=max(T_s,T_pre)
T_peri = max([T_s;T_pre],[],1);

%% 求V_o = V_In ./ T_peri
V_o = V_In ./ T_peri;
%将无交叉点的S对应的V_o设置为0，最大输出值从后续步长中选出
V_o(Index_Set(1,:)==1) = 0;
V_o = roundn(V_o,-3); %保留小数点后三位
%% 求最大值对应的S值
Index_Max = find(V_o == max(V_o));
% 选取最大化输出所对应的S值的最大值
% Num_Step = Index_Max(end);
% 选取最大化输出所对应的S值的最小值
Num_Step1 = Index_Max(1);
% 选取最大化输出所对应的S值的平均值
%Num_Step = ceil(mean(Index_Max));

%% 通过车辆到达时间，限制最小步长
Time_Per_Task = 1/Num_Task_Arrive;
Num_Step2 = ceil(Time_Per_Task/T_Step);
Num_Step = max(Num_Step1,Num_Step2);

%% 绘制YFIT6的线
% X = 1:size(YFIT6,2);
% Y = zeros(1,size(YFIT6,2));
% Z = zeros(1,size(YFIT6,2));
% for i = X
%     Y(i) = find(YFIT6(:,i) ~= 0,1,'first');
%     Z(i) = YFIT6(Y(i),i);
% end
% plot3(X,Y,Z);
% grid on;
% 
% %% 最优性三段趋势线
% Opt3 = YFIT1([50 100 150 200],:);
% plot(Opt3');
% legend('N^A=50','N^A=100','N^A=150','N^A=200');
end
