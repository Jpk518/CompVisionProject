function[features, labels] = extract_dataset_feature_vectors()

% Obtain paths and labels of training data
[paths, labels] = get_trainingdata_paths();

features = zeros(length(paths), 3888);
for i = 1:length(paths)
    % Read each image from path
    c_path = convertStringsToChars(paths(i));
    im = imread(c_path);
    
    feature_vector_im = hog_hsv(im);
    
    % Append the current image feature vector to a matrix
    features(i,:) = feature_vector_im;
end
