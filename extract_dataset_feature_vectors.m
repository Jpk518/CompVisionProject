% function extract_dataset_feature_vectors()


if ~exist('vehicle_images','dir')
    rmdir vehicle_images;
    mkdir vehicle_images;
end
vehicle_image_dir = fullfile(pwd,'vehicle_images')

if ~exist('non_vehicle_images','dir')
    rmdir non_vehicle_images;
    mkdir non_vehicle_images;
end
non_vehicle_image_dir = fullfile(pwd,'non_vehicle_images')


path_vehicles = dir(fullfile(pwd,'vehicles'))
cd('vehicles')
vehicle_image_num = 1
for i = 3:length(path_vehicles)
    cd(path_vehicles(i).name)
    current_vehicle_dir = dir(pwd)
    
    for j = 1:length(pwd)
        new_filename = strcat('v',num2str(vehicle_image_num));
        movefile(current_vehicle_dir(j).name, new_filename)
        movefile(new_filename, vehicle_image_dir);
        vehicle_image_num = vehicle_image_num+1;
    end
    
    cd ..
end
cd ..


% path_non_vehicles = dir(fullfile(pwd,'non-vehicles'))
% cd('non-vehicles')
% for i = 3:length(path_non_vehicles)
%     cd(path_non_vehicles(i).name)
%     non_vehicle_dirs(i) = pwd
%     cd ..
% end
% cd ..
    


% files = dir (strcat(path,'\*.csv'))