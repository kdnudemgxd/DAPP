function  DisplayMAP_2(MAP)
%DISPLAYMAP_2 �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
MAP(MAP == 2) = 1;
MAP(MAP == -1) = 2;
cmap = [1 1 1;0 0 0;abs(rands(14,3))];
colormap(cmap);
image(1.5, 1.5, MAP)
grid on;
axis image;
%set(gca, 'XTick', 0:1:size(MAP, 2), 'YTick', 0:1:size(MAP, 1)); %����gridΪ��λ������ʾ
set(gca, 'XTick', 0:1:size(MAP, 2), 'YTick', 0:1:size(MAP, 1), ...
    'XTickLabel', [], 'YTickLabel', [])
drawnow;
end

