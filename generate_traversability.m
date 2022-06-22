function generate_traversability(data_dir, data_name, plot_data, fuzzy, resolution)

    %% Deal with default arguments
    if nargin < 5
        resolution = 0.3;
    end

    if nargin < 4
        fuzzy = true;
    end

    if nargin < 3
        plot_data = true;
    end

    %% Add Libraries
    addpath(genpath('usrFunctions'))

    %% Path and Data
    data_path = fullfile(data_dir, strcat(data_name, '.txt'));

    %% Filter Ground and Non-ground points
    [ground_points, nonground_points] = filter_pointcloud(data_path, true);
    % Label ground points as 0 and nonground as 1
    point_cloud_points = [
                    [ground_points(:, 1:3), zeros(length(ground_points), 1)];
                    [nonground_points(:, 1:3), ones(length(nonground_points), 1)]
                    ];

    %% Grid Cloud
    [grid_point_cloud, grid_labels_mtx] = grid_cloud(point_cloud_points, data_path, resolution);

    %% Digital Elevation Map Traversability
    map = digital_em(grid_point_cloud, plot_data, fuzzy, resolution);
end
