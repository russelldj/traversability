function [gridMap] = traversability_index(slopeScore, roughnessScore, elevModel_labels, resolution, nan_value)

% Default values
if nargin < 5
    nan_value = 0.5;
end

if nargin < 4
    resolution = 1;
end

% TODO Figure out why this clipping is needed
output_score = min(slopeScore, 1);
is_occupied = slopeScore == 1 | roughnessScore == 1 | elevModel_labels == 1;
slope_is_nan = isnan(slopeScore);
output_score(is_occupied) = 1;
output_score(slope_is_nan) = nan_value;
imshow(output_score)

gridMap = occupancyMap(output_score, resolution);

end