% function boxes = slider(frame, increment)
increment = 8;

frame = imread('frame_image.jpg');
[~, x, m] = size(frame);    % get frame dimensions

bb_size = 64;    % bounding box size
ws = [80, 120, 160, 180, 210];  % Window Size
wp = [410, 390, 380, 380, 400]; % Window Position
y = wp;
y_end = wp + ws;    % End of window in y direction

scalar = ws / bb_size; % Strip scalar to match bounding box dimensions
w = round(x ./ scalar); % Scale strip width

boxes = [];
% Sliding Windows
for i = 1:length(wp)  
    strip = frame(y(i):y_end(i), :, :);    % Strip to search for cars in
    strip = imresize(strip, [bb_size w(i)]); % Resize strip for hog detection
    [ys, xs, ~] = size(strip);  % Get strip dimensions
    
    strip_fv = hog_hsv(strip);  % Calculate HOG feature vector of strip
    
    x_end = (floor(xs/bb_size) - 1) * bb_size; % Get maximum x_end divisible by bounding box size
    
    % Show image strips
    subplot(5,1,i);
    imshow(strip);
    
    % Slide/Increment window across window column. x_rs = x resized
    for x_rs = 1:increment:x_end        
        features = zeros(3, 1296);
        % Slice strip feature vector to 64x64 window size feature vector (Same size as SVM pics)
        for c = 0:m-1
            ind_per_channel = length(strip_fv) / 3;  % Indices per channel
            ind_per_block = 36;   % Indices per block
            blocks_per_row = (x_end - 16) / 8;
            num_rows = 6;
            blocks_per_window = 6;
            ind_per_window = ind_per_block * blocks_per_window; % 216
            ind_per_row = ind_per_block * blocks_per_row; % 4536
            
            fv_row = zeros(6,216);
            for row = 0:num_rows-1
                fv_start = ind_per_channel*c + ind_per_row*row + ind_per_block*((x_rs-1)/8)  + 1;
                fv_end = fv_start + ind_per_window - 1;
                fv_row(row + 1, :) = strip_fv(fv_start:fv_end)';
            end    
            fv_row = reshape(fv_row, 1, []);
            features(c + 1, :) = fv_row;
        end
        features = reshape(features,[],1);
        
        % Check if current window is a car or not. If it is, return position and size of window
        if classifier(features) == 1
            xb = scalar(i) * x_rs;
            yb = y(i);
            wb = ws(i);
            boxes = [boxes; xb yb wb];
        end
    end
    
end
figure;
imshow(frame);

boxes = boxes'
for iter = 1:length(boxes)
    x = boxes(1, iter);
    y = boxes(2, iter);
    w = boxes(3, iter);
    h = boxes(1, iter);
    pos = [x y w h];
    rectangle('Position', pos, 'EdgeColor', 'r');  
end
