function [optimalRadii, optimizationData] = optimizeKernelRadius(focusImgs, blurryImgs,...
    noiseVar, kernelSize, minRadius, maxRadius, radiusPrecision, resizeFactor, plotResults)
% This function iteratively optimizes the kernel radius between specified
% focus images and blurry images.
%
% Syntax:  [optimalRadii, MSE] = optimizeKernelRadius(focusImgs,...
%               blurryImgs, noiseVar, kernelSize, minRadius, maxRadius,...
%               radiusPrecision, resizeFactor)
%
% Inputs:
%    focusImgs - A 3-dimensional matrix of m grayscale images (between 0 and 1)
%                   of size h x l x m
%    blurryImgs - A 4-dimensional matrix of grayscale images (between 0 and 1)
%                   of size h x l x m x n
%    noiseVar - The estimated noise variance
%       (matrix of size equal to the number of images)
%    resizeFactor - The denoising network to use to estimate noise with
%    kernelSize - Kernel size (in original pixel units)
%    minRadius - Minimum kernel radius (in original pixel units)
%    maxRadius - Maximum kernel radius (in original pixel units)
%    radiusPrecision - Precision to determine the optimal kernel radius to
%    plotResults - True if results should be plotted during optimization
%       otherwise false (default false)
%
% Outputs:
%    optimalRadii - Optimal radius for every blurry image (matrix of size m x n)
%    optimizationData - A cell of the mean squared errors as a function of
%       kernel radius when determining the optimal radius
%
% Required functions:
%    [kernel] = circularBlurKernel(kernelSize, radius)
%
% Author: Devdigvijay Singh, Princeton University
% Email: dssingh@princeton.edu
% Website: http://www.dave-singh.me
% Last revision: 20-January-2022

% How many divisions to sample during optimization.
DEFAULT_DIVISIONS = 4;

if ~exist('plotResults','var')
    plotResults = false;
end

% Initialize output variables.
optimalRadii = NaN(size(focusImgs,3), size(blurryImgs,4));
optimizationData.radius = cell(size(focusImgs,3), size(blurryImgs,4));
optimizationData.MSE = cell(size(focusImgs,3), size(blurryImgs,4));

% Loop through all focus images.
for idx1 = 1:size(focusImgs,3)
    cFocus = focusImgs(:,:,idx1);
    
    % Upscale blurry image.
    cFocusUpscale = imresize(cFocus, resizeFactor, 'box');
    
    % Loop through all blurry images.
    for idx2 = 1:size(blurryImgs,4)
        cBlurry = blurryImgs(:,:,idx2);
        
        % Initialize temp variables.
        tempMSESeries = NaN(DEFAULT_DIVISIONS+1,1);
        tempRadiusSeries = [linspace(minRadius,maxRadius,DEFAULT_DIVISIONS+1)]';
        tempPrecision = tempRadiusSeries(2) - tempRadiusSeries(1);
        
        MSESeries = [];
        radiusSeries = [];
        
        iter = 0;
        % Continue optimization until desired precision is reached.
        while (tempPrecision > radiusPrecision)
            tempPrecision = tempRadiusSeries(2) - tempRadiusSeries(1);
            
            % Use parallel processing to speed up optimization
            tic
            parfor cDiv = 1:DEFAULT_DIVISIONS+1
                currentRadius = tempRadiusSeries(cDiv);
                
                % Calculate the blur kernel for a given radius.
                currentKernel = circularBlurKernel(kernelSize*resizeFactor, currentRadius*resizeFactor);
                
                % Convolve the focus image.
                artificialBlurUpscale = conv2(cFocusUpscale, currentKernel, 'same');
                
                % Downsample the convolved image.
                artificialBlur = imresize(artificialBlurUpscale, 1/resizeFactor, 'box');
                artificialBlurNoisy = imnoise(artificialBlur, 'gaussian', 0, noiseVar(idx1,idx2));
                
                % Compare with the original blurred image.
                squaredErrors = (artificialBlurNoisy - cBlurry).^2;
                MSE = mean(squaredErrors(:));
                tempMSESeries(cDiv) = MSE;
            end
            tElapsed = toc;
            
            % Concatenate and computed values.
            radiusSeries = [radiusSeries;tempRadiusSeries];
            MSESeries = [MSESeries;tempMSESeries];
            [radiusSeries,sortIdx] = sort(radiusSeries,'ascend');
            MSESeries = MSESeries(sortIdx);
            
            % Reassign bounds of optimization.
            tempMinRadius = tempRadiusSeries(max(find(tempMSESeries == min(tempMSESeries)) - 1,1));
            tempMaxRadius = tempRadiusSeries(min(find(tempMSESeries == min(tempMSESeries)) + 1,DEFAULT_DIVISIONS+1));
            tempMinRadius = tempMinRadius(1);
            tempMaxRadius = tempMaxRadius(1);
            tempRadiusSeries = [linspace(tempMinRadius,tempMaxRadius,DEFAULT_DIVISIONS+1)]';
            
            iter = iter + 1;
            
            if (plotResults)
                figure(1)
                clf;
                plot(radiusSeries,MSESeries);
                hold on;
                yl = ylim();
                plot([tempMinRadius,tempMinRadius],yl,'k');
                plot([tempMaxRadius,tempMaxRadius],yl,'k');
                hold off;
                drawnow;
            end
            fprintf('focus img: %i\tblurry img: %i\titeration: %i\ttime elapsed: %.2fs\n',idx1, idx2, iter, tElapsed);
            
        end
        temp_mins = radiusSeries(MSESeries == min(MSESeries));
        optimalRadii(idx1,idx2) = temp_mins(1);
        
        fprintf('optimal radius: %.2f\n', optimalRadii(idx1, idx2));
        
        optimizationData.radius{idx1,idx2} = radiusSeries;
        optimizationData.MSE{idx1,idx2} = MSESeries;
    end
end

end