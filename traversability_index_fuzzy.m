function [gridMap] = traversability_index_fuzzy(slopeScore, roughnessScore, elevModel_labels, resolution)

% Default arguments
if nargin < 4
    resolution = 1;
end

% fuzzy_data_path = 'variable data/fuzzy_dem_data.mat';
% override = false;
% if ~isfile(fuzzy_data_path) || override
%     disp("Evaluating Roughness and Slope Membership Functions")
%     % minr = min(roughnessScore, [], 'all', 'omitnan');
%     % maxr = max(roughnessScore, [], 'all', 'omitnan');
%     %
%     % mins = min(slopeScore, [], 'all', 'omitnan');
%     % maxs = max(slopeScore, [], 'all', 'omitnan');
%
%     %% Normalization and dealing with NaN
%     roughnessScore = normalize(roughnessScore, 'range');
%     slopeScore = normalize(slopeScore, 'range');
%     roughnessScore(isnan(roughnessScore)) = -1;
%     slopeScore(isnan(slopeScore)) = -1;
%
%     %% Membership Functions
%     rmf = [
%         fismf("trapmf", [0 0 0.2 0.4], "Name", "smooth");
%         fismf("trapmf", [0.35 0.5 0.6 0.8],"Name", "rough");
%         fismf("trapmf", [0.75 0.85 1 1], "Name", "rocky")];
%
%     smf = [
%         fismf("trapmf", [0 0 0.15 0.25], "Name", "flat"),
%         fismf("trapmf", [0.15 0.4 0.6 0.8],"Name", "sloped"),
%         fismf("trapmf", [0.70 0.85 1 1], "Name", "steep")];
%
%     %% Evaluating MFs
%     [rows, cols] = size(roughnessScore);
%     roughIndex = zeros(rows, cols, 3);
%     slopeIndex = zeros(rows, cols, 3);
%
%     for i=progress(1:rows)
%         for j=1:cols
%             if roughnessScore(i, j) >= 0   % Both roughness and slope have -1 at same indexes
%                 roughIndex(i, j, :) = evalmf(rmf, roughnessScore(i, j));
%                 slopeIndex(i, j, :) = evalmf(smf, slopeScore(i, j));
%             else
%                 roughIndex(i, j, :) = nan;   % -1 indicates unknown
%                 slopeIndex(i, j, :) = nan;
%             end
%         end
%     end
%
%     save(fuzzy_data_path, 'roughIndex', 'slopeIndex')
% else
%     disp("Loading Roughness and Slope Indexes")
%     load(fuzzy_data_path, 'roughIndex', 'slopeIndex')
% end

%% Index Membership Function
% omf = [
%     fismf("gaussmf", [0.15 0], "Name", "high");
%     fismf("gaussmf", [0.15 0.5],"Name", "medium");
%     fismf("gaussmf", [0.15 1], "Name", "low")];

% travers_rules = [
%     "High Travers. if Flat and Smooth",
%     "Medium Travers. if (Sloped and Smooth or Rocky) or (Rough and Flat or Sloped)" ,
%     "Low Travers. if Rocky or Steep"];

%% Traversability Index Calculation
% disp("Calculating Index")
% [rows, cols] = size(roughnessScore);
% gridMap = occupancyMap(rows, cols, 0.3, 'grid');
% for i=progress(1:rows)
%     for j=1:cols
%         if ~isnan(roughIndex(i, j, :))
%             r = slopeIndex(i, j, :);
%             s = roughIndex(i, j, :);
%
%             disp(r);
%             disp(s);
%
%             high = min(r(1), s(1));
%             med = max(min(s(2), max(r(1), r(2))), min(r(2), max(s(1), s(2))));
%             low = max(r(3), s(3));
%
%             disp(high)
%             disp(med)
%             disp(low)
%
%             inference = [high; med; low];
%             disp(inference)
%             index = defuzz(inference, omf, 'centroid');
%             setOccupancy(gridMap, grid2local(gridMap,[i, j]), index);
%         else
%             setOccupancy(gridMap, grid2local(gridMap,[i, j]), 1);
%         end
%     end
% end

traversability_fis = readfis("variable data/traversability_fis_new.fis");
disp("Calculating Index")
roughnessScore = normalize(roughnessScore, 'range');
slopeScore = normalize(slopeScore, 'range');
[rows, cols] = size(roughnessScore);


flat_roughness = reshape(roughnessScore, [], 1);
flat_slope = reshape(slopeScore, [], 1);
flat_labels = reshape(elevModel_labels, [], 1);

valid_roughness = ~isnan(flat_roughness);
valid_slope = ~isnan(flat_slope);
valid_labels = flat_labels == 0;
% TODO should we be checking slope validity which wasn't done previously
valid_inds = valid_roughness & valid_labels & valid_slope;

valid_roughnesses = flat_roughness(valid_inds);
valid_slopes = flat_slope(valid_inds);
fis_inputs = [valid_roughnesses, valid_slopes];
fis_outputs = evalfis(traversability_fis, fis_inputs);
traversability_score = 1 - fis_outputs;

output_index = ones(rows * cols, 1);
output_index(valid_inds) = traversability_score;
output_index = reshape(output_index, [rows, cols]);

gridMap = occupancyMap(output_index, resolution);
end
