clear;

% Load datafiles.
load data_files\deconvolve_settings.mat
load data_files\optimized_params.mat

% Initialize some important constants.
WAVELENGTHS = ["470","530","590","625","730","850","940"]; % Reflected light
LIGHT_TABLE_INDICES = [1,2,4,6,7]; % In case of transmitted light
FOCUS_INDEX = 2; % 530 nm (green)
TILE_SIZE = 5; % Split images into an nxn grid when deconvolving; optimize for your own computer.

% Initialize directories.
% Reminder: 365 nm images are not to be deblurred, so ensure that they you
% manually account for those images.
importImgDir = "deconvolve_pipeline\test_images\original\";
exportImgDir = "deconvolve_pipeline\test_images\deconvolved\";

% Detect all image files from import directory.
fileList = dir(sprintf('%s*.tif', importImgDir));

for imageNum = 1:length(WAVELENGTHS)
    % Identify which wavelength this image is.
    blurryIndex = imageNum;
    
    % Determine deconvolve parameters.
    optRadius = optimalRadius(FOCUS_INDEX, blurryIndex);
    optIteration = optimalIterations(FOCUS_INDEX, blurryIndex);
    
    % Read in image.
    imageSrc = fullfile(fileList(imageNum).folder, fileList(imageNum).name);
    blurryImg = imread(imageSrc);
    
    % Deconvolve image.
    sharpImg = deconvolveImageTiled(blurryImg, optRadius, KERNEL_SIZE, RESIZE_FACTOR, optIteration, TILE_SIZE, true);
    
    % Write image
    refTiff = Tiff(imageSrc,'r+');
    exportImageSrc = fullfile(exportImgDir, fileList(imageNum).name);
    t = Tiff(exportImageSrc,'w');
    tagstruct.ImageLength = size(blurryImg,1);
    tagstruct.ImageWidth = size(blurryImg,2);
    tagstruct.Photometric = getTag(refTiff,'Photometric');
    tagstruct.BitsPerSample = getTag(refTiff,'BitsPerSample');
    tagstruct.SamplesPerPixel = getTag(refTiff,'SamplesPerPixel');
    tagstruct.RowsPerStrip = getTag(refTiff,'RowsPerStrip');
    tagstruct.PlanarConfiguration = getTag(refTiff,'PlanarConfiguration');
    tagstruct.Software = 'MATLAB';
    tagstruct; % display tagstruct
    setTag(t,tagstruct);
    
    write(t,sharpImg);
    close(t);
end