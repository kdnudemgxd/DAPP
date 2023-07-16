%% ͨ�����е�ͼ��С������������������������񳤶���ѵ����ϼ���ʱ��
% <html>
% <table border="0" width="600px" id="table1">	<tr>		<td><b><font size="2">�ð�������������</font></b></td>	</tr>	<tr><td><span class="comment"><font size="2">1�����˳���פ���ڴ�<a target="_blank" href="http://www.matlabsky.com/forum-78-1.html"><font color="#0000FF">���</font></a>��Ըð������ʣ��������ʱش�</font></span></td></tr><tr>	<td><span class="comment"><font size="2">2</font><font size="2">���˰��������׵Ľ�ѧ��Ƶ����Ƶ��������<a href="http://www.matlabsky.com/forum-91-1.html">http://www.matlabsky.com/forum-91-1.html</a></font><font size="2">�� </font></span></td>	</tr>			<tr>		<td><span class="comment"><font size="2">		3���˰���Ϊԭ��������ת����ע����������MATLAB�����㷨30����������������</font></span></td>	</tr>		<tr>		<td><span class="comment"><font size="2">		4�����˰��������������о��й��������ǻ�ӭ���������Ҫ��ȣ����ǿ��Ǻ���Լ��ڰ����</font></span></td>	</tr>	<tr>		<td><span class="comment"><font size="2">		5����������Ϊ���壬��ʵ�ʷ��е��鼮�������г��룬�����鼮�е�����Ϊ׼��</font></span></td>	</tr>	</table>
% </html>

%% ��ջ�������
clear all
clc

%% ��������
% load PBS_CalTime_r_34_c_26.mat
load PBS_CalTime_random-64-64-10
% �������ѵ�����Ͳ��Լ�
n = randperm(size(Attributes,2));
% ѵ��������200������
num_test = ceil(0.7*size(Attributes,2));
p_train = Attributes(:,n(1:num_test))';
t_train = Strength(:,n(1:num_test))';
% ���Լ�����383-283������
p_test = Attributes(:,n(num_test+1:end))';
t_test = Strength(:,n(num_test+1:end))';

%% ���ݹ�һ��

% ѵ����
[pn_train,inputps] = mapminmax(p_train');
pn_train = pn_train';
pn_test = mapminmax('apply',p_test',inputps);
pn_test = pn_test';
% ���Լ�
[tn_train,outputps] = mapminmax(t_train');
tn_train = tn_train';
tn_test = mapminmax('apply',t_test',outputps);
tn_test = tn_test';

%% SVMģ�ʹ���/ѵ��

% Ѱ�����c����/g����
[c,g] = meshgrid(-10:0.5:10,-10:0.5:10);
[m,n] = size(c);
cg = zeros(m,n);
eps = 10^(-4);
v = 5;
bestc = 0;
bestg = 0;
error = Inf;
for i = 1:m
    for j = 1:n
        cmd = ['-v ',num2str(v),' -t 2',' -c ',num2str(2^c(i,j)),   ' -g ',num2str(2^g(i,j) ),' -s 3 -p 0.1'];
        cg(i,j) = svmtrain(tn_train,pn_train,cmd);
        if cg(i,j) < error
            error = cg(i,j);
            bestc = 2^c(i,j);
            bestg = 2^g(i,j);
        end
        if abs(cg(i,j) - error) <= eps && bestc > 2^c(i,j)
            error = cg(i,j);
            bestc = 2^c(i,j);
            bestg = 2^g(i,j);
        end
    end
end
% ����/ѵ��SVM  
cmd = [' -t 2',' -c ',num2str(bestc),' -g ',num2str(bestg),' -s 3 -p 0.01'];
model = svmtrain(tn_train,pn_train,cmd);

%% SVM����Ԥ��
[Predict_1,error_1,dec_value1] = svmpredict(tn_train,pn_train,model);
[Predict_2,error_2,dec_value2] = svmpredict(tn_test,pn_test,model);
% ����һ��
predict_1 = mapminmax('reverse',Predict_1,outputps);
predict_2 = mapminmax('reverse',Predict_2,outputps);
% ����Ա�
result_1 = [t_train predict_1];
result_2 = [t_test predict_2];
%% ����ѵ�����
%save('CalTimeModel_4PBS_r_34_c_26_SVM.mat','model','inputps','outputps');
save('CalTimeModel_4PBS_random-64-64-10_SVM.mat','model','inputps','outputps');

%% ��ͼ
figure(1)
plot(1:length(t_train),t_train,'r-*',1:length(t_train),predict_1,'b:o')
grid on
legend('��ʵֵ','Ԥ��ֵ')
xlabel('�������')
ylabel('����ʱ��')
string_1 = {'ѵ����Ԥ�����Ա�';
           ['mse = ' num2str(error_1(2)) ' R^2 = ' num2str(error_1(3))]};
title(string_1)
figure(2)
plot(1:length(t_test),t_test,'r-*',1:length(t_test),predict_2,'b:o')
grid on
legend('��ʵֵ','Ԥ��ֵ')
xlabel('�������')
ylabel('����ʱ��')
string_2 = {'���Լ�Ԥ�����Ա�';
           ['mse = ' num2str(error_2(2)) ' R^2 = ' num2str(error_2(3))]};
title(string_2)

%% BP ������
% 
% % ����ת��
% pn_train = pn_train';
% tn_train = tn_train';
% pn_test = pn_test';
% tn_test = tn_test';
% % ����BP������
% net = newff(pn_train,tn_train,10);
% % ����ѵ������
% net.trainParam.epochs = 1000;
% net.trainParam.goal = 1e-3;
% net.trainParam.show = 10;
% net.trainParam.lr = 0.1;
% % ѵ������
% net = train(net,pn_train,tn_train);
% % �������
% tn_sim = sim(net,pn_test);
% % �������
% E = mse(tn_sim - tn_test);
% % ����ϵ��
% N = size(t_test,1);
% R2=(N*sum(tn_sim.*tn_test)-sum(tn_sim)*sum(tn_test))^2/((N*sum((tn_sim).^2)-(sum(tn_sim))^2)*(N*sum((tn_test).^2)-(sum(tn_test))^2)); 
% % ����һ��
% t_sim = mapminmax('reverse',tn_sim,outputps);
% % ��ͼ
% figure(3)
% plot(1:length(t_test),t_test,'r-*',1:length(t_test),t_sim,'b:o')
% grid on
% legend('��ʵֵ','Ԥ��ֵ')
% xlabel('�������')
% ylabel('��ѹǿ��')
% string_3 = {'���Լ�Ԥ�����Ա�(BP������)';
%            ['mse = ' num2str(E) ' R^2 = ' num2str(R2)]};
% title(string_3)

%%
% <html>
% <table width="656" align="left" >	<tr><td align="center"><p align="left"><font size="2">�����̳��</font></p><p align="left"><font size="2">Matlab������̳��<a href="http://www.matlabsky.com">www.matlabsky.com</a></font></p><p align="left"><font size="2">M</font><font size="2">atlab�����ٿƣ�<a href="http://www.mfun.la">www.mfun.la</a></font></p></td>	</tr></table>
% </html>