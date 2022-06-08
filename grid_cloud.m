function [grid_point_cloud, grid_labels_mtx] = grid_cloud(pc_data, pc_path, resolution, force_reload)

if nargin < 4
    force_reload = true;
end
    
function points = index_cloud(inds) 
    points = pc_data(inds,:);
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
    grid_point_cloud = [];
    grid_labels_mtx = [];
    grid_labels = [];
    nLabels = 1;

    % TODO vectorize
    x_min = min(pc_data(:,1));
    x_max = max(pc_data(:,1));

    y_min = min(pc_data(:,2));
    y_max = max(pc_data(:,2));

    z_min = min(pc_data(:,3));
    z_max = max(pc_data(:,3));

    xLimits = linspace(x_min, x_max, fix((x_max - x_min)/resolution));
    yLimits = linspace(y_min, y_max, fix((y_max - y_min)/resolution));
    
    num_x = fix((x_max - x_min)/resolution);
    num_y = fix((y_max - y_min)/resolution);
    disp('Grid Cloud Resolution X, Y: ' + resolution)
    
    spatial_extent = [[x_min, x_max];[y_min, y_max];[z_min, z_max]];
    bins = pcbin(pointCloud(pc_data(:,1:3)), [num_x,num_y,1], spatial_extent);
    points_per_bin = cellfun(@index_cloud, bins,'UniformOutput', false );
    disp(points_per_bin{200,200})

    grid_point_cloud = zeros([size(pc_data,1), 4]);
    grid_labels_mtx = zeros(num_x, num_y);

    num_points_added = 1;
    index = 1;
    for i=1:num_x
        for j=1:num_y
            current_points = points_per_bin{i,j};
            num_points = size(current_points, 1);
            labels = ones(num_points,1)*index;
            
            grid_point_cloud(num_points_added:num_points_added+num_points-1, 1:3) = current_points(:, 1:3);
            grid_point_cloud(num_points_added:num_points_added+num_points-1, 4) = labels;
            
            grid_labels_mtx(i,j) = index;
            num_points_added = num_points_added + num_points;
            index = index+1;
        end
    end

    save(gc_data_path, 'grid_point_cloud', 'grid_labels_mtx');
end

% figure
% pcshow(grid_point_cloud(:,1:3), gridLabels)
% colormap("lines")

end