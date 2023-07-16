function  DisplayConMap(MAP,RouteNow,TaskSet)
%DISPLAYCONMAP 显示连续的路径，通过断点
%   此处显示详细说明
for i = 1:size(RouteNow,1)-2
    DisplayMAP(MAP,squeeze(RouteNow(i,:,:))',squeeze(RouteNow(i+1,:,:))',TaskSet);
end
end

