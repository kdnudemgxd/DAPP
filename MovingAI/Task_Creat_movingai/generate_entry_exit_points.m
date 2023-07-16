function [EntrancePoints, ExitPoints] = generate_entry_exit_points(MAP, En_Num, Exit_Num)
%为其他地图创建装载点和离开点
%随机生成
% Find indices of all reachable points (value 2)
[rows, cols] = find(MAP == 2);

% Combine rows and cols into a single matrix
all_points = [rows, cols];

% Calculate the total number of reachable points
num_points = size(all_points, 1);

% Check if there are enough reachable points for entrance and exit points
if num_points < (En_Num + Exit_Num)
    error('Not enough reachable points for the specified number of entrance and exit points');
end

% Randomly select unique indices for entrance and exit points
rand_indices = randperm(num_points, En_Num + Exit_Num);

% Split the selected indices into entrance and exit points
entrance_indices = rand_indices(1:En_Num);
exit_indices = rand_indices(En_Num+1:end);

% Convert selected indices to (x, y) coordinates
EntrancePoints = all_points(entrance_indices, :);
ExitPoints = all_points(exit_indices, :);
end