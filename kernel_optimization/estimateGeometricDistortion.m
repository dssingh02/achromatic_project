function [xShift,yShift] = estimateGeometricDistortion(imgSet1, imgSet2, minCircleRadius, maxCircleRadius, sensitivity, stdDevThreshold)
% This function calculates the mean geometric distortion between two sets
% of images permutatively, where all images are of dark grid dots on a
% light background.
%
% Syntax:  [xShift,yShift] = estimateGeometricDistortion(imgSet1, imgSet2,...
%           minCircleRadius, maxCircleRadius, sensitivity, stdDevThreshold)
%
% Inputs:
%    imgSet1 - First image set (matrix of size h x w x n)
%    imgSet2 - Second image set (matrix of size h x w x m)
%    minCircleRadius - Minimum radius of calibration circles
%    maxCircleRadius - Maximum radius of calibration circles
%    sensitivity - Sensitivity to find circles in (see imfindcircles(...))
%    stdDevThreshold - Shift magnitude threshold (std. dev) to filter out
%       of the mean calculation
%
% Outputs:
%    xShift - The mean x shift in pixels for every combination of images (nxm grid)
%    yShift - The mean y shift in pixels for every combination of images (nxm grid)
%
% Author: Devdigvijay Singh, Princeton University
% Email: dssingh@princeton.edu
% Website: http://www.dave-singh.me
% Last revision: 19-January-2022

if ~exist('stdDevThreshold','var')
    stdDevThreshold = 3;
end

% Initialize shift matrices.
xShift = NaN(size(imgSet1,3), size(imgSet2,3));
yShift = NaN(size(imgSet1,3), size(imgSet2,3));

% Find and store all circle positions in all images.
imgCentersSet1 = cell(size(imgSet1,3),1);
imgCentersSet2 = cell(size(imgSet1,3),1);

for idx1 = 1:size(imgSet1,3)
    [imgCentersSet1{idx1},~] = imfindcircles(imgSet1(:,:,idx1), ...
        [minCircleRadius maxCircleRadius], 'ObjectPolarity','dark', ...
        'Sensitivity',sensitivity);
end

for idx2 = 1:size(imgSet2,3)
    [imgCentersSet2{idx2},~] = imfindcircles(imgSet2(:,:,idx2), ...
        [minCircleRadius maxCircleRadius], 'ObjectPolarity','dark', ...
        'Sensitivity',sensitivity);
end

% Process circle center positions to determine geometric distortion.
for idx1 = 1:size(imgSet1,3)
    for idx2 = 1:size(imgSet2,3)
        centroidShift = zeros(size(imgCentersSet1{idx1},1),2);
        
        for k = 1:size(imgCentersSet1{idx1},1)
            % Compute Euclidean distances.
            centerDiff = imgCentersSet2{idx2} - imgCentersSet1{idx1}(k,:);
            distances = sqrt(sum([centerDiff.^2]'))';
            
            % Find the circle in set 2 that is closest to the current
            % circle in set 1.
            closest = imgCentersSet2{idx2}(distances==min(distances),:);
            
            % Calculate the centroid shift.
            centroidShift(k,:) = closest - imgCentersSet1{idx1}(k,:);
        end
        
        % Filter out deviations.
        shiftMagnitude = sqrt(sum([centroidShift.^2]'))';
        sel = abs((shiftMagnitude - mean(shiftMagnitude))/std(shiftMagnitude)) > stdDevThreshold;
        centroidShift = centroidShift(~sel,:);
        xShift(idx1, idx2) = mean(centroidShift(:,1));
        yShift(idx1, idx2) = mean(centroidShift(:,2));
    end
end

end