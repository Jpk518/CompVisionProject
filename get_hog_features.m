% function hog = get_hog_features(im)
%% HOG algorithm Preprocessing and parameters 
pixels_per_cell = [8,8];
cells_per_block = [2,2];
num_bins = 9;

im = imread('test_image.png');
hsv = rgb2hsv(im);
[y,x,m] = size(hsv);

num_cells_x = x / pixels_per_cell(1);
num_cells_y = y / pixels_per_cell(2);

step_x = pixels_per_cell(1);
step_y = pixels_per_cell(2);

%% Image Gradiants
% Sobel operator derivative masks
dx =  [-1 -2 -1; 0 0 0; 1 2 1];
dy =  dx';

% Calculate the horizontal and vertical gradients using correlation with dx and dy
Ix= imfilter(hsv, dx); 
Iy= imfilter(hsv, dy);

% Gradiant Magnitude and direction
grad_mag = sqrt(Ix.^2 + Iy.^2);
grad_dir = rad2deg(atan2(Iy,Ix));
grad_dir = grad_dir - 0.001;
grad_dir(isnan(grad_dir)) = 0;    % Convert nan values from division by 0 to 0
grad_dir = abs(grad_dir);

%% Histogram of gradients in each cell
% Assign Bucket Values
left_bin = floor(abs(grad_dir / 20));
right_bin = mod(abs(floor(grad_dir / 20) + 1), num_bins);

left_val = grad_mag .* (right_bin .* 20 - grad_dir) ./ 20;
right_val = grad_mag .* (grad_dir - left_bin .* 20) ./ 20;

orient_bins = zeros(x*y, num_bins + 1);
cur_cell_num = 0;

% Divide image into cells
for i = 0:num_cells_y-1
    for j = 0:num_cells_x-1
        cur_cell_num = cur_cell_num + 1;
        cell_left_bin = left_bin(i*step_y+1:(i+1)*step_y, j*step_x+1:(j+1)*step_x);
        cell_right_bin = left_bin(i*step_y+1:(i+1)*step_y, j*step_x+1:(j+1)*step_x);
        cell_left_vals = left_val(i*step_y+1:(i+1)*step_y, j*step_x+1:(j+1)*step_x);
        cell_right_vals = right_val(i*step_y+1:(i+1)*step_y, j*step_x+1:(j+1)*step_x);

        cell_bin = zeros(num_bins, 1);

        for i1 = 1:pixels_per_cell(2)
            for j1 = 1:pixels_per_cell(1)
                cell_bin(cell_left_bin(i1,j1)+1) = cell_bin(cell_left_bin(i1,j1)+1) + cell_left_vals(i1,j1);
                cell_bin(cell_right_bin(i1,j1)+1) = cell_bin(cell_right_bin(i1,j1)+1) + cell_right_vals(i1,j1);
            end
        end
    end
end





% for i = 0:num_cells_y-1
%     for j = 0:num_cells_x-1
%         cur_cell_num = cur_cell_num +1;
%         
%         for i1 = 1:height
%             for j1 = 1:width
%                 orient_bins(cur_cell_num, left_bin(i1,j1)+1) = orient_bins(cur_cell_num, left_bin(i1,j1)+1) + left_val(i1,j1);
%                 orient_bins(cur_cell_num, right_bin(i1,j1)+1) = orient_bins(cur_cell_num, right_bin(i1,j1)+1) + right_val(i1,j1);
%             end
%         end      
%     end
% end
% 
