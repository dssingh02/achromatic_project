function [sharpImg] = deconvolveImage(blurryImg, optRadius, kernelSize, resizeFactor, optIteration)
% Deconvolve achromatic image - Deconvolves an achromatic image with a
% a specified circular blur kernel radius, kernel size, and resize factor.
%
% Syntax: [sharpImg] = deconvolveImage(blurryImg, optRadius, kernelSize, resizeFactor, optIteration)
%
% Inputs:
%    blurryImg - Image to deconvolve
%    optRadius - Blur kernel radius
%    kernelSize - Kernel size
%    resizeFactor - Upscale resize factor during deblurring
%    optIteration - Number of iterations for deconvolving; 0 if no
%       deblurring is necessary
%
% Outputs:
%    sharpImg - The deconvolved image
%
% Required functions:
%    [kernel] = circularBlurKernel(kernelSize, radius)
%
% Author: Devdigvijay Singh, Princeton University
% Email: dssingh@princeton.edu
% Website: http://www.dave-singh.me
% Last revision: 19-January-2022

% Generate circular blur kernel.
[kernel] = circularBlurKernel(kernelSize, optRadius);

if (optIteration > 0)
    % Upscale blurry image.
    upscaleImg = imresize(blurryImg, resizeFactor, 'box');
    clear blurryImg;
    
    % Deconvolve upscaled image.
    deconvImg = deconvlucy(upscaleImg, kernel, optIteration);
    clear upscaleImg;
    
    % Downscale deconvolved image.
    sharpImg = imresize(deconvImg, 1/resizeFactor, 'box');
    clear deconvImg;
else
    sharpImg = blurryImg;
end

end