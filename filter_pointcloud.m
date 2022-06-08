function [ground_points, nonground_points] = filter_pointcloud(pc_path)
%% Filter Point Cloud
base_name = split(pc_path, '.');
base_name = base_name(1);
ground_path = strcat(base_name, '_ground_points.txt');
nonground_path = strcat(base_name, '_non_ground_points.txt');

if isfile(ground_path) && isfile(nonground_path) && false
    %% Load Datas
    disp("Loading Ground and Non-ground Point Clouds : " + base_name)
    ground_points = importdata(ground_path);
    nonground_points = importdata(nonground_path);
else
    %% Process Data
    disp("Processing Point Cloud : " + base_name)
    point_cloud = readmatrix(pc_path);

    %% CSF
    % tic
    % [ground_index, nonground_index] = csf_filtering(point_cloud,3,true,1,0.5,500,0.65);
    % toc
    % groundPoints = point_cloud(ground_index, :);
    % nonGroundPoints = point_cloud(nonground_index, :);
    % ground_cloud = pointCloud(groundPoints);
    % nonground_cloud = pointCloud(nonGroundPoints);

    %% SMRF
    tic
    full_cloud = pointCloud(point_cloud(:, 1:3));
    [ground_points_index, nonground_cloud, ground_cloud] = segmentGroundSMRF(full_cloud);
    toc

    ground_points = point_cloud(ground_points_index, 1:3);
    nonground_points = point_cloud(~ground_points_index, 1:3);

    save(ground_path{1}, 'ground_points')
    save(nonground_path{1}, 'nonground_points')

    figure;
    pcshowpair(ground_cloud, nonground_cloud)
    title('Point Cloud - Filtered')

    % figure;
    % subplot(1,2,1)
    % pcshow(full_cloud(:,1:3))
    % title('Point Cloud - Original')
    % subplot(1,2,2)
    % pcshow(ptCloud(:,1:3), ptCloud(:,4))
    % title('Point Cloud - Filtered')
end
end