function  DisplayConMap(MAP,RouteNow,TaskSet)
%DISPLAYCONMAP ��ʾ������·����ͨ���ϵ�
%   �˴���ʾ��ϸ˵��
for i = 1:size(RouteNow,1)-2
    DisplayMAP(MAP,squeeze(RouteNow(i,:,:))',squeeze(RouteNow(i+1,:,:))',TaskSet);
end
end

