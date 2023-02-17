%% TEST Human Visual Figures %%%%%%%%%%
% written 02/16/23 - Adam Tiesman
clear;
close all;
sca;

% Version info
Version = 'TEST_Human_Visual_v.1.0' ; % after code changes, change version
file_directory = '/Users/a.tiesman/Documents/Research/Human_AV_Motion/Psychometric_Function_Plot';
data_file_directory = '/Users/a.tiesman/Documents/Research/Human_AV_Motion/Psychometric_Function_Plot';
figure_file_directory = '/Users/a.tiesman/Documents/Research/Human_AV_Motion/Psychometric_Function_Plot/Human_Figures';

% Add the experimental data to path
load("RDKHoop_psyVis_01_01_02_24.mat");

% Provide specific variables 
chosen_threshold = 0.72; %Ask Mark about threshold

% Replace all the 0s to 3s for catch trials for splitapply
data_output(data_output(:, 1) == 0, 1) = 3; 

%Group trials based on stimulus direction--> 1 = right, 2 = left, 3 = catch
right_or_left = data_output(:, 1);
right_vs_left = splitapply(@(x){x}, data_output, right_or_left);

% Isolate coherences for right and left groups
right_group = findgroups(right_vs_left{1,1}(:,2));
left_group = findgroups(right_vs_left{2,1}(:,2));
catch_group = findgroups(right_vs_left{3,1}(:,2));

%Initialize an empty array to store rightward_prob for all coherences
rightward_prob = [];

% Loop over each coherence level and extract the corresponding rows of the matrix for
% i = max(groups):-1:1 for leftward trials
for i = max(left_group):-1:1
    group_rows = right_vs_left{2,1}(left_group == i, :);
    left_var = 2;
    logical_array = group_rows(:, 3) == left_var;
    count = sum(logical_array);
    percentage = 1 - (count/ size(group_rows, 1));
    rightward_prob = [rightward_prob percentage];
end

% Add to the righward_prob vector the catch trials
group_rows = right_vs_left{3,1};
right_var = 1;
logical_array = group_rows(:, 3) == right_var;
count = sum(logical_array);
percentage = (count/ size(group_rows, 1));
rightward_prob = [rightward_prob percentage];

% Loop over each coherence level and extract the corresponding rows of the matrix for
% i = 1:max(groups) for rightward trials
for i = 1:max(right_group)
    group_rows = right_vs_left{1,1}(right_group == i, :);
    right_var = 1;
    logical_array = group_rows(:, 3) == right_var;
    count = sum(logical_array);
    percentage = count/ size(group_rows, 1);
    rightward_prob = [rightward_prob percentage];
end

% Display prob of right response at each coherence from -5 to 5 (neg being
% leftward trials and pos being rightward trials)
coherence_lvls = [-5, -4, -3, -2, -1, 0, 1, 2, 3 , 4, 5];
scatter(coherence_lvls, rightward_prob);

% Add title and labels to the x and y axis
xlabel('Coherence Level');
ylabel('Rightward Response Probability');
title('TEST Human Visual Psychometric Plot');

