load OptimalityModel_Regress
E_Distance = 36.8058;
T_Step = 2;
Num_Task_Arrive = 0.2;
syms S Opt N V
eq1 = V == Num_Task_Arrive * T_Step * S;
eq2 = N == Opt*E_Distance*V/S;
eq3 = RegressModel(1) + RegressModel(2)*N^2 + RegressModel(3)*S^2 + RegressModel(4)*N + RegressModel(5)*S + RegressModel(6)*N*S == Opt;
eq4 = S - 20;

%% 求解
res = solve(eq1,eq2,eq3,[ Opt V N] );
res_Opt = double(subs(res.Opt(1),S,1:50))'
res_N = double(subs(res.N(1),S,1:50))'
%res_N = vpasolve(res.Opt(1),S, 1)
%简化
%res2 = simplify(res.Opt)