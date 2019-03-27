function hog_bin = get_hog_features(im)
%% HOG algorithm Preprocessing and parameters 
[y,x] = size(im);

pixels_per_cell = [8,8];
cells_per_block = [2,2];

% Calculate number of cells
num_cells_x = x / pixels_per_cell(2);
num_cells_y = y / pixels_per_cell(1);

% ppc = pixels per cell
ppc_x = pixels_per_cell(2);
ppc_y = pixels_per_cell(1);

% cpb = cells per block
cpb_x = cells_per_block(2);
cpb_y = cells_per_block(1);

% ppb = pixels per block
ppb_x = pixels_per_cell(2)*cells_per_block(2);
pp_y = pixels_per_cell(1)*cells_per_block(1);
num_blocks_x = (x - ppb_x) / (ppb_x/2);
num_blocks_y = (y - pp_y) / (pp_y/2);
num_bins = 9;

%% Image Gradiants
% Sobel operator derivative masks
dx =  [-1 -2 -1; 0 0 0; 1 2 1];
dy =  dx';

% Calculate the horizontal and vertical gradients using correlation with dx and dy
Ix= imfilter(im, dx); 
Iy= imfilter(im, dy);

% Gradiant Magnitude and unsigned direction computation
g_mag = sqrt(Ix.^2 + Iy.^2);
g_dir = rad2deg(atan2(Iy,Ix));
% g_dir(g_dir == 180) = g_dir(g_dir == 180) - 0.001;
g_dir(g_dir < 0) = 180 + g_dir(g_dir < 0);  % Convert to unsigned
g_dir(g_dir == 180) = g_dir(g_dir == 180) - 0.001;
%% Histogram of gradients in each cell
% Assign Bucket Values
l_bin = floor(g_dir / 20);
r_bin = mod(round(g_dir / 20) + 1, num_bins);

% Bilinear Interpolation
l_val = g_mag .* ((l_bin+1).*20 - g_dir) ./20;
r_val = g_mag .* (g_dir - l_bin .* 20) ./ 20;

% Create empty HOG Histogram
hog_bin = zeros(num_cells_x*num_cells_y*num_bins + 1,1);

%Block loop
b_count = 0;
for i = 0:num_blocks_y-1
    for j = 0:num_blocks_x-1
        b_bin = zeros(cpb_x*cpb_y*num_bins,1);
        %Cell loop
        c_count = 0;
        for i1 = 1:cpb_y
            for j1 = 1:cpb_x
                c_bin = zeros(num_bins,1);
                cx_start = (j/2)*ppb_x+j1*ppc_x+1;
                cy_start = (i/2)*pp_y+i1*ppc_y+1;
                cx_end = (j/2)*ppb_x+(j1+1)*ppc_x;
                cy_end = (i/2)*pp_y+(i1+1)*ppc_y;
                cell_l_bin = reshape(l_bin(cy_start:cy_end, cx_start:cx_end), [], 1);
                cell_r_bin = reshape(r_bin(cy_start:cy_end, cx_start:cx_end), [], 1);
                cell_l_val = reshape(l_val(cy_start:cy_end, cx_start:cx_end), [], 1);
                cell_r_val = reshape(r_val(cy_start:cy_end, cx_start:cx_end), [], 1);
                K = max(size(cell_l_bin));
                
                bin = 0;
                for k = 1:K
                    c_bin(cell_l_bin(k)+1) = c_bin(cell_l_bin(k)+1) + cell_l_val(k);
                    c_bin(cell_r_bin(k)+1) = c_bin(cell_r_bin(k)+1) + cell_l_val(k);
                end  % End of bin angle loop
                c_count = c_count + 1;
                b_bin((c_count-1)*num_bins+1:c_count*num_bins) = c_bin; 
            end 
        end % End of cell loop
        b_bin = b_bin/(norm(b_bin) + 0.01); 
        b_count = b_count + 1;
        hog_bin((b_count-1)*num_bins*4+1:b_count*num_bins*4,1) = b_bin;
    end
end % End of block loop