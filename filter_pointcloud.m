function [ground_points, nonground_points] = filter_pointcloud(pc_path, show, csf)

    if nargin < 3
        csf = false;
    end

    if nargin < 2
        show = false;
    end

    %% Savepaths
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
        tic

        if csf
            %% CSF
            [ground_index, nonground_index] = csf_filtering(point_cloud, 3, true, 1, 0.5, 500, 0.65);
            groundPoints = point_cloud(ground_index, :);
            nonGroundPoints = point_cloud(nonground_index, :);
            ground_cloud = pointCloud(groundPoints);
            nonground_cloud = pointCloud(nonGroundPoints);
        else
            %% SMRF

            full_cloud = pointCloud(point_cloud(:, 1:3));
            [ground_points_index, nonground_cloud, ground_cloud] = segmentGroundSMRF(full_cloud);

            ground_points = point_cloud(ground_points_index, 1:3);
            nonground_points = point_cloud(~ground_points_index, 1:3);
        end

        toc

        save(ground_path{1}, 'ground_points')
        save(nonground_path{1}, 'nonground_points')

        if show
            figure;
            pcshowpair(ground_cloud, nonground_cloud)
            title('Point Cloud - Filtered')
        end

    end

end
