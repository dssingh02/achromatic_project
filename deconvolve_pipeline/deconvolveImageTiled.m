function [sharpImg] = deconvolveImageTiled(blurryImg, optRadius, kernelSize, resizeFactor, optIteration, tileSize, dispFig)
% Deconvolve achromatic image by splitting it up into an nxn grid of images
%
% Syntax: [sharpImg] = deconvolveImageTiled(blurryImg, optRadius, kernelSize, resizeFactor, optIteration, tileSize, dispFig)
%
% Inputs:
%    blurryImg - Image to deconvolve
%    optRadius - Blur kernel radius
%    kernelSize - Kernel size
%    resizeFactor - Upscale resize factor during deblurring
%    optIteration - Number of iterations for deconvolving; 0 if no
%       deblurring is necessary
%    tileSize - Grid size to split image into (tileSize x tileSize)
%    dispFig - True if figure should be displayed during process (default false)
%
% Outputs:
%    sharpImg - The deconvolved image
%
% Required functions:
%    [sharpImg] = deconvolveImage(blurryImg, optRadius, kernelSize, resizeFactor, optIteration)
%
% Author: Devdigvijay Singh, Princeton University
% Email: dssingh@princeton.edu
% Website: http://www.dave-singh.me
% Last revision: 19-January-2022

if ~exist('dispFig','var')
    dispFig = false;
end

% Calculate the tile dimensions
tileWidth = floor(size(blurryImg,2)/tileSize);
tileHeight = floor(size(blurryImg,1)/tileSize);

% Initialize a sharp image to be in the same format as the blurry image.
sharpImg = blurryImg;
sharpImg(:) = 0;

tileMargin = kernelSize;

for row = 1:tileSize
    for col = 1:tileSize
        startRow = max(1,(row-1)*tileHeight+1-tileMargin);
        startCol = max(1,(col-1)*tileWidth+1-tileMargin);
        endRow = min(size(blurryImg,1),row*tileHeight+tileMargin);
        endCol = min(size(blurryImg,2),col*tileWidth+tileMargin);
        
        if (row == tileSize)
            endRow = size(blurryImg,1);
        end
        if (col == tileSize)
            endCol = size(blurryImg,2);
        end
        
        % Crop image
        cTile = blurryImg(startRow:endRow,startCol:endCol);
        cTile = deconvolveImage(cTile, optRadius, kernelSize, resizeFactor, optIteration);
        
        % Reconstruct full image
        deconvStartRow = startRow + tileMargin;
        deconvStartCol = startCol + tileMargin;
        deconvEndRow = endRow - tileMargin;
        deconvEndCol = endCol - tileMargin;
        
        tileStartRow = tileMargin + 1;
        tileStartCol = tileMargin + 1;
        tileEndRow = size(cTile,1)-tileMargin;
        tileEndCol = size(cTile,2)-tileMargin;
        
        if (row == 1)
            deconvStartRow = 1;
            tileStartRow = 1;
        end
        if (col == 1)
            deconvStartCol = 1;
            tileStartCol = 1;
        end
        if (row == tileSize)
            deconvEndRow = size(blurryImg,1);
            tileEndRow = size(cTile,1);
        end
        if (col == tileSize)
            deconvEndCol = size(blurryImg,2);
            tileEndCol = size(cTile,2);
        end
        
        sharpImg(deconvStartRow:deconvEndRow,deconvStartCol:deconvEndCol) = cTile(tileStartRow:tileEndRow,tileStartCol:tileEndCol);
        
        if (dispFig)
            figure(1)
            clf;
            imshow(sharpImg);
            fprintf('Row: %i\tCol: %i\tRows: %i to %i\tColumns: %i to %i\n',row,col,startRow,endRow,startCol,endCol);
        end
    end
end

end