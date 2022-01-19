function [normalizedImage, normalizedImage2] = normalizeBWImage(img, threshold, darkPk, brightPk, bitCount)
% Normalize BW image - Linearly stretches the histogram of a grayscale image
% with black and white elements to specified peaks for black and white.
%
% Syntax:  [normalizedImage] = normalizeBWImage(img, threshold, blackPk, whitePk)
%
% Inputs:
%    img - Image to normalize
%    threshold - A grayscale threshold value guaranteed to divide black and
%    white
%    darkPk - The desired value of the dark peak in the histogram.
%    brightPk - The desired value of the bright peak in the histogram.
%    bitCount - 8 if 8-bit, 16 if 16-bit.
%
% Outputs:
%    normalizedImage - The normalized image in 8- or 16-bit.
%    normalizedImage2 - The normalized image as a double without rounding.
%
% Author: Devdigvijay Singh, Princeton University
% email: dssingh@princeton.edu
% Website: http://www.dave-singh.me
% Last revision: 12-January-2022

% Initialize histogram bins based on image bit-count.
if (bitCount == 8)
    bins = [0:2^8-1];
elseif (bitCount == 16)
    bins = [0:2^16-1];
end

img = double(img);
counts = histcounts(img, bins);
bins = bins(2:end);

sel = bins < threshold;

darkMax = max(counts(sel));
brightMax = max(counts(~sel));

darkMax = darkMax(1);
brightMax = brightMax(1);

cDarkPk = bins(counts == darkMax);
cBrightPk = bins(counts == brightMax);

cDarkPk = cDarkPk(1);
cBrightPk = cBrightPk(1);


img = img - cDarkPk;
img = img.*((brightPk - darkPk)/(cBrightPk(1) - cDarkPk(1)));
img = img + darkPk;

if (bitCount == 8)
    normalizedImage = uint8(img);
elseif (bitCount == 16)
    normalizedImage = uint16(img);
end

normalizedImage2 = img;

end



