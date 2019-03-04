function [paths, labels] = get_trainingdata_paths()
    
path_vehicles = dir(fullfile(pwd,'vehicles'));
cd('vehicles');

vehicle_image_num = 1;
for i = 3:length(path_vehicles)
    cd(path_vehicles(i).name);
    current_vehicle_dir = dir(pwd);
    for j = 3:length(current_vehicle_dir)
        paths_vehicle_images(vehicle_image_num) =  convertCharsToStrings(fullfile(pwd,current_vehicle_dir(j).name));
        paths_vehicle_images2 = paths_vehicle_images';
        vehicle_image_num = vehicle_image_num + 1;
    end
    cd ..
end
cd ..

path_non_vehicles = dir(fullfile(pwd,'non-vehicles'));
cd('non-vehicles');
non_vehicle_image_num = 1;
for i = 3:length(path_non_vehicles)
    cd(path_non_vehicles(i).name);
    current_non_vehicle_dir = dir(pwd);
    for j = 3:length(current_non_vehicle_dir)
        paths_non_vehicle_images(non_vehicle_image_num) =  convertCharsToStrings(fullfile(pwd,current_non_vehicle_dir(j).name));
        non_vehicle_image_num = non_vehicle_image_num + 1;
    end
    cd ..
end
cd ..

[row_num_cars, col_num_cars] = size(paths_vehicle_images);
[row_num_noncars, col_num_noncars] = size(paths_non_vehicle_images);

label_cars = ones(row_num_cars, col_num_cars);
label_noncars = zeros(row_num_noncars, col_num_noncars);

labels = cat(2, label_cars, label_noncars);
paths = cat(2, paths_vehicle_images, paths_non_vehicle_images);

rand_num = randperm(length(paths));
labels = labels(:,rand_num(1:length(rand_num)));
paths = paths(:,rand_num(1:length(rand_num)));
labels = labels';
