function total_distance = Sum_Dis_by_A_Star(map_matrix, task_set)
% 使用A*算法求解最短路径，并求和
    total_distance = 0;
    
    for task = task_set'
        start = task(1:2)';
        goal = task(3:4)';
        [~,distance] = a_star(map_matrix, start, goal);
        
        if isinf(distance)
            error('No path found between (%d, %d) and (%d, %d)', start(1), start(2), goal(1), goal(2));
        end
        
        total_distance = total_distance + distance;
    end
end

% function dist = heuristic(a, b)
%     dist = abs(a(1) - b(1)) + abs(a(2) - b(2));
% end
% 
% function nbrs = neighbors(map_matrix, node)
%     [rows, cols] = size(map_matrix);
%     x = node(1);
%     y = node(2);
%     nbrs = [];
%     directions = [1, 0; -1, 0; 0, 1; 0, -1];
%     
%     for k = 1:size(directions, 1)
%         nx = x + directions(k, 1);
%         ny = y + directions(k, 2);
%         if (nx >= 1 && nx <= rows && ny >= 1 && ny <= cols && map_matrix(nx, ny) == 2)
%             nbrs = [nbrs; nx, ny];
%         end
%     end
% end
% 
% function [shortest_path, shortest_distance] = a_star(map_matrix, start, goal)
%     [rows, cols] = size(map_matrix);
%     frontier = containers.Map('KeyType', 'char', 'ValueType', 'double');
%     frontier(mat2str(start)) = 0;
%     came_from = containers.Map('KeyType', 'char', 'ValueType', 'any');
%     cost_so_far = containers.Map('KeyType', 'char', 'ValueType', 'double');
%     came_from(mat2str(start)) = [];
%     cost_so_far(mat2str(start)) = 0;
%     
%     while ~isempty(frontier)
%         [~, idx] = min(cell2mat(values(frontier)));
%         current_key = keys(frontier);
%         current_key = current_key{idx};
%         current = str2num(current_key);
%         if isequal(current, goal)
%             break;
%         end
%         remove(frontier, current_key);
% 
%         for next = neighbors(map_matrix, current)'
%             new_cost = cost_so_far(mat2str(current)) + 1;
%             next_key = mat2str(next);
%             
%             if ~isKey(cost_so_far, next_key) || new_cost < cost_so_far(next_key)
%                 cost_so_far(next_key) = new_cost;
%                 priority = new_cost + heuristic(goal, next);
%                 frontier(next_key) = priority;
%                 came_from(next_key) = current;
%             end
%         end
%     end
% 
%     if ~isKey(came_from, mat2str(goal))
%         shortest_path = [];
%         shortest_distance = Inf;
%         return;
%     end
%     
%     shortest_path = goal;
%     current = goal;
%     
%     while ~isempty(came_from(mat2str(current)))
%         current = came_from(mat2str(current));
%         shortest_path = [current; shortest_path];
%     end
%     
%     shortest_distance = size(shortest_path, 1) - 1;
% end

% function [path, distance] = a_star(map_matrix, start, goal)
%     [rows, cols] = size(map_matrix);
%     frontier = PriorityQueue();
%     frontier.insert(mat2str(start), 0);
%     came_from = containers.Map('KeyType', 'char', 'ValueType', 'any');
%     cost_so_far = containers.Map('KeyType', 'char', 'ValueType', 'double');
%     came_from(mat2str(start)) = [];
%     cost_so_far(mat2str(start)) = 0;
%     
%     while ~frontier.is_empty()
%         [current_key, ~] = frontier.pop();
%         current = str2num(current_key);
% 
%         if isequal(current, goal)
%             break;
%         end
%         
%         for next = neighbors(map_matrix, current)'
%             new_cost = cost_so_far(mat2str(current)) + 1;
%             next_key = mat2str(next);
%             
%             if ~isKey(cost_so_far, next_key) || new_cost < cost_so_far(next_key)
%                 cost_so_far(next_key) = new_cost;
%                 priority = new_cost + heuristic(goal, next);
%                 frontier.insert(next_key, priority);
%                 came_from(next_key) = current;
%             end
%         end
%     end
%     
%     if ~isKey(came_from, mat2str(goal))
%         path = [];
%         distance = Inf;
%         return;
%     end
%     
%     path = goal;
%     current = goal;
%     
%     while ~isempty(came_from(mat2str(current)))
%         current = came_from(mat2str(current));
%         path = [current; path];
%     end
%     
%     distance = size(path, 1) - 1;
% end

