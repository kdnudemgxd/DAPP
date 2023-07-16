function [Optimality_S,Index_Set] = GetOptimality_V_S(YFIT1,YFIT3,YFIT6,S)
%% 计算以S为自变量的Optimality值变化
%   YFIT3为差值，YFIT6为交叉线所在处的值
% 先在YFIT6中依照S选择，若不存在交线，则在差值YFIT3中选择绝对值最小的值
Optimality_S = zeros(1,length(S));
Index_Set = zeros(2,length(S));
for i = 1:length(S)
    Index = find(YFIT6(:,S(i)) ~= 0,1);
    if isempty(Index)
        [~,Index] = min(YFIT3(:,S(i)));
        Optimality_S(i) = YFIT1(Index,S(i));
        Index_Set(:,i) = [1;Index];
    else
        Optimality_S(i) = YFIT6(Index,S(i));
        Index_Set(:,i) = [6;Index];
    end
end

end

