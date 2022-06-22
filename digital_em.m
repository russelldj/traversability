function [gridMap] = digital_em(gridPtCloud, plot_dem_data, fuzzy, resolution, roughness_method, roughness_kernel_size)
    %% Generate DEM from point cloud

    % Default arguments
    if nargin <= 5
        roughness_method = 'srf';
    end

    if nargin <= 6
        roughness_kernel_size = 5;
    end

    ground_inds = gridPtCloud(:, 4) == 0;
    ground_points = gridPtCloud(ground_inds, 1:5);

    elevModel = pc2dem(pointCloud(gridPtCloud(:, 1:3)), [resolution, resolution]);
    % Finds what fraction of the points are ground
    elevModel_labels = pc2dem(pointCloud([gridPtCloud(:, 1:2), gridPtCloud(:, 4)]), [resolution, resolution]);

    min_points = min(gridPtCloud(:, 1:3), [], 1);
    max_points = max(gridPtCloud(:, 1:3), [], 1);
    mean_z = mean(gridPtCloud(:, 3), 1);

    additional_points = [[min_points(1), min_points(2), mean_z]; ...
                        [min_points(1), max_points(2), mean_z]; ...
                        [max_points(1), min_points(2), mean_z]; ...
                        [max_points(1), max_points(2), mean_z]];
    % HACK append the additional points to the DEM to ensure the size is the
    % same
    groundModel = pc2dem(pointCloud([ground_points(:, 1:3); additional_points]), [resolution, resolution]);

    X = 0:size(elevModel, 2) - 1;
    Y = 0:size(elevModel, 1) - 1;

    if plot_dem_data
        figure
        subplot(1, 2, 1)
        imshow(elevModel, [])
        colorbar()
        title("Digital Terrain Model")
        subplot(1, 2, 2)
        imshow(elevModel_labels, [])
        colorbar()
        title("Labels")
    end

    full_DEM = GRIDobj(X, Y, elevModel);
    ground_DEM = GRIDobj(X, Y, groundModel);

    if plot_dem_data
        figure
        imageschs(full_DEM)
    end

    %% Traversability Roughness
    % TODO Should roughness be computed from the full DEM?
    R = roughness(full_DEM, roughness_method, [roughness_kernel_size, roughness_kernel_size]);
    roughnessScore = R.Z;

    % Normalize the roughness appropriately so that it lies in the range [0, 1] with
    % 0 being the smoothest surface
    if roughness_method == "roughness"
        roughnessScore = min(max(roughnessScore / 10, 0), 1);
    elseif roughness_method == "tri"
        % TODO
    elseif roughness_method == "tpi"
        % TODO
    elseif roughness_method == "ruggedness"
        % TODO
    elseif roughness_method == "srf"
        roughnessScore = 1 - roughnessScore;
    end

    %% Traversability Slope
    % Get the slope in radians using an 8-connected grid
    G = gradient8(ground_DEM, 'rad');
    slopeScore = G.Z;

    % Visualize the slope, roughness, and DEM
    if false
        figure
        imshow(full_DEM.Z, [])
        colorbar()
        title("DEM Z, min: " + string(min(full_DEM.Z, [], 'all')) + " , max: " + string(max(full_DEM.Z, [], 'all')))

        figure
        imshow(slopeScore, [])
        colorbar()
        title("slopeScore, min: " + string(min(slopeScore, [], 'all')) + " , max: " + string(max(slopeScore, [], 'all')))

        figure
        imshow(roughnessScore, [])
        colorbar()
        title("roughnessScore, min: " + string(min(roughnessScore, [], 'all')) + " , max: " + string(max(roughnessScore, [], 'all')))
    end

    if plot_dem_data
        figure
        imageschs(full_DEM, slopeScore, 'ticklabel', 'nice', 'colorbarylabel', 'Slope')
        figure
        imageschs(full_DEM, roughnessScore, 'ticklabel', 'nice', 'colorbarylabel', 'Roughness')
    end

    %% Traversability Index
    if ~fuzzy
        disp("Heuristic Traversability DEM")
        gridMap = traversability_index(slopeScore, roughnessScore, elevModel_labels, resolution);
        figure;
        show(gridMap);
        title("Heuristic Grid Map")
    else
        disp("Fuzzy Traversability DEM")
        gridMap = traversability_index_fuzzy(slopeScore, roughnessScore);
        figure;
        show(gridMap);
        title("Fuzzy Grid Map")
    end

end
