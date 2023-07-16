% Open the file for reading
clear all;
% Open the file for reading
fid = fopen('F:\MATLAB_File\PrePBS-DDM-RHCR\PrePBS\MovingAI\random-64-64-10\random-64-64-10.map','r');

% Read the height and width from the second and third lines
fgets(fid);
line = fgets(fid);
height = str2double(line(8:end));
line = fgets(fid);
width = str2double(line(7:end));

% Read the map data
map = [];
line = fgets(fid);

for i = 1:height
    line = fgets(fid);
    map = [map; line];
end

% Convert the map into a matrix
mapMatrix = zeros(height, width);
for i = 1:height
    for j = 1:width
        if map(i,j) == 'T' || map(i,j) == '@'
            mapMatrix(i,j) = -1;
        elseif map(i,j) == '.'
            mapMatrix(i,j) = 2;
        end
    end
end

% Close the file
fclose(fid);

save('F:\MATLAB_File\PrePBS-DDM-RHCR\PrePBS\MovingAI\random-64-64-10\random-64-64-10.mat');

%% Show map
% figure; 
% imagesc(mapMatrix);
% colormap([0 0 0; 1 1 1]); % Set colormap - black for 0, white for other values
% 
% % Set barrier cells to black
% barrier_locs = find(matrix==-1);
% for i = 1:length(barrier_locs)
%    x = barrier_locs(i);
%    y = mod(x-1,5)+1; % Find y coordinate
%    rectangle('Position',[x-1 y 1 1], 'FaceColor',[0 0 0]); 
% end
% % Add grid lines 
% hold on;
% for i = 1:5
%    line([i i], [0 6], 'Color', 'k', 'LineWidth', 2);
%    line([0 6], [i i], 'Color', 'k', 'LineWidth', 2);
% end

% Convert the matrix to a colormap-friendly format
% Barriers (-1) will be mapped to 1 (black) and reachable points (2) will be mapped to 2 (white)
colormapMatrix = mapMatrix + 2;

% Create a colormap with black (1) and white (2) colors
customColormap = [
    0 0 0; % Black for barriers
    1 1 1; % White for reachable points
];

% Create the image using the imagesc function
imagesc(colormapMatrix);

% Apply the custom colormap
colormap(customColormap);

% Remove axis lines and labels
axis off;