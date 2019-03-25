%function train_support_vector_machine()
clear; close; clc;

%% Retrieve feature vector matrix
% Contains 17760 images classified as car(1) or not car(0). Each sample has 3888 features. Features(17760, 3888), labels(17760,1)
fprintf('Starting\n')
if exist('feature_vectors.mat', 'file') == 2
    fprintf('Loading feature vectors\n')
    load('feature_vectors.mat')
else
    fprintf('Creating feature vectors\n')
    [features, labels] = extract_dataset_feature_vectors();
end

% features = zscore(features);  % Normalize features

[num_rows, num_cols] = size(features);
X_train = features(1:floor(0.8*num_rows), :);
y_train = labels(1:1:floor(0.8*num_rows), :);
X_test = features(floor(0.8*num_rows)+1:end, :);
y_test = labels(floor(0.8*num_rows)+1:end, :);
y_train(y_train == 0) = y_train(y_train == 0) - 1;
fprintf('Creating Initial Model\n');

Mdl = fitclinear(X_train', y_train','ObservationsIn','columns','Solver','sparsa',...
    'OptimizeHyperparameters','auto','HyperparameterOptimizationOptions',...
    struct('AcquisitionFunctionName','expected-improvement-plus'));

fprintf(' Finished creating initial model\n');
                
fprintf('Creating cross validation model \n')


save('SVM','Mdl')