%% 读取已有的结果数据文件生成视频
clear
%% 装载数据
load F:\MATLAB_File\PrePBS-DDM-RHCR\PrePBS\Data\PBSData\GroupExp\70_38_1000_220322\Group_1\r_70_c_38_v_5.00_TN_1000_PreNet_FixLen_PBS.mat
%生成地图
Row = 17;
Column = 8;
MAP = CreateExperimentMAP(Row,Column);

% 生成图片
Display = 1;
if Display == 1
    Fig_map = figure;
end
StepTime = 2;
StartTime = TotalPath.StartTime';
EndTime = TotalPath.EndTime;

TaskSetNum = 1;
system_time = 2;
while system_time < 100 || ~isempty(TaskSetNum)
    
    TaskSetNum = find(StartTime <= system_time & EndTime > system_time);
    CurrentPointLocations = [];
    for i = 1:length(TaskSetNum)
        %更新当前时刻位置
        CurrentPointLocations(i,:) = TotalPath.TotalSet{TaskSetNum(i)}((system_time-TotalPath.StartTime(TaskSetNum(i)))/StepTime+1,:);
    end
    
    % 展示地图
    if Display == 1
        display_time = 0.5;
        DisplayAGV(Fig_map, MAP, CurrentPointLocations, TaskSetNum, display_time);
    end
    
    system_time = system_time + StepTime;
end