function[features, labels] = extract_dataset_feature_vectors()

% Obtain paths and labels of training data
[paths, labels] = get_trainingdata_paths();

for i = 1:length(paths)
    I = imread(paths(i));
    features(i,:) = extractHOGFeatures(I);
end

