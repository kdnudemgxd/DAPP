%% 测试神经网络的拟合效果
CalTime_Pred_net = zeros(100,100);
for i = 1:100
    for j = 1:100
        CalTime_Pred_net(i,j) = PBS_70_38_NeuralNetworkFunction([i*10;j]);
    end
end
mesh(CalTime_Pred_net);