%% TEST Human Unimodality Figures %%%%%%%%%%
% written 02/16/23 - Adam Tiesman
clear;
close all;
sca;

% Version info
Version = 'TEST_Human_Visual_v.1.1' ; % after code changes, change version
file_directory = '/Users/a.tiesman/Documents/Research/Human_AV_Motion/Psychometric_Function_Plot';
data_file_directory = '/Users/a.tiesman/Documents/Research/Human_AV_Motion/Psychometric_Function_Plot';
figure_file_directory = '/Users/a.tiesman/Documents/Research/Human_AV_Motion/Psychometric_Function_Plot/Human_Figures';

% Load the experimental data
load("RDKHoop_stairVis_23_23_03_23.mat");

% Provide specific variables 
chosen_threshold = 0.72; % Ask Mark about threshold
right_var = 1;
left_var = 2;
catch_var = 0;
save_name = 'stairVis_23_23_03_23';

% Replace all the 0s to 3s for catch trials for splitapply
data_output(data_output(:, 1) == 0, 1) = 3; 

% Replace coherence levels percentages (0-1) to whole number integers (1-5)
% Find the unique values in column 2
unique_vals = unique(data_output(:, 2));

% Initialize a map to keep track of which values have been assigned an integer
val_map = containers.Map('KeyType', 'double', 'ValueType', 'double');

% Initialize a counter variable
counter = 1;

% Loop through the unique values in column 2
for i = 1:length(unique_vals)
    % Get the current value
    curr_val = unique_vals(i);
    
    % Check if the current value has already been assigned an integer
    if isKey(val_map, curr_val)
        % If so, assign the same integer as the previous occurrence
        data_output(data_output(:, 2) == curr_val, 2) = val_map(curr_val);
    else
        % Otherwise, assign a new integer and update the map
        data_output(data_output(:, 2) == curr_val, 2) = counter;
        val_map(curr_val) = counter;
        counter = counter + 1;
    end
end

% Group trials based on stimulus direction--> 1 = right, 2 = left, 3 = catch
right_or_left = data_output(:, 1);
right_vs_left = splitapply(@(x){x}, data_output, right_or_left);

% Isolate coherences for right and left groups and catch
right_group = findgroups(right_vs_left{1,1}(:,2));
left_group = findgroups(right_vs_left{2,1}(:,2));
if size(right_vs_left, 1) >= 3 && size(right_vs_left{3,1}, 2) >= 2
    catch_group = findgroups(right_vs_left{3,1}(:,2));
end

%Initialize an empty array to store rightward_prob for all coherences
rightward_prob = [];

% Loop over each coherence level and extract the corresponding rows of the matrix for
% i = max(left_group):-1:1 for leftward trials
for i = max(left_group):-1:1
    group_rows = right_vs_left{2,1}(left_group == i, :);
    logical_array = group_rows(:, 3) == left_var;
    count = sum(logical_array);
    percentage = 1 - (count/ size(group_rows, 1));
    rightward_prob = [rightward_prob percentage];
end

% Add to the righward_prob vector the catch trials
if size(right_vs_left, 1) >= 3 && size(right_vs_left{3,1}, 2) >= 2
    group_rows = right_vs_left{3,1};
    logical_array = group_rows(:, 3) == right_var;
    count = sum(logical_array);
    percentage = (count/ size(group_rows, 1));
    rightward_prob = [rightward_prob percentage];
end

% Loop over each coherence level and extract the corresponding rows of the matrix for
% i = 1:max(right_group) for rightward trials
for i = 1:max(right_group)
    group_rows = right_vs_left{1,1}(right_group == i, :);
    logical_array = group_rows(:, 3) == right_var;
    count = sum(logical_array);
    percentage = count/ size(group_rows, 1);
    rightward_prob = [rightward_prob percentage];
end

% Create vector of coherence levels
right_coh_vals = right_vs_left{1,1}(:, 2);
left_coh_vals = -right_vs_left{2,1}(:, 2);
combined_coh = [right_coh_vals; left_coh_vals];
coherence_lvls = sort(combined_coh, 'ascend');
coherence_lvls = unique(coherence_lvls, 'stable')';

% Create a Normal Cumulative Distribution Function (NormCDF)
normCDF_plotter(coherence_lvls, rightward_prob, chosen_threshold, left_coh_vals, right_coh_vals, save_name);

% Create a stairstep graph for visualizing staircase
stairstep_plotter(data_output);
