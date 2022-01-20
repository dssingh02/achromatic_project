clear;

% Read in two images known to have some geometric distortion.
img1 = imread('kernel_optimization\test_files\530_530.tif');
img2 = imread('kernel_optimization\test_files\530_625.tif');

% Crop images;
img1 = img1(6800:6800+500, 4200:4200+500);
img2 = img2(6800:6800+500, 4200:4200+500);

% Normalize the two images;
img1 = normalizeBWImage(img1, 125, 50, 200, 8);
img2 = normalizeBWImage(img2, 125, 50, 200, 8);

% Calculate geometric distortions.
MIN_CIRCLE_RADIUS = 15;
MAX_CIRCLE_RADIUS = 18;
SENSITIVITY = 0.95;

[xShift,yShift] = estimateGeometricDistortion(img1, img2, MIN_CIRCLE_RADIUS, MAX_CIRCLE_RADIUS, SENSITIVITY);

% Correct geometric distortions
[img4, img3] = correctGeometricDistortion(img2, xShift, yShift, img1);

% Convert them to double.
img1Double = double(img1);
img2Double = double(img2);
img3Double = double(img3);
img4Double = double(img4);

% Calculate their difference.
imgDiff1 = img2Double - img1Double;
imgDiff2 = img4Double - img3Double;

% Visualize differences before and after correction.
figure(1)
clf;
subplot(1,2,1)
imagesc(imgDiff1);
axis image;
colorbar;
caxis([-40,40])
subplot(1,2,2)
imagesc(imgDiff2);
axis image;
colorbar;
caxis([-40,40])


