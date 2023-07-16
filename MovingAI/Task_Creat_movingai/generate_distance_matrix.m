function [distance_matrix,reachable_points] = generate_distance_matrix(MAP)

% Find the coordinates of all reachable points (value 2) in the matrix 'MAP'
[row, col] = find(MAP == 2);
reachable_points = [row, col];

% Iterate through all reachable points and calculate the distance maps
distance_matrices = cell(size(reachable_points, 1), 1);
for i = 1:size(reachable_points, 1)
    start_point = reachable_points(i, :);
    distance_matrices{i} = bfs_distance_map(start_point, MAP);
end

% Extract the distances from the distance maps and store them in a matrix
num_points = size(reachable_points, 1);
distance_matrix = Inf(num_points, num_points);

for i = 1:num_points
    for j = i+1:num_points
        point_i = reachable_points(i, :);
        point_j = reachable_points(j, :);
        
        distance = distance_matrices{i}(point_j(1), point_j(2));
        
        if ~isinf(distance)
            distance_matrix(i, j) = distance;
            distance_matrix(j, i) = distance;
        end
    end
end
end

function [distance_map] = bfs_distance_map(start_point, MAP)

% Initialize a queue and visited matrix
queue = [start_point, 0];
visited = false(size(MAP));

% Set the starting point as visited
visited(start_point(1), start_point(2)) = true;

% Initialize the distance map with Inf values
distance_map = Inf(size(MAP));

% Define possible moves (up, down, left, and right)
moves = [0, 1; 0, -1; 1, 0; -1, 0];

while ~isempty(queue)
    % Get the current position and its distance
    curr_position = queue(1, 1:2);
    curr_distance = queue(1, 3);
    
    % Remove the processed position from the queue
    queue(1, :) = [];
    
    % Check all possible moves
    for i = 1:size(moves, 1)
        next_position = curr_position + moves(i, :);
        
        % Check if the move is valid (within the matrix)
        if next_position(1) >= 1 && next_position(1) <= size(MAP, 1) && ...
                next_position(2) >= 1 && next_position(2) <= size(MAP, 2)
            
            % If the next position is unvisited and reachable
            if ~visited(next_position(1), next_position(2)) && MAP(next_position(1), next_position(2)) == 2
                % Update the distance map at the next position
                distance_map(next_position(1), next_position(2)) = curr_distance + 1;
                
                % Mark the next position as visited and add it to the queue
                visited(next_position(1), next_position(2)) = true;
                queue(end+1, :) = [next_position, curr_distance + 1];
            end
        end
    end
end
end