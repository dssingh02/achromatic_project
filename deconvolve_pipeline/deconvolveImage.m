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
%    optIteration - Number of iterations for deconvolving
%
% Outputs:
%    sharpImg - The deconvolved image
%
% Author: Devdigvijay Singh, Princeton University
% email: dssingh@princeton.edu
% Website: http://www.dave-singh.me
% Last revision: 18-January-2022

end