function [gridMap] = traversability_index_fuzzy(slopeScore, roughnessScore, resolution)
    % elevModel_labels is something to do with the fraction of ground points

    % Default arguments
    if nargin < 4
        resolution = 1;
    end

    traversability_fis = readfis("variable data/traversability_fis_new.fis");
    disp("Calculating Index")

    [rows, cols] = size(roughnessScore);

    flat_roughness = reshape(roughnessScore, [], 1);
    flat_slope = reshape(slopeScore, [], 1);

    %figure
    %imshow(roughnessScore, [])
    %figure
    % For some reason they appear transposed
    %imshow(elevModel_labels, [])

    valid_roughness = ~isnan(flat_roughness);
    valid_slope = ~isnan(flat_slope);

    % TODO should we be checking slope validity which wasn't done previously
    valid_inds = valid_roughness & valid_slope;

    valid_roughnesses = flat_roughness(valid_inds);
    valid_slopes = flat_slope(valid_inds);
    fis_inputs = [valid_slopes, valid_roughnesses];
    %test_input = (1:sum(valid_inds))/sum(valid_inds);
    %fis_inputs = transpose([test_input; test_input]);
    fis_outputs = evalfis(traversability_fis, fis_inputs);
    traversability_score = 1 - fis_outputs;

    output_index = zeros(rows * cols, 1);
    output_index(valid_inds) = traversability_score;
    output_index = reshape(output_index, [rows, cols]);

    gridMap = occupancyMap(output_index, resolution);
end
