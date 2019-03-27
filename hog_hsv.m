function feature_vector_total = hog_hsv(im)

%%
% im = imread('test_image.png');
hsv = rgb2hsv(im);
hsv = round(hsv*256);
% hsv = double(im);
[~, ~, m] = size(hsv);

feature_vector_total = [];
for c=1:m
    hsv_channel = hsv(:, :, c);
    
    % Returns 1296 size feature histogram (9 bins * 2x2 cells * 6x6 blocks)
    feature_vector = get_hog_features(hsv_channel);
    
    feature_vector_total = cat(2, feature_vector_total, feature_vector);
end

feature_vector_total = reshape(feature_vector_total, [], 1);

