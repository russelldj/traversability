function [grid_point_cloud, grid_labels_mtx] = grid_cloud(pc_data, pc_path, resolution, force_reload, crop, crop_height)
% Default argument
if nargin < 6
    crop_height = 3;
end
if nargin < 5
    crop = true;
end
if nargin < 4
    force_reload = true;
end

% Indexes a global variable point cloud
function points = index_cloud(inds) 
    points = pc_data(inds,:);
end

% Indexes a global variable point cloud
% Crops points within a threshold of the highest ground point in a cell
function valid_points = index_cloud_and_crop(inds) 
    points = pc_data(inds,:);

    ground_inds = points(:, 4) == 0;
    ground_points = points(ground_inds, 1:4);
    if size(ground_points, 1) == 0
        % 
        valid_points = zeros(0, 4);
    else
        heighest_ground = max(ground_points(:, 3));
        height_above = points(:,3) - heighest_ground;
        valid_inds = height_above < crop_height;
        valid_points = points(valid_inds, 1:4);
    end
  
end



%% Dividing Point Cloud in Grid
base_name = split(pc_path, '.');
base_name = base_name(1);
gc_data_path = strcat(base_name, '_grid_cloud.mat');
gc_data_path = gc_data_path{1}; % Remove spurious cell array
if isfile(gc_data_path) && ~force_reload
    %% Load Data
    disp("Loading Grid Cloud")
    load(gc_data_path, 'grid_point_cloud', 'grid_labels_mtx');
else
    %% Process Data
    disp("Generating Grid Cloud")
    
    % Compute preliminaries for gridding
    point_mins = min(pc_data(:, 1:3), [], 1);
    point_maxes = max(pc_data(:, 1:3), [], 1);
    spatial_extent = transpose([point_mins ; point_maxes]);
    num_x_y = fix((point_maxes(1:2) - point_mins(1:2))/resolution);
    
    % Actually compute gridding with optimized library function
    bins = pcbin(pointCloud(pc_data(:,1:3)), [num_x_y(1),num_x_y(1),1], spatial_extent);
    % Obtain the points from the indices
    if crop
        points_per_bin = cellfun(@index_cloud_and_crop, bins, 'UniformOutput', false);
    else
        points_per_bin = cellfun(@index_cloud, bins,'UniformOutput', false );     
    end
    % Aggregate the information into a single array with labels
    grid_point_cloud = zeros([size(pc_data,1), 4]);
    grid_labels_mtx = zeros(num_x_y);
    num_points_added = 1;
    label_ID = 1;
    num_x = num_x_y(1);
    num_y = num_x_y(2);

    for i=1:num_x
        for j=1:num_y
            % Extract the points 
            current_points = points_per_bin{i,j};
            num_points = size(current_points, 1);
            labels = ones(num_points,1)*label_ID;

            % disp(strcat("Setting num_points = ",string(num_points), " to label = ", string(index)))
            % Set the points and labels
            grid_point_cloud(num_points_added:num_points_added+num_points-1, 1:3) = current_points(:, 1:3);
            grid_point_cloud(num_points_added:num_points_added+num_points-1, 4) = labels;
            % Fill this semi-useless variable indicating the id at each
            % cell
            grid_labels_mtx(i,j) = label_ID;
            % Increment to determine where to insert
            num_points_added = num_points_added + num_points;
            % Increament label
            label_ID = label_ID+1;
        end
    end
  
    save(gc_data_path, 'grid_point_cloud', 'grid_labels_mtx');
end
figure

indx =  grid_point_cloud(:,4);
pcshow(grid_point_cloud(:,1:3), indx);
colormap("lines")

end