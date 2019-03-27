function is_car = classifier(features)
% Load svm model for classification
load('SVM.mat');
% im = imread('wc.png');
% im = imresize(im, [64 64]);
% features = hog_hsv(im);

features = reshape(features, 1, []);    

[is_car,score] = predict(Mdl, features);

if score(2) < 0.97
    is_car = 0;
end

% if is_car == 1%
%     fprintf("Is Car %i   ", score(2))
% else
%     fprintf('Is Not Car %i \n', score(1))
% end
% 


 
