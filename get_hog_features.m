% Inputs:
%   img

pixels_per_cell = [8,8];
cells_per_block = [2,2];
num_bins = 9;

%% Image pre-processing
im = imread('test_image.png');
hsv = rgb2hsv(im);

% Split image into cells

cells = mat2cell(hsv, [8 8 8 8 8 8 8 8], [8 8 8 8 8 8 8 8], [3]);

%% Image Gradiants
% Sobel operator derivative masks
dx =  [-1 -2 -1; 0 0 0; 1 2 1];
dy =  [-1 0 1; -2 0 2; -1 0 1];

% Calculate the horizontal and vertical gradients using correlation with dx and dy
Ix= imfilter(hsv, dx);
Iy= imfilter(hsv, dy);

% Gradiant Magnitude
grad_mag = sqrt(Ix.^2 + Iy.^2);

% Gradiant Direction
grad_dir_rad = atan(Iy./Ix);
grad_dir_deg = rad2deg(grad_dir_rad);

%% Histograms
% Gradient orientation
orient_bins = zeros(1, num_bins+1);

% Assign Bucket Values
left_bin = round(,0)

%%
% imshow(Ix);