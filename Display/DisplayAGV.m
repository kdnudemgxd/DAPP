function DisplayAGV(Fig, MAP, CurrentPointLocations, TaskSetNum, display_time)
    % Create a copy of the MAP to display
    display_map = MAP;

    % Display the map with barriers and AGVs
    figure(Fig);
    clf(Fig, 'reset'); % Clear the figure and reset its properties
    Fig.WindowState = 'maximized'; % Maximize the figure
    imagesc(display_map);
    
    % Customize the colormap to show barriers as black blocks and empty spaces as white
    cmap = [0, 0, 0; % Black color for barriers (-1)
            1, 1, 1]; % White color for empty spaces (2)
    colormap(cmap);
    
    % Adjust color limits
    caxis([-1, 2]);
    
    % Set axis properties
    axis equal;
    axis tight;
    set(gca, 'XTick', 0.5:size(MAP, 2)+0.5, 'YTick', 0.5:size(MAP, 1)+0.5, ...
        'XTickLabel', '', 'YTickLabel', '', 'XGrid', 'on', 'YGrid', 'on', ...
        'GridLineStyle', '-', 'LineWidth', 1.5, 'GridAlpha', 0.5);
    
    % Display AGV numbers at their corresponding locations with a green background
    for i = 1:size(CurrentPointLocations, 1)
        x = CurrentPointLocations(i, 2);
        y = CurrentPointLocations(i, 1);
        % 显示数字
%         text(x, y, num2str(TaskSetNum(i)), 'HorizontalAlignment', 'center', ...
%              'Color', 'k', 'FontWeight', 'bold', 'BackgroundColor', 'green', ...
%              'Margin', 2);
         % 显示方格
         %rectangle('Position',[x-0.5, y-0.5, 1, 1],'FaceColor','blue');
         rectangle('Position', [x-0.5, y-0.5, 1, 1], 'FaceColor', [0.2, 0.4, 0.8], 'EdgeColor', 'none');
    end
    
    % Display the map for the specified amount of time
    pause(display_time);
end