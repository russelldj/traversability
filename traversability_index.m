function [occupancy, gridMap] = traversability_index(slopeScore, roughnessScore, elevModel_labels, resolution, nan_value)

    % Default values
    if nargin < 5
        nan_value = 1;
    end

    if nargin < 4
        resolution = 1;
    end

    % By default, it's mostly based on the slope
    occupancy = min(slopeScore, 1);
    is_occupied = slopeScore == 1 | roughnessScore == 1 | elevModel_labels == 1;
    slope_is_nan = isnan(slopeScore);
    occupancy(is_occupied) = 1;
    occupancy(slope_is_nan) = nan_value;

    gridMap = occupancyMap(occupancy, resolution);

end
