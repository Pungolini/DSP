%% Laborat�rio 5 de PDS
%Pedro Martins n� 87735
%Pedro Ramos n� 90159
%Grupo n� 26
%Turno L03 (Segunda �s 14h)

clear;
close all;
clc;


%% R1 b)
%   Carregamento e visualiza��o da imagem
load('sar_image.mat');
figure;
im = imagesc(I);
colormap default
%% R1 c)
[ice, rect_ice] = imcrop(I,[9 201 166 320]);
figure
im_ice = imagesc(ice);
title('Ice region');
colormap default;

[water,rect_water] = imcrop(I,[402.5100  132.5100  158.9800  106.9800]);
figure
im_water = imagesc(water);
title('Water region');
colormap default;

% C�lculo dos par�metros para a regi�o do gelo
% Distribui��o normal
norm_param_ice = mle(ice(:),'distribution','norm')
% Distribui��o exponencial
exp_param_ice = mle(ice(:),'distribution','exp')
% Distribui��o Rayligh
ray_param_ice = mle(ice(:),'distribution','rayl')

% C�lculo dos par�metros para a regi�o da �gua
% Distribui��o normal
norm_param_water = mle(water(:),'distribution','norm');
% Distribui��o exponencial
exp_param_water = mle(water(:),'distribution','exp');
% Distribui��o Rayligh
ray_param_water = mle(water(:),'distribution','rayl');

%% R1 d)
% Obten��o das distribui��es para o gelo
ice_tmp = sort(ice(:));
% Distribui��o Rayligh
ray_ice = raylpdf(ice_tmp, ray_param_ice);

% Distribui��o exponencial
exp_ice = exppdf(ice_tmp, exp_param_ice);

% Distribui��o normal
norm_ice = normpdf(ice_tmp, norm_param_ice(1),norm_param_ice(2));

% Obten��o do histograma para a regi�o do gelo 
figure;
h_ice = histogram(ice(:),1000,'Normalization', 'pdf');

% Apresenta��o das distribui��es e do histograma
title('Ice');
xlabel('Pixel intensity');
ylabel('Probability density');
hold on;

plot(ice_tmp, exp_ice, ice_tmp, ray_ice, ice_tmp, norm_ice, 'LineWidth', 2);
legend('Histogram', 'Exponential', 'Rayleigh', 'Normal', 'Location', 'best');

% Obten��o das distribui��es para a �gua
water_tmp = sort(water(:));

% Distribui��o Rayligh
ray_water = raylpdf(water_tmp, ray_param_water);

% Distribui��o exponencial
exp_water = exppdf(water_tmp, exp_param_water);

% Distribui��o normal
norm_water = normpdf(water_tmp, norm_param_water(1), norm_param_water(2));

% Obten��o do histograma para a regi�o da �gua
figure;
h_water = histogram(water(:), 1000,'Normalization', 'pdf');
title('Water');
xlabel('Pixel intensity');
ylabel('Probability density');
hold on; 

% Apresenta��o das distribui��es e do histograma

plot(water_tmp, exp_water, water_tmp, ray_water, water_tmp, norm_water, 'LineWidth', 2);
legend('Histogram', 'Exponential', 'Rayleigh', 'Normal', 'Location', 'best');

%% R2 a)

% Segmenta��o da imagem por pixel conforme a distribui��o rayligh

water_seg = log(raylpdf(I, ray_param_water));
ice_seg = log(raylpdf(I, ray_param_ice));

Segmentation = ice_seg > water_seg;

figure;
imagesc(I);
hold on 
contour(logical(Segmentation), 'LineColor', 'w');
title('Segmentation');

%% R2 b)

% Segmenta��o da imagem por pixel com influ�ncia dos vizinhos 5x5 conforme a distribui��o rayligh

patch = ones(5);
water_patch_water = conv2(log(raylpdf(I, ray_param_water)), patch, 'same');
ice_patch = conv2(log(raylpdf(I, ray_param_ice)), patch, 'same');

SegmentationPatch = ice_patch > water_patch_water;
figure;
imagesc(I);
hold on 
contour(SegmentationPatch, 'LineColor', 'w');
title('Segmentation with Patch');


%% R2 c)

% Verifica��o das segmenta��es na regi�o do gelo
[m,n] = size(ice);
total = m*n;

% Segmenta��o Patch
correct = 0;
patch = ones(5);
water_patch_ice = conv2(log(raylpdf(ice, ray_param_water)), patch, 'same');
ice_patch_ice = conv2(log(raylpdf(ice, ray_param_ice)), patch, 'same');

correct = sum(ice_patch_ice > water_patch_ice, 'all');
RatePatchIce = correct/total

% Segmenta��o Pixel
correct = 0;
water_seg_ice = log(raylpdf(ice, ray_param_water));
ice_seg_ice = log(raylpdf(ice, ray_param_ice));

correct = sum(ice_seg_ice > water_seg_ice, 'all');

RatePixelIce = correct/total


% Verifica��o das segmenta��es na regi�o da �gua
[m,n] = size(water);
total = m*n;

% Segmenta��o Patch
correct = 0;
patch = ones(5);
water_patch_water = conv2(log(raylpdf(water, ray_param_water)), patch, 'same');
ice_patch_water = conv2(log(raylpdf(water, ray_param_ice)), patch, 'same');

correct = sum(water_patch_water > ice_patch_water, 'all');
RatePatchWater = correct/total

% Segmenta��o Pixel
correct = 0;
water_seg_water = log(raylpdf(water, ray_param_water));
ice_seg_water = log(raylpdf(water, ray_param_ice));

correct = sum(water_seg_water > ice_seg_water, 'all');

RatePixelWater = correct/total
