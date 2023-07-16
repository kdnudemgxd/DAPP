function [Exist,num] = ExistinSortingPanes(SortingPanes,x,y)
%判断点是否存在于SortingPanes中，如果存在，给出编号
Exist = false;
num = 0;
for i = 1:size(SortingPanes,3)
    Manhattan_dis = sum(abs(SortingPanes(:,:,i) - [x,y]),2);
    if any(Manhattan_dis == 1)
        Exist = true;
        num = i;
        return;
    end
end

end