function [kernel] = circularBlurKernel(kernelSize, radius)
% Generate a normalized, circular blur kernel - Generates and normalizes
% a circular blur kernel of a specified kernel size and radius.
%
% Syntax: [kernel] = circularBlurKernel(kernelSize, radius)
%
% Inputs:
%    kernelSize - Kernel size
%    radius - Blur kernel radius
%
% Outputs:
%    kernel - The deconvolved image
%
% Author: Devdigvijay Singh, Princeton University
% Email: dssingh@princeton.edu
% Website: http://www.dave-singh.me
% Last revision: 19-January-2022

RESOLUTION = 100;

kernel = zeros(kernelSize, kernelSize);

x = -kernelSize/2 + 0.5:kernelSize/2 - 0.5;
[X,Y] = meshgrid(x,x);

for i = 1:size(X(:),1)
    cx = linspace(X(i) - 0.5, X(i) + 0.5, RESOLUTION);
    cy = linspace(Y(i) - 0.5, Y(i) + 0.5, RESOLUTION);
    
    [CX,CY] = meshgrid(cx,cy);
    total = 0;
    
    for j = 1:size(CX(:))
        if (CX(j)^2 + CY(j)^2 < radius^2)
            total = total + 1;
        end
    end
    
    kernel(i) = total / RESOLUTION^2;
end

kernel = kernel / sum(kernel(:));
end