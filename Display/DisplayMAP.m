function CNTPoints = DisplayMAP(MAP,CurrentPointLocations,NextPointLocations,TaskSet)
%UNTITLED 显示当前位置分布
%   此处显示详细说明
% 展示结果
CNTPoints = [CurrentPointLocations NextPointLocations TaskSet(:,3:4)];
%% current
[MAX_X,MAX_Y] = size(MAP);
figure
set(gcf,'unit','normalized','position',[0.2,0.2,0.64,0.32]);
 %CurrentPointLocations
 subplot(1,2,1);
 
 grid on;
 hold on;
 axis([1 MAX_X+1 1 MAX_Y+1])
 plot(CurrentPointLocations(:,1)+.5,CurrentPointLocations(:,2)+.5,'g+');
 %Obstical
 [m,n]=find(MAP==-1);
 plot(m+.5,n+.5,'ro');
 %% next
 %NextPointLocations
 
  subplot(1,2,2);
  grid on;
    hold on;
    axis([1 MAX_X+1 1 MAX_Y+1])
 plot(NextPointLocations(:,1)+.5,NextPointLocations(:,2)+.5,'gd');
 %Obstical
 [m,n]=find(MAP==-1);
 plot(m+.5,n+.5,'ro');
end

