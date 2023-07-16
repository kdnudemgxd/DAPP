function [MAP,Entrances,Exits,SortingPanes] = CreateExperimentMAP(Row,Column)
%����ʵ�������ͼ
% Obstacle=-1, Space=2, Subgraph = 3
%Row ��ͼ�зּ𴰸�����
%Column ��ͼ�зּ𴰸�����
%220112SortingPanes�ּ𴰸�λ��
%װ�ش����·����кŴ�С�����һ��Ϊ���ڣ��ڶ���Ϊ���

MAP = ones(4*Row+2,4*Column+6)*2;
for i = 1:Row
    for j = 0:Column+1
        MAP(4*i-1:4*i,4*j+1:4*j+2) = -1;
    end
end
%��������
[m,n] = size(MAP);
Entrances = zeros(2*Row+2,2);
Exits = zeros(2*Row+2,2);
Entrances(1:Row+1,:) = [(1:Row+1)'*4-2',ones(Row+1,1)];
Entrances(Row+2:2*Row+2,:) = [(1:Row+1)'*4-2',ones(Row+1,1)*n];
Exits = [Entrances(:,1)-1,Entrances(:,2)];
%�ּ𴰸�
SortingPanes = zeros(4,2,Row*Column);
for k = 1:Row*Column
    i = mod(k-1,Row);
    j = floor((k-1)/Row);
    SortingPanes(:,:,k) = [4+4*i-1,4+4*j+1;
                            4+4*i-1,4+4*j+2;
                            4+4*i,4+4*j+1;
                            4+4*i,4+4*j+2;];
end
seq = 1:Row*Column;
%seq = reshape(seq,Column,Row);
seq = reshape(seq,Row,Column);
seq = seq';
seq = reshape(seq,1,[]);
SortingPanes = SortingPanes(:,:,seq);
% p = 1;
% for i = 1:size(MAP,1)
%     for j = 1:size(MAP,2)
%         if MAP(i,j) == -1 && (j > 2 && j < size(MAP,2)-2) && 
%             SortingPanes(p,:) = [i,j];
%             p = p+1;
%         end
%     end
% end

end