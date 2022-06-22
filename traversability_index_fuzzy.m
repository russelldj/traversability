function [gridMap] = traversability_index_fuzzy(slopeScore, roughnessScore, resolution)
    % Default arguments
    if nargin < 4
        resolution = 1;
    end

    traversability_fis = readfis("variable data/traversability_fis_new.fis");
    disp("Calculating Index")

    [rows, cols] = size(roughnessScore);

    % Flatten data for easier processing
    flat_roughness = reshape(roughnessScore, [], 1);
    flat_slope = reshape(slopeScore, [], 1);

    % Find non-nan values, meaning they are valid
    valid_roughness = ~isnan(flat_roughness);
    valid_slope = ~isnan(flat_slope);

    % Only take samples where both the slope and roughness are valid
    valid_inds = valid_roughness & valid_slope;

    % Index the original data to get the valid samples
    valid_roughnesses = flat_roughness(valid_inds);
    valid_slopes = flat_slope(valid_inds);
    % Concatenate to provide as input to the Fuzzy Inference System
    fis_inputs = [valid_slopes, valid_roughnesses];

    fis_outputs = evalfis(traversability_fis, fis_inputs);
    % Traversability is defined as 1 - the cost
    traversability_score = 1 - fis_outputs;

    % Set the output map to all zeros
    output_index = zeros(rows * cols, 1);
    % And then fill in the valid results
    output_index(valid_inds) = traversability_score;
    % Reshape back to a 2-D grid
    output_index = reshape(output_index, [rows, cols]);
    % Create an occupancy map from this data
    gridMap = occupancyMap(output_index, resolution);
end
