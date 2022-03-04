%% Laboratório 5 de PDS
%Pedro Martins nº 87735
%Pedro Ramos nº 90159
%Grupo nº 26
%Turno L03 (Segunda às 14h)

clear;
close all;
clc;


%% R1 b)
%   Carregamento e visualização da imagem
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

% Cálculo dos parâmetros para a região do gelo
% Distribuição normal
norm_param_ice = mle(ice(:),'distribution','norm')
% Distribuição exponencial
exp_param_ice = mle(ice(:),'distribution','exp')
% Distribuição Rayligh
ray_param_ice = mle(ice(:),'distribution','rayl')

% Cálculo dos parâmetros para a região da água
% Distribuição normal
norm_param_water = mle(water(:),'distribution','norm');
% Distribuição exponencial
exp_param_water = mle(water(:),'distribution','exp');
% Distribuição Rayligh
ray_param_water = mle(water(:),'distribution','rayl');

%% R1 d)
% Obtenção das distribuições para o gelo
ice_tmp = sort(ice(:));
% Distribuição Rayligh
ray_ice = raylpdf(ice_tmp, ray_param_ice);

% Distribuição exponencial
exp_ice = exppdf(ice_tmp, exp_param_ice);

% Distribuição normal
norm_ice = normpdf(ice_tmp, norm_param_ice(1),norm_param_ice(2));

% Obtenção do histograma para a região do gelo 
figure;
h_ice = histogram(ice(:),1000,'Normalization', 'pdf');

% Apresentação das distribuições e do histograma
title('Ice');
xlabel('Pixel intensity');
ylabel('Probability density');
hold on;

plot(ice_tmp, exp_ice, ice_tmp, ray_ice, ice_tmp, norm_ice, 'LineWidth', 2);
legend('Histogram', 'Exponential', 'Rayleigh', 'Normal', 'Location', 'best');

% Obtenção das distribuições para a água
water_tmp = sort(water(:));

% Distribuição Rayligh
ray_water = raylpdf(water_tmp, ray_param_water);

% Distribuição exponencial
exp_water = exppdf(water_tmp, exp_param_water);

% Distribuição normal
norm_water = normpdf(water_tmp, norm_param_water(1), norm_param_water(2));

% Obtenção do histograma para a região da àgua
figure;
h_water = histogram(water(:), 1000,'Normalization', 'pdf');
title('Water');
xlabel('Pixel intensity');
ylabel('Probability density');
hold on; 

% Apresentação das distribuições e do histograma

plot(water_tmp, exp_water, water_tmp, ray_water, water_tmp, norm_water, 'LineWidth', 2);
legend('Histogram', 'Exponential', 'Rayleigh', 'Normal', 'Location', 'best');

%% R2 a)

% Segmentação da imagem por pixel conforme a distribuição rayligh

water_seg = log(raylpdf(I, ray_param_water));
ice_seg = log(raylpdf(I, ray_param_ice));

Segmentation = ice_seg > water_seg;

figure;
imagesc(I);
hold on 
contour(logical(Segmentation), 'LineColor', 'w');
title('Segmentation');

%% R2 b)

% Segmentação da imagem por pixel com influência dos vizinhos 5x5 conforme a distribuição rayligh

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

% Verificação das segmentações na região do gelo
[m,n] = size(ice);
total = m*n;

% Segmentação Patch
correct = 0;
patch = ones(5);
water_patch_ice = conv2(log(raylpdf(ice, ray_param_water)), patch, 'same');
ice_patch_ice = conv2(log(raylpdf(ice, ray_param_ice)), patch, 'same');

correct = sum(ice_patch_ice > water_patch_ice, 'all');
RatePatchIce = correct/total

% Segmentação Pixel
correct = 0;
water_seg_ice = log(raylpdf(ice, ray_param_water));
ice_seg_ice = log(raylpdf(ice, ray_param_ice));

correct = sum(ice_seg_ice > water_seg_ice, 'all');

RatePixelIce = correct/total


% Verificação das segmentações na região da àgua
[m,n] = size(water);
total = m*n;

% Segmentação Patch
correct = 0;
patch = ones(5);
water_patch_water = conv2(log(raylpdf(water, ray_param_water)), patch, 'same');
ice_patch_water = conv2(log(raylpdf(water, ray_param_ice)), patch, 'same');

correct = sum(water_patch_water > ice_patch_water, 'all');
RatePatchWater = correct/total

% Segmentação Pixel
correct = 0;
water_seg_water = log(raylpdf(water, ray_param_water));
ice_seg_water = log(raylpdf(water, ray_param_ice));

correct = sum(water_seg_water > ice_seg_water, 'all');

RatePixelWater = correct/total
