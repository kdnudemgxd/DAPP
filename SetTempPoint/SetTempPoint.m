function CurrTempGoal = SetTempPoint_210813(MAP,TaskGroup,CurrentPointLocations,GoalPointLocations,TaskSetNum,PredStepNum,SignTaskComplete,EntrancePoints,ExitPoints)
%依照所预测的步数进行临时路径设置，期望实现计算能力和路径最优性之间的平衡
%在起点和目标点之间的矩形区域中，以距离起点PredStepNum距离的斜线来选择临时目标点，
%这样不会绝对导致两段路径连接起来后总路径的长度超过原来的最短路径长度
%修改TaskGroup_T为TaskGroup，以适应新的程序逻辑
%用SignTaskComplete替代TaskGroup.TempGoalNum
%矩形临时目标点不能是入口
%添加扩展矩形大小的功能，以提高规划临时点设置成功率
%% 修复bug
% 不可选择出口和入口作为临时目标点，不能选择入口的原因为入口不应被占用，不能选择出口的原因为出口进入后不能再离开
% 210720，   将矩形内寻找临时点失败时扩展一次的决策改为向着点多的方向多次扩展
%            选取原目标点为临时目标点时，由于无任何措施，所以可能出现冲突，添加同其他两种情况相同的措施
% 210813,   在矩形规划失败后，采用A*算法来进行后续规划（将已有临时目标点当做障碍物），不再采用扩展矩形的方法

%% 程序
% CurrTempGoal 对应任务的临时目标点,一般任务有一个临时目标点，经过分拣窗格的任务有两个，其中一个是分拣窗格
CurrTempGoal = zeros(size(TaskSetNum,1),4);
LengthToDes = sum(abs(GoalPointLocations-CurrentPointLocations),2);
ExistingTempPoint = zeros(size(TaskSetNum,1),2); %已选择的临时规划目标点
for i = 1:length(LengthToDes)
    ExtendValue = 0;
    Succ = 0;
    while Succ == 0
        Succ = 1;
        if LengthToDes(i) < PredStepNum
           %% 距离目标点距离小于规划的步数，则将现在目标点定为中间点，减去此段距离，然后在分拣窗格和出口之间选择更合适的位置作为临时规划目标点
            if SignTaskComplete(TaskSetNum(i)) == 1
                %此时的目标是分拣窗格，则应以分拣窗格为中间点，以分拣窗格与出口之间的某个点为临时规划目标点距离为，设定距离减去现在点到分拣窗格的距离
                CurrTempGoal(i,1:2) = GoalPointLocations(i,:);
                In_StPt = GoalPointLocations(i,:);
                In_GlPt = TaskGroup.ExitPoints(TaskSetNum(i),:);%任务对应出口
                In_Dis = PredStepNum - LengthToDes(i); %减去一定的距离
                LenSoPaToExit = sum(abs(In_GlPt - In_StPt)); %分拣窗格到达
                if In_Dis >= LenSoPaToExit
                    TempPoint = In_GlPt;
                else
                    [TempPoint,SelSucc] = SelectPointInRec_210726(MAP,In_StPt,In_GlPt,In_Dis,ExistingTempPoint,EntrancePoints,ExitPoints,ExtendValue);
                    if SelSucc == 0
                        %选择点失败的情况下，采用A*进行规划
                        Map_Occup = ExistingTempPoint;
                        NumAGV = 1; %用于DDM判断密度的参数，在此处无用
                        StartPoint = In_StPt;
                        EndPoint = In_GlPt;
                        SinglePath = SingleAGVpath(MAP,Map_Occup,NumAGV,StartPoint,EndPoint);
                        TempPoint = SinglePath(In_Dis+1,:);
                    end
                end
                CurrTempGoal(i,3:4) = TempPoint;
            else
                %此时的目标是出口，则以出口为临时规划目标点
                CurrTempGoal(i,1:2) = GoalPointLocations(i,:);
                TempPoint = GoalPointLocations(i,:);
            end
        elseif LengthToDes(i) == PredStepNum
            %% 距离目标点距离等于规划的步数，将现在的目标点设置为临时规划目标点
            TempPoint = GoalPointLocations(i,:);
            CurrTempGoal(i,1:2) = GoalPointLocations(i,:);
            % 若已经被占用，则缩短距离进行临时目标点规划，同后一种情况
            Index_Temp = ismember(ExistingTempPoint,TempPoint,'row');
            if ~isempty(Index_Temp) && ~ismember(TempPoint,EntrancePoints,'row') && ~ismember(TempPoint,ExitPoints,'row')
                In_StPt = CurrentPointLocations(i,:);
                In_GlPt = GoalPointLocations(i,:);
                %In_Dis = PredStepNum - 1;
                In_Dis = PredStepNum; %此处应该不需要减1
                [TempPoint,SelSucc] = SelectPointInRec_210726(MAP,In_StPt,In_GlPt,In_Dis,ExistingTempPoint,EntrancePoints,ExitPoints,ExtendValue);
                if SelSucc == 0
                        %选择点失败的情况下，采用A*进行规划
                        Map_Occup = ExistingTempPoint;
                        NumAGV = 1; %用于DDM判断密度的参数，在此处无用
                        StartPoint = In_StPt;
                        EndPoint = In_GlPt;
                        SinglePath = SingleAGVpath(MAP,Map_Occup,NumAGV,StartPoint,EndPoint);
                        TempPoint = SinglePath(In_Dis+1,:);
                end
                CurrTempGoal(i,1:2) = TempPoint; %记录结果，只有一个
            end
        else
            %% 距离目标点距离大于规划的步数，在此次目标点之前选择合适距离的点作为临时规划目标点
            In_StPt = CurrentPointLocations(i,:);
            In_GlPt = GoalPointLocations(i,:);
            In_Dis = PredStepNum;
            [TempPoint,SelSucc] = SelectPointInRec_210726(MAP,In_StPt,In_GlPt,In_Dis,ExistingTempPoint,EntrancePoints,ExitPoints,ExtendValue);
            
            if SelSucc == 0
                        %选择点失败的情况下，采用A*进行规划
                        Map_Occup = ExistingTempPoint;
                        NumAGV = 1; %用于DDM判断密度的参数，在此处无用
                        StartPoint = In_StPt;
                        EndPoint = In_GlPt;
                        SinglePath = SingleAGVpath(MAP,Map_Occup,NumAGV,StartPoint,EndPoint);
                        TempPoint = SinglePath(In_Dis+1,:);
             end
            CurrTempGoal(i,1:2) = TempPoint; %记录结果，只有一个
        end
        %将所选的TempPoint记录入ExistingTempPoint中，用于选择新的TempPoint的比对
        ExistingTempPoint(i,:) = TempPoint;
    end
end

end

