clear;

load data_files\optimization_params.mat;

FOLDER_NAME = "D:\mansouri_image_set\";
IMG_WAVELENGTHS = ["470","530","590","625","730","850","940"];

% Read one image and calculate crop parameters.
img = imread(sprintf('%s%s_%s.tif',FOLDER_NAME,IMG_WAVELENGTHS(1),IMG_WAVELENGTHS(1)));
cropParams = [size(img,2)*CROP_RATIO/2, size(img,1)*CROP_RATIO/2, size(img,2)*CROP_RATIO, size(img,1)*CROP_RATIO];
cropParams = round(cropParams);
img = imcrop(img, cropParams);

% Initialize storage for all images.
focusImgs = repmat(img, [1,1,length(IMG_WAVELENGTHS)]);
blurryImgs = repmat(img, [1,1,length(IMG_WAVELENGTHS),length(IMG_WAVELENGTHS)]);

% Read, crop, and normalize images.
for focusIdx = 1:length(IMG_WAVELENGTHS)
    for blurryIdx = 1:length(IMG_WAVELENGTHS)
        img = imread(sprintf('%s%s_%s.tif',FOLDER_NAME,IMG_WAVELENGTHS(focusIdx),IMG_WAVELENGTHS(blurryIdx)));
        img = imcrop(img, cropParams);
        img = normalizeBWImage(img, NORMALIZATION_THRESHOLD, DARK_PK, BRIGHT_PK, BIT_COUNT);
        blurryImgs(:,:,focusIdx,blurryIdx) = img;
        
        if (focusIdx == blurryIdx)
            focusImgs(:,:,focusIdx) = img;
        end
    end
end

% Estimate geometric distortions.
tic;
[xShift,yShift] = estimateGeometricDistortion(focusImgs, blurryImgs, MIN_CIRCLE_RADIUS, MAX_CIRCLE_RADIUS, SENSITIVITY);
toc

% Correct geometric distortions.
tic;
[blurryImgs, focusImgs] = correctGeometricDistortion(blurryImgs, xShift, yShift, focusImgs);
toc






