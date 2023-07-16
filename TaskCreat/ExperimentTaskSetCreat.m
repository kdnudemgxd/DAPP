function [TaskGroup,Entrances,Exits] = ExperimentTaskSetCreat(Row,Column,MAP,TaskNumPerEntrance)
%UNTITLED10 �˴���ʾ�йش˺�����ժҪ
% TaskSet.StartPoints ,������㣬�����λ��
% TaskSet.GoalPoints ,����Ŀ���
% TaskSet.ExitPoints ,�����뿪��
NumAGV = 1;
[m,n] = size(MAP);
ExitPoints = zeros(2*Row,2);
EndPoints = zeros(2*Row,2);
%�ֲ�Ŀ���ѡ�񼯺�
LocalGoalSet = [0 -1;1 -1;2 0;2 1;1 2;0 2;-1 1;-1 0];
%��������
Entrances = zeros(2*Row,2);
Exits = zeros(2*Row,2);
Entrances(1:Row,:) = [(1:Row)'*4-2',ones(Row,1)];
Entrances(Row+1:2*Row,:) = [(1:Row)'*4-2',ones(Row,1)*n];
Exits = [Entrances(:,1)-1,Entrances(:,2)];
%����ṹ��
TaskGroup.StartPoints = Entrances;
TaskGroup.GoalPoints = zeros(2*Row,2,TaskNumPerEntrance);
TaskGroup.ExitPoints = zeros(2*Row,2,TaskNumPerEntrance);
%% ��������
for Group = 1:TaskNumPerEntrance
    %�ּ������
    for i = 1 : 2*Row
        j = randi(8);
        %�������ѡ��ķּ𴰸���Χѡ��һ��λ��
        EndPoints(i,:) = [4*randi(Row)-1,4*randi(Column)+1] + LocalGoalSet(j,:);
        while any(all(EndPoints(1:i-1,:) == EndPoints(i,:),2))
            EndPoints(i,:) = [4*randi(Row)-1,4*randi(Column)+1] + LocalGoalSet(j,:);
        end
    end
    %�뿪��
    for i = 1 : 2*Row
        Distance = Exits - EndPoints(i,:);
        Distance = sum(abs(Distance),2);
        [~,j] = min(Distance);
        ExitPoints(i,:) = Exits(j,:);
    end
    %% ��¼����
    TaskGroup.GoalPoints(:,:,Group) = EndPoints;
    TaskGroup.ExitPoints(:,:,Group) = ExitPoints;
end
end

