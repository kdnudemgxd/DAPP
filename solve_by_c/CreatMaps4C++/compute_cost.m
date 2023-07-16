function cost = compute_cost(MAP,x,y)
% 计算往各个方向移动的代价
cost = ones(5,1);
cost = -1*cost;
if MAP(x,y) == -1
    return;
else
    if y+1 <= size(MAP,2) && MAP(x,y+1) == 2
        cost(1) = 1;
    end
    if x-1 > 0 && MAP(x-1,y) == 2
        cost(2) = 1;
    end
    if y-1 > 0 && MAP(x,y-1) == 2
        cost(3) = 1;
    end
    if x+1 <= size(MAP,1) && MAP(x+1,y) == 2
        cost(4) = 1;
    end
    cost(5) = 1;
end
end