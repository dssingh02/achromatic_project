function [correctedImgSet2,correctedImgSet1] = correctGeometricDistortion(imgSet2, xShift, yShift, imgSet1)
% This function corrects a constant geometric translation between images.
%
% Syntax:  [correctedImgSet2,correctedImgSet1] = correctGeometricDistortion(imgSet2, xShift, yShift, imgSet1)
%
% Inputs:
%    imgSet2 - The set of images to correct (matrix of size l x w x n)
%    xShift - The shift in the x-direction (matrix of size m x n)
%    yShift - The shift in the y-direction (matrix of size m x n)
%    imgSet1 - The set of images from which imgSet2 is distorted
%       (optional parameter) (matrix of size l x w x m) to ensure these
%       images are cropped just like the undistorted
%
% Outputs:
%    correctedImgSet2 - The corrected images (matrix of size l x w x m x n)
%    correctedImgSet1 - The cropped images (matrix of size l x w x m)
%
% Author: Devdigvijay Singh, Princeton University
% Email: dssingh@princeton.edu
% Website: http://www.dave-singh.me
% Last revision: 19-January-2022

% Initialize dimensions and output image matrix.
[m,n] = size(xShift);
cropBorder = round(max([abs(xShift(:)); abs(yShift(:))])) + 2;
correctedImgSet2 = repmat(imgSet2(:,:,1), [1, 1, m, n]);

% Initialize pixel coordinates.
imgX = 1:size(imgSet2,2);
imgY = 1:size(imgSet2,1);
[imageX,imageY] = meshgrid(imgX,imgY);

% Correct images.
for idx1 = 1:m
    for idx2 = 1:n
        % Calculate distorted coordinates.
        distortedX = imageX - xShift(idx1, idx2);
        distortedY = imageY - yShift(idx1, idx2);
        
        % Interpolate image.
        correctedImgSet2(:,:,idx1,idx2) = griddata(distortedX, distortedY, double(imgSet2(:,:,idx2)), imageX, imageY);
    end
end

% Crop corrected images.
correctedImgSet2 = correctedImgSet2(cropBorder:end-cropBorder, cropBorder:end-cropBorder,:,:);

% Crop optional images.
correctedImgSet1 = NaN;
if exist('imgSet1','var')
    correctedImgSet1 = imgSet1(cropBorder:end-cropBorder, cropBorder:end-cropBorder,:);
end

end