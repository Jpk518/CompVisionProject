function is_car = classifier(features)
% Load svm model for classification
load('SVM.mat')
% im = imread('test_image2.png');
% features = hog_hsv(im);

features = reshape(features, 1, []);
best_features = features(:, fs);
is_car = predict(model, best_features);

if is_car == 1
    fprintf("Is Car\n")
else
    fprintf('Is Not Car\n')
end



 
