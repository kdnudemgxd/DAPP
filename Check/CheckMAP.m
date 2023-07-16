function ErrorSign = CheckMAP(MAP)
%UNTITLED3 此处显示有关此函数的摘要
%   此处显示详细说明
ErrorSign = 0;
testvalue1 = sum(MAP == 3,'all');
testvelue2 = mod(testvalue1,6);
if testvelue2 ~= 0
    ErrorSign = 1;
end
end

