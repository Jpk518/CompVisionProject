% function[features, labels] = extract_dataset_feature_vectors()

% Obtain paths and labels of training data
[paths, labels] = get_trainingdata_paths();

for i = 1:length(paths)
    I = imread(paths(i));
    hsv_image = rgb2hsv(I);
    feature_vector_hsv = [];
    for j=1:3
        feature_vector = extractHOGFeatures(hsv_image(:,:,j));
        feature_vector_hsv = cat(2, feature_vector_hsv, feature_vector);
    end
    features(i,:) = feature_vector_hsv;
end

