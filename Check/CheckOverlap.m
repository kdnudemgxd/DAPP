function [OverlapSign,OverlapTab] = CheckOverlap(PointSet)
%CHECKOVERLAP ��������ĵ㼯���Ƿ���һ���ĵ�
% OverlapSign �غϱ�־��1Ϊ�غϣ�0Ϊ���غ�
% OverlapTab �����غϱ���ʾ���������غϵĴ���
OverlapSign = 0;
OverlapTab = zeros(size(PointSet,1),1);
%% ��ȡ�յ�
TaskNowDes = zeros(size(PointSet,1),2); 
if size(PointSet,2) > 2
    %���������Ŀ��㣬�����
    for i = 1:size(PointSet,1)
        if PointSet(i,3) == 0
            TaskNowDes(i,:) = PointSet(i,1:2);
        else
            TaskNowDes(i,:) = PointSet(i,3:4);
        end
    end
else
    TaskNowDes = PointSet;
end
%% �����غ�
for i = 1:size(TaskNowDes,1)
    OverlapTab(i) = sum(all(TaskNowDes(i,:) == TaskNowDes , 2));
end
if max(OverlapTab) > 1
    OverlapSign = 1;
end

end