clear
close all 
clc
%% Maximum Likelihood Estimation
%% R1b) Load and Visualize
load('sar_image.mat');
img = imagesc(I);
title('Synthetic Aperture Radar (SAR)');
colormap('default');
%% R1c) Crop the images into ICE and WATER. Estimates the parameter(s) of the given distributions
%% Cropping images
% Ice
[image_croped_ice, rect_ice] = imcrop(I,[0.51 179.51 150 305]);

figure
imagesc(image_croped_ice);
% Water
[image_croped_water, rect_water]= imcrop(imagesc(I));

figure; 
imagesc(image_croped_water);

rect_ice
rect_water
%% Estimate the parameters of the distributions
% Ice Params
ice_normal_params = mle(image_croped_ice(:),'distribution','norm')
ice_exponential_params = mle(image_croped_ice(:),'distribution','exp')
ice_rayleigh_params = mle(image_croped_ice(:),'distribution','rayl')

% Water Params
water_normal_params = mle(image_croped_water(:),'distribution','norm')
water_exponential_params = mle(image_croped_water(:),'distribution','exp')
water_rayleigh_params = mle(image_croped_water(:),'distribution','rayl')

% Parameters obtained: remove semicolons above to print them


%% R1d) Plot the distributions and compare with the histogram
% histogram

%% Distributions for Ice
figure;
histogram_ice = histogram(image_croped_ice(:),1000,'Normalization', 'pdf');

rayleigh_ice = raylpdf(sort(image_croped_ice(:)), ice_rayleigh_params);
exponential_ice = exppdf(sort(image_croped_ice(:)), ice_exponential_params);
normal_ice = normpdf(sort(image_croped_ice(:)), ice_normal_params(1),ice_normal_params(2));
hold on 
plot(rayleigh_ice)
hold on
plot(exponential_ice)
hold on
plot(normal_ice)
title('Ice Histogram and Distributions')
xlabel('Pixel intensity');
ylabel('Probability density');
legend('Histogram', 'Rayleigh', 'Exponential', 'Normal');

% Although not by a long distance, the rayleigh distribution seems to fit
% the data the best. In fact, the area of the histogram below eache
% distribution curve seems to be bigger for the rayleigh distribution.


%% Distributions for Water

rayleigh_water = raylpdf(sort(image_croped_water(:)), water_rayleigh_params);
exponential_water = exppdf(sort(image_croped_water(:)), water_exponential_params);
normal_water = normpdf(sort(image_croped_water(:)), water_normal_params(1),water_normal_params(2));
figure
histogram_water = histogram(image_croped_water(:),'Normalization', 'pdf');
hold on 
plot(rayleigh_water)
hold on
plot(exponential_water)
hold on
plot(normal_water)
title('Water Histogram and Distributions')
xlabel('Pixel intensity');
ylabel('Probability density');
legend('Histogram', 'Rayleigh', 'Exponential', 'Normal');

% Again, although none of the distributions really fit the data good enough
% (at least at the time writing this). The best is still the rayleigh
% distribution, for the same reasons as in the previous image. The scale
% parameter of the rayleigh distribution seems to be too large.
% By tuning the cropped region the results can vary drastically and we
% probably sampled a bad region

%% R2) Image Segmentation
%% R2a) Perform the segmentation using the best distribution: Rayleigh
ice_seg = log(raylpdf(I, ice_rayleigh_params));
water_seg = log(raylpdf(I, water_rayleigh_params));
Segmentation = ice_seg > water_seg;

figure;
imagesc(I);
hold on 
contour(logical(Segmentation), 'LineColor', 'r');
title('Segmentation');

%% R2b) Repeat the previous using patch  
patch = ones(5);
ice_with_patch = conv2(log(raylpdf(I, ice_rayleigh_params)), patch, 'same');
water_with_patch= conv2(log(raylpdf(I, water_rayleigh_params)), patch, 'same');
Patch_Segmentation = ice_with_patch > water_with_patch;
figure;
imagesc(I);
hold on 
contour(Patch_Segmentation, 'LineColor', 'r');
title('Segmentation with Patch');


%% R3c
