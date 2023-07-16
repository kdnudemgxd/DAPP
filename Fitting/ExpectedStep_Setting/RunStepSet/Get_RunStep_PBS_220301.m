function Num_Step = Get_RunStep_PBS_220301(MAP,Entrances,Exits,Num_Task_Arrive,T_Step,FittingModel)
%% GET_RUNSTEP ͨ�������������ʵĲ���
% �������
% Num_Step ͨ�����Ʒ����õ��Ĳ���
% �������
% MAP ��ͼ
% Entrances ��ڼ���
% Exits ���ڼ���
% Num_Task_Arrive �����������
% T_Step ÿһ����ʱ��
%% �Ľ�
% ������Ϊѡȡ������ֵʱ������Ӧ��Ԥ�ڲ����У�������һ���������ڱ�֤����ʻ���ʵ�ͬʱ���������·�������ԣ��ϸ��汾����������ֵ�Ĳ�������С�Ǹ��������׵���·�����̣�Ӱ�������ԣ�
% ��������ԵĿ���������·����С��������ģ��
% ����SVR�ع�ģ���������
% ���ͨ��ƽ�����񵽴�ʱ�䣬��������С����
%% ����
% �ж�ÿ�ν���ʱ����������
if size(MAP,1) == 81 || size(MAP,1) == 64
    E_Distance = 60; %den312d��ͼֱ������Ϊ60
else
    E_Distance = Get_E_Distance(MAP,Entrances,Exits);
end
V_In = 0; %��ʾÿ�γ���������
S = 1:ceil(E_Distance);
V_In = Num_Task_Arrive * T_Step * S;
V_In(V_In >= size(Entrances,1)) = size(Entrances,1);

% ƽ������E_Distance

%E_Distance = 53;
% ��ϳ�����������
%[YFIT1,YFIT2] = Get_Y1_Y2_Regress(S,E_Distance,V_In); %�ع����
%�Բ����б����Ԥ��
if size(MAP,1) == 22
    N_Opt_Temp = 1:200;%10:10:200; %���������Ե�����������ʱ��
elseif size(MAP,1) == 70
    N_Opt_Temp = 10:10:1000;
elseif size(MAP,1) == 34
    N_Opt_Temp = 10:10:500;
elseif size(MAP,1) == 81 || size(MAP,1) == 64
    N_Opt_Temp = 10:10:1000; %���õ�ͼ70��������
end

YFIT1 = Get_Y1_PBS_SVM(S,N_Opt_Temp,FittingModel);
YFIT2 = Get_Y2(S,E_Distance,V_In,N_Opt_Temp);
%���ֵ
YFIT3 = YFIT1 - YFIT2;
YFIT4 = YFIT3;
YFIT4(YFIT4<0) = -1;
YFIT4(YFIT4>0) = 1;
YFIT5 = diff(YFIT4,1);
YFIT5(YFIT5 ~= 0)=1;
YFIT5(YFIT4(1:end-1,:) == 0)=1;
YFIT6 = YFIT1(1:end-1,:);
YFIT6(YFIT5 == 0) = 0;



%�õ�����ʵ�������ֵ
[Optimality_S,Index_Set] = GetOptimality_V_S(YFIT1,YFIT3,YFIT6,S);

% ���������Ҫ����Ĵ���N_c
N_c = ceil(E_Distance.*Optimality_S ./ S);

% ����ʱ��T_s
T_s = S * T_Step;

% �ּ����������ɵĳ�����N_A
N_A = N_c .* V_In;
N_A = ceil(N_A*1.5);
%% Ԥ�����ʱ��T_pre
% װ��Ԥ��ģ��
%load CalTimeModel_4PBS_r_22_c_22_SVM
load(FittingModel.CalModel);

%�Բ����б����Ԥ��
T_pre = zeros(1,length(S));

%Attribution = [size(MAP,1),size(MAP,2),N_A(1),S(1)]; %�õ�Ԥ���������
%Attribution = [N_A(1),S(1)]; %�õ�Ԥ���������
for i = 1:length(S)
    Attribution = [N_A(i),S(i)];
    AttritutionNormal = mapminmax('apply',Attribution',inputps);
    [Predict_1,error_1,dec_value1] = svmpredict(0,AttritutionNormal',model);
    Predict_Time1 = abs(mapminmax('reverse',Predict_1,outputps));
    %%
    T_pre(i) = Predict_Time1; %�õ��滮1�����������Ӧ�ļ���ʱ��
end

%% ��T_peri=max(T_s,T_pre)
T_peri = max([T_s;T_pre],[],1);

%% ��V_o = V_In ./ T_peri
V_o = V_In ./ T_peri;
%���޽�����S��Ӧ��V_o����Ϊ0��������ֵ�Ӻ���������ѡ��
V_o(Index_Set(1,:)==1) = 0;
V_o = roundn(V_o,-3); %����С�������λ
%% �����ֵ��Ӧ��Sֵ
Index_Max = find(V_o == max(V_o));
% ѡȡ����������Ӧ��Sֵ�����ֵ
% Num_Step = Index_Max(end);
% ѡȡ����������Ӧ��Sֵ����Сֵ
Num_Step1 = Index_Max(1);
% ѡȡ����������Ӧ��Sֵ��ƽ��ֵ
%Num_Step = ceil(mean(Index_Max));

%% ͨ����������ʱ�䣬������С����
Time_Per_Task = 1/Num_Task_Arrive;
Num_Step2 = ceil(Time_Per_Task/T_Step);
Num_Step = max(Num_Step1,Num_Step2);

%% ����YFIT6����
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
% %% ����������������
% Opt3 = YFIT1([50 100 150 200],:);
% plot(Opt3');
% legend('N^A=50','N^A=100','N^A=150','N^A=200');
end
