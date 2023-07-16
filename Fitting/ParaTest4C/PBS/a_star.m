function [shortest_path, shortest_distance] = a_star(map_matrix, start, goal)
    [rows, cols] = size(map_matrix);
    frontier = containers.Map('KeyType', 'char', 'ValueType', 'double');
    frontier(mat2str(start)) = 0;
    came_from = containers.Map('KeyType', 'char', 'ValueType', 'any');
    cost_so_far = containers.Map('KeyType', 'char', 'ValueType', 'double');
    came_from(mat2str(start)) = [];
    cost_so_far(mat2str(start)) = 0;
    
    while ~isempty(frontier)
        [~, idx] = min(cell2mat(values(frontier)));
        current_key = keys(frontier);
        current_key = current_key{idx};
        current = str2num(current_key);
        if isequal(current, goal)
            break;
        end
        remove(frontier, current_key);

        for next = neighbors(map_matrix, current)'
            next_h = next';
            new_cost = cost_so_far(mat2str(current)) + 1;
            next_key = mat2str(next_h);
            
            if ~isKey(cost_so_far, next_key) || new_cost < cost_so_far(next_key)
                cost_so_far(next_key) = new_cost;
                priority = new_cost + heuristic(goal, next_h);
                frontier(next_key) = priority;
                came_from(next_key) = current;
            end
        end
    end

    if ~isKey(came_from, mat2str(goal))
        shortest_path = [];
        shortest_distance = Inf;
        return;
    end
    
    shortest_path = goal;
    current = goal;
    
    while ~isempty(came_from(mat2str(current)))
        current = came_from(mat2str(current));
        shortest_path = [current; shortest_path];
    end
    
    shortest_distance = size(shortest_path, 1) - 1;
end
function dist = heuristic(a, b)
    dist = abs(a(1) - b(1)) + abs(a(2) - b(2));
end

function nbrs = neighbors(map_matrix, node)
    [rows, cols] = size(map_matrix);
    x = node(1);
    y = node(2);
    nbrs = [];
    directions = [1, 0; -1, 0; 0, 1; 0, -1];
    
    for k = 1:size(directions, 1)
        nx = x + directions(k, 1);
        ny = y + directions(k, 2);
        if (nx >= 1 && nx <= rows && ny >= 1 && ny <= cols && map_matrix(nx, ny) == 2)
            nbrs = [nbrs; nx, ny];
        end
    end
end

function str = serialize(arr)
    str = sprintf('%d %d', arr(1), arr(2));
end

function arr = deserialize(str)
    arr = sscanf(str, '%d %d')';
end