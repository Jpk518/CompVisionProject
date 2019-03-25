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

features = zscore(features);  % Normalize features

clearvars -except features labels  % Clean up workspace
[num_rows, num_cols] = size(features);

X_train = features(1:floor(0.8*num_rows), :);
y_train = labels(1:1:floor(0.8*num_rows), :);

X_test = features(floor(0.8*num_rows)+1:end, :);
y_test = labels(floor(0.8*num_rows)+1:end, :);

fprintf('Creating Initial Model\n')

Lambda = logspace(-6,-0.5,11);
CVMdl = fitclinear(X_train', y_train','ObservationsIn','columns','KFold',5,...
                    'Learner','logistic','Solver','sparsa','Regularization','lasso',...
                    'Lambda', Lambda,'GradientTolerance',1e-8);
                
fprintf(' Finished creating initial model\n')
                
numCLModels = numel(CVMdl.Trained);

Mdl1 = CVMdl.Trained{1};

ce = kfoldLoss(CVMdl);

fprintf('Creating cross validation model \n')

Mdl = fitclinear(X_train',y_train','ObservationsIn','columns','Solver','sparsa',...
    'OptimizeHyperparameters','auto','HyperparameterOptimizationOptions',...
    struct('AcquisitionFunctionName','expected-improvement-plus'))
numNZCoeff = sum(Mdl.Beta~=0);

figure;
[h,hL1,hL2] = plotyy(log10(Lambda),log10(ce),...
    log10(Lambda),log10(numNZCoeff)); 
hL1.Marker = 'o';
hL2.Marker = 'o';
ylabel(h(1),'log_{10} classification error')
ylabel(h(2),'log_{10} nonzero-coefficient frequency')
xlabel('log_{10} Lambda')
title('Test-Sample Statistics')
hold off


% save('SVM','MdlFinal')