clear; close all; clc;      % Clear previous state

%%
input_file = 'project_video.mp4';    % Input Video

% Create System objects for reading and displaying video and for drawing a bounding box of the object.
videoFileReader = vision.VideoFileReader(input_file);   % object to read video frames, images, and audio samples from a video file
videoPlayer = vision.VideoPlayer(); % Play video
shapeInserter = vision.ShapeInserter('BorderColor','Custom','CustomBorderColor',[1 0 0]);   % Inserts shape into video
 
% Read first video
%objectFrame = videoFileReader();
objectFrame = step(videoFileReader); % https://www.mathworks.com/help/matlab/ref/step.html
objectHSV = rgb2hsv(objectFrame);   % Convert frame to hsv
objectRegion = [40, 45, 25, 25]; 

figure; imshow(objectFrame); 
% Returns current position of ROI object, this is function that gets you to make box
objectRegion = round(getPosition(imrect));  %imrect is vector: [xmin ymin width height]

objectImage = step(shapeInserter, objectFrame, objectRegion);

figure; imshow(objectImage); title('Red box shows object region');

% Histogram based object tracker that incorporates continuously adaptive mean shift for object tracking
tracker = vision.HistogramBasedTracker;     

% HBT Object. Set object to track and set initial search window. Called before step method
initializeObject(tracker, objectHSV(:,:,1) , objectRegion);

% Loop through video object frames
while ~isDone(videoFileReader)
  frame = step(videoFileReader);   % Grab current frame
  hsv = rgb2hsv(frame);            % Convert frame to hsv                   
  bbox = step(tracker, hsv(:,:,1));     %  
  
 
  
  
  out = step(shapeInserter, frame, bbox); 
  step(videoPlayer, out);   
  pos = [1 400 1279 310]
  rectangle('Position', pos, 'EdgeColor', 'r')
end
 
% Release video and reader and player
release(videoPlayer);
release(videoFileReader);

pause;
close all;

% while hasFrame(video_reader)
% %     fprintf('Frame Number: %f .', frame_num);
%     frame = readFrame(video_reader);
%     
%     [height, width] = size(frame);
% 
%     [featureVector, hogVisualization] = extractHOGFeatures(frame(height/4:height/2),:);
%     
%     
%   
%     
%     
%     figure(1); 
%     imshow(frame); hold on;
% %     video_player(frame)
%     plot(hogVisualization(:,:));
%     frame_num = frame_num + 1;    % Iterate to next frame
% end
%    
% 

