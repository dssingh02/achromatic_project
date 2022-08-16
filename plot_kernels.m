clear;

load data_files\optimized_paramsV4WithNoise.mat

IMG_WAVELENGTHS = ["470","530","590","625","730","850","940"];

KERNEL_SIZE = 15;
RESIZE_FACTOR = 4;

clrs = [0,0,1;...
    0,1,0;...
    1,1,0;...
    1,0,0;...
    0.698,0.133,0.133;...
    0.5,0.5,0.5;...
    0.1,0.1,0.1];

radius = optimizationData.radius;
MSE = optimizationData.MSE;

kernels = cell(6,1);

figure(1)
clf;
for i = 1:7
    j = 1;
    
    hold on;
    p(j) = plot(radius{i}, MSE{i});
    p(j).Color = clrs(i,:);
    p(j).LineWidth = 1;
    p(j).DisplayName = sprintf('%s nm (%.2f px)', IMG_WAVELENGTHS(i), optimalRadii(i));
    sel = radius{i} == optimalRadii(i);
    optimalMSE = MSE{i}(sel);
    s(j) = scatter(optimalRadii(i),optimalMSE(1),'filled');
    s(j).MarkerFaceColor = p(j).Color;
    s(j).MarkerEdgeColor = p(j).Color;
    s(j).MarkerFaceAlpha = 0.5;
    s(j).SizeData = 100;
    s(j).HandleVisibility = 'off';
    hold off;
    
    img = circularBlurKernel(KERNEL_SIZE, RESIZE_FACTOR*optimalRadii(i));
    img = uint8(img*255);
    img = repmat(img, [1,1,3]);
    for k = 1:3
        img(:,:,k) = img(:,:,k) * clrs(i,k);
    end
    
    kernels{i} = img;
end

xlabel('Kernel radius (px)');
ylabel('MSE')

lgd = legend();
lgd.Location = 'eastoutside';

%%

%%
NUM_WAVELENGTHS = 7;
GREEN_INDEX = 2;
position = [1658         806         892         432];
insetPos = [0.13,0.62,0.6,0.4];

kernelInset = [];
kernelInsetAlphaData = [];

figure(10)
clf;

hold on;
for i = 1:NUM_WAVELENGTHS
    if i == GREEN_INDEX
        continue;
    end
    radiusSeries = radius{i};
    MSESeries = MSE{i};
    optRadius = optimalRadii(i);
    minMSE = MSESeries(radiusSeries == optRadius);
    minMSE = minMSE(1);
    
    optRadiusToPlot = optRadius;
    
    p(i) = plot([0; radiusSeries],[MSESeries(1); MSESeries]);
    p(i).Color = clrs(i,:);
    p(i).DisplayName = sprintf('%s nm',IMG_WAVELENGTHS(i));
    p(i).LineWidth = 1;
    
    s(i) = scatter(optRadiusToPlot,minMSE);
    s(i).MarkerEdgeColor = 0.9*clrs(i,:);
    s(i).MarkerFaceColor = s(i).MarkerEdgeColor;
    s(i).MarkerFaceAlpha = 0.5;
    s(i).HandleVisibility = 'off';
    
    currentKernel = circularBlurKernel(KERNEL_SIZE*RESIZE_FACTOR, optRadius*RESIZE_FACTOR);
    currentKernel = currentKernel / max(currentKernel(:));
    imageKernel = ones(size(currentKernel,1),size(currentKernel,2),3);
    imageKernel(:,:,1) = imageKernel(:,:,1) * clrs(i,1);
    imageKernel(:,:,2) = imageKernel(:,:,2) * clrs(i,2);
    imageKernel(:,:,3) = imageKernel(:,:,3) * clrs(i,3);
    
    kernelInset = [kernelInset, imageKernel];
    kernelInsetAlphaData = [kernelInsetAlphaData, currentKernel];
end
hold off;

xlim([0 7])
ylim([0 0.006])

set(gca,'FontSize',16)

xlabel('Kernel radius (px)','FontSize',20)
ylabel('MSE','FontSize',20)

lgd = legend();
lgd.FontSize = 16;
lgd.Location = 'eastoutside';

set(gca, 'FontName', 'AvenirNext LT Pro Regular')
grid on;

set(figure(10),'Position',position)

axes('Position', insetPos);
box on;
ax = gca;
ax.LineWidth = 6;
h = imshow(kernelInset);
h.AlphaData = kernelInsetAlphaData;
axis image;
axis off;

increment = size(kernelInsetAlphaData,2)/(NUM_WAVELENGTHS-1) - 0.5;

for i = 1:NUM_WAVELENGTHS
    if (i == GREEN_INDEX)
        continue;
    end
    if (i < GREEN_INDEX)
        idx = i;
    elseif (i > GREEN_INDEX)
        idx = i - 1;
    end
    textBox(i) = text(increment/2 + (idx-1)*increment - 13, increment, sprintf('%.2f px', optimalRadii(i)));
    textBox(i).FontSize = 12;
end

drawnow;


