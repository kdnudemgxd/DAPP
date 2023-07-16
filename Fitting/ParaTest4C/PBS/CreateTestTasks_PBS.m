function  TaskSet = CreateTestTasks_PBS(MAP,Entrances,Exits,Num_Tasks,MaxDis_Tasks)
%依照所设定的参数创建参数预测实验的任务
%参数：
%MAP 地图
%Entrances 入口
%Exits 出口
%Num_Tasks 所设置的任务数
%MaxDis_Tasks 任务的最大距离

%输出：
%TaskSet 所产生的任务集
%% 改进
% PBS只规划第一段
% 添加中间任务点，中间任务点可以相同，但目标任务点不能相同
% 生成的任务长度更加集中，在区间Range_Dis中生成，这样计算时间也更符合设置临时目标点的情况
% 修改为两阶段任务版本，所生成的任务具有中间临时目标点
%% 程序
Distance = zeros(Num_Tasks,1); %任务起始点到目标点距离
% Distance_M = zeros(Num_Tasks,1); %任务起始点到临时目标点距离，小于目标点距离
% Range_Dis_M = zeros(Num_Tasks,2);
% Distance_1 = zeros(Num_Tasks,1);
% Distance_2 = zeros(Num_Tasks,1);
Range_Dis = [max(MaxDis_Tasks-3,1) MaxDis_Tasks]; %在最大距离[-3,0]的范围内生成任务，但距离应该不小于2
TaskSet = zeros(Num_Tasks,6);
for i = 1:Num_Tasks
    %逐个选择，不符合的重新选择，依据所设置的距离，产生临时目标
    %TaskSet记录所产生的任务，但此处并未添加防止失败的措施
    Sign_Fail = 1;
    while Sign_Fail
        %% 产生起点
        TaskSet(i,1:2) = [randi(size(MAP,1)) randi(size(MAP,2))];
        Sign = any(all(TaskSet(i,1:2) == Exits,2)) || any(all(TaskSet(i,1:2) == TaskSet(1:i-1,1:2),2))...
            || MAP(TaskSet(i,1),TaskSet(i,2)) == -1;
        while Sign
            TaskSet(i,1:2) = [randi(size(MAP,1)) randi(size(MAP,2))];
            Sign = any(all(TaskSet(i,1:2) == Exits,2)) || any(all(TaskSet(i,1:2) == TaskSet(1:i-1,1:2),2))...
                || MAP(TaskSet(i,1),TaskSet(i,2)) == -1;
        end
        
        %% 设置距离
        Distance(i) = randi(Range_Dis,1,1);
%         Range_Dis_M(i,:) = [max(floor(Distance(i)/2)-3,1) max(min(floor(Distance(i)/2)+3,Distance(i)-1),1)]; %最小距离应该为1,限制距离在中间10个长度之间
%         Distance_M(i) = randi(Range_Dis_M(i,:),1,1);
%         Distance_1(i) = Distance_M(i); %第1段距离
%         Distance_2(i) = Distance(i) - Distance_M(i); %第2段距离
        
        %% 第一段规划
        % PBS只规划第一段
        %第一段，目标点不能是进出口、分拣窗格；但可以重合
        %先找出所有符合要求的点，从中剔除不可行的点(障碍点、入口、出口、已占用、地图外)，然后随机选择
        Points_SpeDis = FindPoints_SpeDis(MAP,TaskSet(i,1:2),Distance(i)); %求得在地图内的距离为Distance(i)的点,注意为线性坐标
        Points_SpeDis_Leg = DeleteIllegalPoints_PBS(MAP,Points_SpeDis,Entrances,Exits); %删除不可行点（障碍点（分拣窗格）、入口、出口）
        if isempty(Points_SpeDis_Leg)
            Sign_Fail = 1; %Points_SpeDis_Leg 为空时，表明任务确定失败，需要循环再次执行
            continue;
        else
            Sign_Fail = 0;
        end
        %在合法的点中，随机选择一个
        [TaskSet(i,3),TaskSet(i,4)] = ind2sub(size(MAP),Points_SpeDis_Leg(randi(length(Points_SpeDis_Leg))));
        
%         if Distance_2(i) ~= 0
%             %% 第二段规划
%             %第二段，目标点不能是入口、分拣窗格；可以是出口，在出口处可以重合，在其他位置不可以重合
%             %先找出所有符合要求的点，从中剔除不可行的点(障碍点、入口、已占用（出口可占用）、地图外)，然后随机选择
%             Points_SpeDis = FindPoints_SpeDis(MAP,TaskSet(i,3:4),Distance_2(i)); %求得在地图内的距离为Distance(i)的点,注意为线性坐标
%             Index_TempSet = find(ismember(TaskSet(1:i-1,5:6),Exits,'row')); %已占用点中的出口点
%             Index_TempSet = setdiff(1:i-1,Index_TempSet); %去除出口
%             Points_SpeDis_Leg = DeleteIllegalPoints_PBS(MAP,Points_SpeDis,Entrances,TaskSet(Index_TempSet,5:6)); %删除不可行点（障碍点（分拣窗格）、入口、已占用（非出口））
%             if isempty(Points_SpeDis_Leg)
%                 Sign_Fail = 1; %Points_SpeDis_Leg 为空时，表明任务确定失败，需要循环再次执行
%                 continue;
%             else
%                 Sign_Fail = 0;
%             end
%             %在合法的点中，随机选择一个
%             [TaskSet(i,5),TaskSet(i,6)] = ind2sub(size(MAP),Points_SpeDis_Leg(randi(length(Points_SpeDis_Leg))));
%         end
    end
end
return;
end
