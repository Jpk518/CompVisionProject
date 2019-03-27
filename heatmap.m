function [history, hm_bb, map] = heatmap(frame, history, bounding_boxes, map)


%% ---------- Initialize Parameters ---------- %%

% load('bbox.mat')
thresh_val = 1;

memory = 8;
f = frame;
% history = [];
boxes = bounding_boxes;
% boxes = boxes';

% Create an empty heatmap
[y ,x, z] = size(f);


%% ---------- Update heatmap ---------- %%

if size(history, 3) == memory
    map = remove(map, history(:,:,1));  % Take least recent box off heatmap
    history(:,:,1) = [];    % Remove least recent box from history
end

map = add(map, boxes);
if isempty(history)
    history = boxes;
else
    sh = size(history,1);
    sb = size(boxes, 1);
    sd = abs(sh - sb);
    if sh > sb
    boxes = [boxes; zeros(sd, 3)];    
    elseif sh < sb
        history = [history; zeros(sd, 3, size(history,3))];    
    end
    history = cat(3, history, boxes);
end
map = threshold_map(map, thresh_val);

%% ---------- Show heatmap ---------- %%


[L_map, samples_found] = bwlabel(map, 4);

hm_bb = [];
if samples_found > 0
    for n = 1:samples_found
        [ys, xs] = find(L_map == n, 1, 'first');
        [ye, xe] = find(L_map == n, 1, 'last');
        h = ye- ys;
        w = xe - xs;
        hm_bb = [hm_bb; xs ys w h];
    end
end

end
%% ------------------------------ Functions ------------------------------ %%


%% ---------- Remove ---------- %%
% Pops least recent boxes element in memory from heatmap
function map = remove(map, boxes)
    for i = 1:size(boxes, 1)
        [x1, y1, x2, y2] = box_boundaries(boxes(i, :));
        if x1 ~= 0 && x2 ~= 0 && y1 ~= 0 && y2 ~= 0
            map(y1:y2, x1:x2) = map(y1:y2, x1:x2) - 1;
        end
    end
end

%% ---------- Add ---------- %%
% Pushes most recent boxes element in memory to heatmap
function map = add(map, boxes)
    for i = 1:size(boxes, 1)
        [x1, y1, x2, y2] = box_boundaries(boxes(i, :));
        if x1 ~= 0 && x2 ~= 0 && y1 ~= 0 && y2 ~= 0
            map(y1:y2, x1:x2) = map(y1:y2, x1:x2) + 1;
        end
    end
end

%% ---------- Heatmap Threshold ---------- %%
% Thresholds heatmap to 0 below a certain threshold parameter
function map = threshold_map(map, thresh_val)
    map(map < thresh_val) = 0;
end

%% ----------Box Boundaries ---------- %%
% Returns boundaries given xo, yo and box dimensions
function [x1, y1, x2, y2] = box_boundaries(box)
    x1 = box(1);
    y1 = box(2);
    
    size = box(3);

    x2 = x1 + size;
    y2 = y1 + size;
end