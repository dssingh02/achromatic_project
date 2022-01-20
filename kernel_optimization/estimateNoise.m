function [noise_var] = estimateNoise(imgs, net)
% This function estimates the variance of noise in a grayscale image.
%
% Syntax:  [noise_var] = estimateNoise(imgs, net)
%
% Inputs:
%    imgs - A 3-dimensional matrix of grayscale images between 0 and 1
%    net - The denoising network to use to estimate noise with
%
% Outputs:
%    noise_var - The estimated noise variance
%       (matrix of size equal to the number of images)
%
% Author: Devdigvijay Singh, Princeton University
% Email: dssingh@princeton.edu
% Website: http://www.dave-singh.me
% Last revision: 20-January-2022

% Initialize matrix
dimensions = [size(imgs), 1];
noise_var = NaN(dimensions(3:end));
numImgs = numel(noise_var);

% Estimate noise
for imgNum = 1:numImgs
    noisyImg = imgs(:,:,imgNum);
    clearImg = denoiseImage(noisyImg, net);
    diffImg = clearImg - noisyImg;
    noise_var(imgNum) = var(diffImg(:));
end

end