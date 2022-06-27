function generate_traversability( ...
        data_dir, ...
        data_name, ...
        fuzzy, ...
        resolution, ...
        roughness_method, ...
        roughness_kernel_size_meters, ...
        pointcloud_crop_height, ...
        use_csf_groundplane_filtering, ...
        show_plots, ...
        show_pointcloud)

    % CLose all other figure by default
    close all;

    %% Deal with default arguments
    if nargin < 10
        show_pointcloud = true;
    end

    if nargin < 9
        show_plots = true;
    end

    if nargin < 8
        use_csf_groundplane_filtering = false;
    end

    if nargin < 7
        pointcloud_crop_height = 3;
    end

    if nargin < 6
        roughness_kernel_size_meters = 3;
    end

    if nargin < 5
        roughness_method = "srf";
    end

    if nargin < 4
        resolution = 0.3;
    end

    if nargin < 3
        fuzzy = true;
    end

    % Compute the number of grid cells to use to compute roughness
    roughness_kernel_size_inds = ceil(roughness_kernel_size_meters / resolution);

    %% Add Libraries
    addpath(genpath('usrFunctions'))

    %% Path and Data
    data_path = fullfile(data_dir, strcat(data_name, '.txt'));

    %% Filter Ground and Non-ground points
    [ground_points, nonground_points] = filter_pointcloud(data_path, ...
    show_pointcloud, ...
        use_csf_groundplane_filtering);
    % Label ground points as 0 and nonground as 1
    point_cloud_points = [
                    [ground_points(:, 1:3), zeros(length(ground_points), 1)];
                    [nonground_points(:, 1:3), ones(length(nonground_points), 1)]
                    ];

    %% Grid Cloud
    [grid_point_cloud, ~] = grid_cloud(point_cloud_points, ...
    data_path, ...
        resolution, ...
        pointcloud_crop_height, ...
        show_pointcloud);

    %% Digital Elevation Map Traversability
    map = digital_em(grid_point_cloud, ...
    show_plots, ...
        fuzzy, ...
        resolution, ...
        roughness_method, ...
        roughness_kernel_size_inds);
end
