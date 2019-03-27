clear; close all; clc;      % Clear previous state
input_file = 'test_video.mp4';    % Input Video

% Create System objects for reading and displaying video and for drawing a bounding box of the object.
videoFileReader = vision.VideoFileReader(input_file);   % object to read video frames, images, and audio samples from a video file
position = [50 50 1500 700];
videoPlayer = vision.VideoPlayer('Position',position); % Play video
v = VideoWriter('results.mp4');
open(v);
history = [];
map = zeros(720, 1280);
count = 0;
% Loop through video object frames
while ~isDone(videoFileReader)
    frame = step(videoFileReader);   % Grab current frame
    [history, hm_bb, map] = slider(frame, history, map);
    
    hm_bb = hm_bb';
    for iter = 1:size(hm_bb,2)
        x = hm_bb(1, iter);
        y = hm_bb(2, iter);
        w = hm_bb(3, iter);
        h = hm_bb(4, iter);
        pos = [x y w h];
        frame = insertShape(frame, 'rectangle', pos);
    end
    step(videoPlayer, frame);
    writeVideo(v,frame);
end
 
% Release video and reader and player
release(videoPlayer);
release(videoFileReader);
close(v)
pause;
close all;