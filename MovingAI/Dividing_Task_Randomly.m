function index_of_task = Dividing_Task_Randomly(task_set_num, m)
    % Randomly permute the task set numbers
    permuted_task_set_num = task_set_num(randperm(length(task_set_num)));

    % Calculate the size of each set
    set_size = ceil(length(task_set_num) / m);

    % Initialize the cell array to store the sets
    index_of_task = cell(1, m);

    % Divide the permuted task set numbers into m sets
    for i = 1:m
        start_idx = (i - 1) * set_size + 1;
        end_idx = min(i * set_size, length(task_set_num));
        index_of_task{i} = permuted_task_set_num(start_idx:end_idx);
        index_of_task{i} = sort(index_of_task{i});
    end
end
