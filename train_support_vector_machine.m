%function train_support_vector_machine()
clear; close; clc;
%% Retrieve dataset
% Contains 17760 images classified as car(1) or not car(0). 
% Each sample has 1764 features. Features(17760,1764), labels(17760,1)
fprintf('Starting')

[features, labels] = extract_dataset_feature_vectors();

clearvars -except features labels
[num_rows, num cols] = size(features);

fprintf('got here')
%% Divide test set in to training and validation 80/20 (X=features, y=labels)
% We will turn 80 of our data set to training data and 20% to validation data.
% X_train = features(1:floor(0.8*num_rows), :);
% y_train = labels(1:1:floor(0.8*num_rows), :);

% X_test = features(floor(0.8*num_rows)+1:end, :);
% y_test = labels(floor(0.8*num_rows)+1:end, :);

X_train = features(1:800, :);
y_train = labels(1:800, :);
X_test = features(801:1000, :);
y_test = labels(801:1000, :);


%% Preparing validation set out of training set (K-fold cross validation)
% Constructs an object c out of a random nonstratified partition for k-fold cross-validation on n observations.
c = cvpartition(y_train,'k',5);   

%% Feature Selection
% Extracts 2 random features to
opts = statset('disp','iter');

fun = @(train_data, train_labels, test_data, test_labels)...
    sum(predict(fitcsvm(train_data, train_labels, 'KernelFunction', 'rbf'), test_data) ~= test_labels);

[fs, history] = sequentialfs(fun, X_train, y_train, 'cv', c, 'options', opts, 'nfeatures', 2);

%% Best hyperparameters

X_train_with_best_features = X_train(:,fs);

% Train binary support vector machine classifier
Md1 = fitcsvm(X_train_with_best_features, y_train, 'KernelFunction', 'rbf', 'OptimizeHyperparameters', 'auto',...
    'HyperparameterOptimizationOptions', struct('AcquisitionFunctionName','expected-improvement-plus','ShowPlots', true));
fprintf('got here 5')

%% Test model with test set

X_test_with_best_feature = X_test(:,fs);
accuracy = sum(predict(Md1, X_test_with_best_feature) == y_test)/length(y_test)*100;

%% HyperPlane

figure;
hgscatter = gscatter(X_train_with_best_features(:,1), X_train_with_best_features(:,2), y_train);
hold on;
h_sv = plot(Md1.SupportVectors(:,1),Md1.SupportVectors(:,2), 'ko','MarkerSize',8);


% decision plane
XLIMs = get(gca,'xlim');
YLIMs = get(gca,'ylim');
[xi,yi] = meshgrid([XLIMs(1):0.01:XLIMs(2)],[YLIMs(1):0.01:YLIMs(2)]);
dd = [xi(:), yi(:)];
pred_mesh = predict(Md1, dd);
redcolor = [1, 0.8, 0.8];
bluecolor = [0.8, 0.8, 1];
pos = find(pred_mesh == 1);
h1 = plot(dd(pos,1), dd(pos,2),'s','color',redcolor,'Markersize',5,'MarkerEdgeColor',redcolor,'MarkerFaceColor',redcolor);
pos = find(pred_mesh == 2);
h2 = plot(dd(pos,1), dd(pos,2),'s','color',bluecolor,'Markersize',5,'MarkerEdgeColor',bluecolor,'MarkerFaceColor',bluecolor);
uistack(h1,'bottom');
uistack(h2,'bottom');
legend([hgscatter;h_sv],{'car','not car','support vectors'})