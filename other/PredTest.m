load predict %装载svm预测模型
Attribution = [27 17 18 12];
AttritutionNormal = mapminmax('apply',Attribution',inputps);
[Predict_1,error_1,dec_value1] = svmpredict(0,AttritutionNormal',model);
Predict_Time1 = abs(mapminmax('reverse',Predict_1,outputps));
x = Predict_Time1; %得到规划1到最大步数所对应的计算时间