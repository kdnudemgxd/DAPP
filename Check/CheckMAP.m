function ErrorSign = CheckMAP(MAP)
%UNTITLED3 �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
ErrorSign = 0;
testvalue1 = sum(MAP == 3,'all');
testvelue2 = mod(testvalue1,6);
if testvelue2 ~= 0
    ErrorSign = 1;
end
end

