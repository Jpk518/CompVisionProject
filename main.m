clear; close all; clc;      % Clear previous state

input_file = 'project_video.mp4';    % Input Video

video_reader = VideoReader(input_file);  % Create an object of the video
video_player = vision.DeployableVideoPlayer();

frame_num = 0
while hasFrame(video_reader)
%     fprintf('Frame Number: %f .', frame_num);
    frame = readFrame(video_reader
    
    [height, width] = size(frame);

    [featureVector, hogVisualization] = extractHOGFeatures(frame);
    
    
  
    
    
%     figure(1); imshow(frame); hold on;
%     video_player(frame)
    figure(1); plot(hogVisualization);
    frame_num = frame_num + 1;    % Iterate to next frame
end
   

pause;
close all;
