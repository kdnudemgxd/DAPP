function [MAP,Entrances,Exits,SortingPanes] = CreateExperimentMAP(Row,Column)
%����ʵ�������ͼ
% Obstacle=-1, Space=2, Subgraph = 3
%Row ��ͼ�зּ𴰸�����
%Column ��ͼ�зּ𴰸�����
%װ�ش����·����кŴ�С�����һ��Ϊ���ڣ��ڶ���Ϊ���
%��ӶԷּ𴰸��λ��������������Ϊ�ּ𴰸�ռ��4��λ�ã����Բ���ƽ����λ������
MAP = ones(4*Row+2,4*Column+6)*2;
SortingPanes = zeros(Row*Column,2);
for i = 1:Row
    for j = 0:Column+1
        MAP(4*i-1:4*i,4*j+1:4*j+2) = -1;
        if j > 0 && j < Column+1
        SortingPanes(i+(j-1)*Row,:) = [mean([4*i-1:4*i]) mean(4*j+1:4*j+2)];
    end
end
%��������
[m,n] = size(MAP);
Entrances = zeros(2*Row+2,2);
Exits = zeros(2*Row+2,2);
Entrances(1:Row+1,:) = [(1:Row+1)'*4-2',ones(Row+1,1)];
Entrances(Row+2:2*Row+2,:) = [(1:Row+1)'*4-2',ones(Row+1,1)*n];
Exits = [Entrances(:,1)-1,Entrances(:,2)];
end