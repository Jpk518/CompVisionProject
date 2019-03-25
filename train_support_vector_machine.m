%function train_support_vector_machine()
clear; close; clc;

%% Retrieve feature vector matrix
% Contains 17760 images classified as car(1) or not car(0). Each sample has 3888 features. Features(17760, 3888), labels(17760,1)
fprintf('Starting\n');
if exist('feature_vectors.mat', 'file') == 2
    fprintf('Loading feature vectors\n');
    load('feature_vectors.mat');
else
    fprintf('Creating feature vectors\n');
    [features, labels] = extract_dataset_feature_vectors();
    save('feature_vectors','features', 'labels');
end

% features = zscore(features);  % Normalize features

clearvars -except features labels  % Clean up workspace
% [num_rows, num_cols] = size(features);

%% Divide test set in to training and validation 80/20 (X=features, y=labels)
% We will turn 80 of our data set to training data and 20% to validation data.
% X_train = features(1:floor(0.8*num_rows), :);
% y_train = labels(1:1:floor(0.8*num_rows), :);
% 
% X_test = features(floor(0.8*num_rows)+1:end, :);
% y_test = labels(floor(0.8*num_rows)+1:end, :);

X_train = features(1:800, :);
y_train = labels(1:800, :);
X_test = features(801:1000, :);
y_test = labels(801:1000, :);

%% Feature Selection
% Preparing validation set out of training set (K-fold cross validation)
% Constructs an object c from cvpartition class out of a random nonstratified partition for k-fold cross-validation on n observations.
c = cvpartition(y_train, 'k', 10);   

opts = statset('disp','iter');

% Create a function handle fun to a function that defines criterion used to select features and to determine when to stop
fun = @(train_data, train_labels, test_data, test_labels)...
    sum( ...
         predict(fitcsvm(train_data, train_labels, 'KernelFunction', 'polynomial'), test_data) ~= test_labels);

% Sequential feature selection: Selects subset from X and best predicts y. In laymens terms, determine what variables to include
% by sequentialy selecting features until there is no improvement in prediction
% params:
%   fun: function handle
%   cv: validation method used to compute the criterion for each candidate feauture subset
%   options: options structure for iterative sequential search algorithm created by statset
%   nfeatures: number of features at which sequentialfs should stop
[fs, history] = sequentialfs(fun, X_train, y_train, ...
                             'cv', c, 'options', opts, 'nfeatures', 2);

%% Train Classifier With Best hyperparameters
X_train_w_best_features = X_train(:, fs);
   
% Train binary support vector machine classifier returning classification discrimination object Md1
model = fitcsvm(X_train_w_best_features, y_train, ...
             'KernelFunction', 'rbf', 'OptimizeHyperparameters', 'auto',...
             'HyperparameterOptimizationOptions', struct('AcquisitionFunctionName','expected-improvement-plus','ShowPlots', true));
         
%% Cross Validation - Testing Model with Test Set
X_test_with_best_feature = X_test(:, fs);
accuracy = sum(predict(model, X_test_with_best_feature) == y_test) / ...
           length(y_test) * 100;

%% Plot Hyperplane and other pertinent data
figure;

% Plot a scatter diagram of data and circle support vectors
hgscatter = gscatter(X_train_w_best_features(:,1), X_train_w_best_features(:,2), y_train);
hold on;
h_sv = plot(model.SupportVectors(:,1), model.SupportVectors(:,2), ...
            'ko', 'MarkerSize', 8);

% % decision plane
x_lims = get(gca, 'xlim'); % gca gets current axis for figure    
y_lims = get(gca, 'ylim');
% 
% %Create 3d grid
step = 0.01;
[xi, yi] = meshgrid(x_lims(1):step:x_lims(2), ...
                   y_lims(1):step:y_lims(2));
dd = [xi(:), yi(:)];
pred_mesh = predict(model, dd);
red = [1, 0.8, 0.8];
blue = [0.8, 0.8, 1];

pos = find(pred_mesh == 1); % Find indicies of non zero elements
h1 = plot(dd(pos,1), dd(pos, 2), ...
         's', 'color', red, 'Markersize', 5, ...
         'MarkerEdgeColor', red, 'MarkerFaceColor', red);
     
pos = find(pred_mesh == 2); % Find indicies of non zero elements
h2 = plot(dd(pos,1), dd(pos, 2), ...
          's', 'color', blue, 'Markersize', 5, ...
          'MarkerEdgeColor', blue, 'MarkerFaceColor', blue);
% 
% % Re order visual stacking of UI components
uistack(h1, 'bottom');
uistack(h2, 'bottom');

legend([hgscatter; h_sv], ...
       {'car', 'not car', 'support vectors'}) % Create a legend 
   
save('SVM','model', 'fs')