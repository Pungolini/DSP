clear 
close all
clc
%% Anomaly Detection in Energy Time Series Data
%% R1a)
% Function that receives a time series and returns the coeficcient 'a' for
% the AR model


%% R1 a) & b)

x_train = load('energy_train.mat');
% Obtaining the "a" coefficient
x = x_train.x_train;
N = 96;
a = AR_coef(x, N);

% Predicted signal 
[x_predicted, r] = deal(zeros(1, length(x)));
for n=1:length(x)
    if(n <= N)
        x_predicted(n) = x(n);
    else 
        x_predicted(n) = a*x(n-N); 
    end
    r(n) = x(n) - x_predicted(n);
end
% Plots
figure
plot(x);
hold on
plot(x_predicted);
hold on
plot(r)
legend('x_{train}', 'x_{predicted}', 'Residual');
grid on 
title('Predicted and Residual plots');
% As there are no anomalies, the error between the predicted and real
% values are small, as are the residuals. Since the production throughout
% the day is very similar daily (resulting in a signal that looks
% periodic), then it makes sense that the samples are well predicted.
% If this periodic aspect of the energy production would disappear (for
% example by computing with a monthly time frame). 
% Likewise, the residual is very small due to the prediction's accuracy.

%% R1c) Coeficient and the 
% Energy of the residual
Energy = 0;
for n=1:length(r)
    Energy = Energy + abs(r(n))^2; 
end
display(Energy);
display(a);
% a = 0.981 
% Energy = 0.3478
% We have x(n) = a*x(n-N) + r(n) <=> r(n) = x(n) - a*x(n-N)
% The coefficent a is very close to 1 (0.981), showing the big correlation
% between today's prediction and yesterday's samples. The formula above
% also allows us to understand why the residual r(n) is small, as is its
% energy. The bigger the variation in energy between days, the bigger the
% residual.
%% R1d) Short term model
P = 6;
a = AR_short_term_coef(r, P);

%% R1e) 
[r_predicted, e] = deal(zeros(1, length(r)));

for n=1:length(r)
    for k=1:P
        if(n <= k)
            r_predicted(n) = r(n);
        else        
            r_predicted(n)  = r_predicted(n) + a(k)*r(n-k);
        end
    end
    e(n) = r(n) - r_predicted(n);
end

x_new_prediction = x_predicted - r_predicted;

figure
plot(x);
hold on
plot(x_new_prediction);
hold on
plot(e)
legend('x_{train}', 'x_{prediction}', 'Residual');
grid on 
title('New Prediction and Residual plots');

Energy = 0;
for n=1:length(r)
    Energy = Energy + abs(r(n))^2; 
end
display(Energy);
display(a);

%% R1f) Coeficient and the Energy of the residual
Energy = 0;
for n=1:length(e)
    Energy = Energy + abs(e(n))^2; 
end
display(Energy);
display(a);

% a =
% 
%     0.5993
%     0.1496
%    -0.0031
%     0.2730
%    -0.1552
%    -0.0279
% The predictions still remains accurate to the samples. Gauging by eye,
% I'd say that the predictions are slightly better than for the long term
% model prediction, although not a significative difference.
% On the other sidethe residual's energy decreased (0.1248), and when looking
% at the plot, there are less impulse-like peaks.
% The magnitudes of the a coefficients are also much lower, being only once
% higher than 0.5. This shows that indeed the ST model does not depend that
% much on a single precedent sample but on the P samples.
% Doing an analogy with filters, this short term prediction would be a
% median/ non linear filter whereas the long term prediction would be an
% LIT filter.
%% Part2 Anomaly Detection R2a) & R2b) & R2c)
% Load test data
x_test = load('energy_test.mat');
x = x_test.x_test;

%figure(555);
%plot(x)
%grid on
%%

% Creating predicted signal
N = 96;
a = AR_coef(x, N);
% Predicted signal 
[x_predicted, r] = deal(zeros(1, length(x)));
for n=1:length(x)
    if(n <= N)
        x_predicted(n) = x(n);
    else 
        x_predicted(n) = a*x(n-N); 
    end
    r(n) = x(n) - x_predicted(n);
end
% Short term prediction
P = 6;
a = AR_short_term_coef(r, P);
[r_predicted, e] = deal(zeros(1, length(r)));
for n=1:length(r)
    for k=1:P
        if(n <= k)
            r_predicted(n) = r(n);
        else        
            r_predicted(n)  = r_predicted(n) + a(k)*r(n-k);
        end
    end
    e(n) = r(n) - r_predicted(n);
end
x_short_term_pred = x_predicted - r_predicted;

% Calculating anomaly
anomalies = Anomalies(x, x_short_term_pred); % SWITCH BETWEEN: x_predicted e x_short_term_pred !!!!!!! 
[pks, locs] = findpeaks(anomalies, 'MinPeakDistance', 50, 'MinPeakHeight', 0.1);
figure
plot(anomalies); % Values above > 0.1 count as an anomaly
hold on 
findpeaks(anomalies, 'MinPeakDistance', 50, 'MinPeakHeight', 0.1);

% R2b
% The short term model prediction detects more anomalies than the long term
% model prediction. It makes sense as we've seen that the short term model also
% performs better. Setting the threshold at 0.1, the ST model detects 20
% anomalies whereas the LT model detected only 16.
% Setting the threshold at 0.2, the LT model only detects 2 anomalies,
% which are the 2 obvious when looking at the test data. Meanwhile, the ST
% model detected 6 anomalies, which are the exact number detected by visual
% inspection of the data. Even visually, some of these anomalies are hard
% to detect. The ST model is therefore a very sensitive and accurate way of
% detecting the anomalies

% R2c

% Using again a median filter comparison, if we use more sample points between
% anomalies, then the effect of the precedent anomaly is mitigated. These
% extra points can be inserted using a mean/median/interpolation of the
% points between anomalies.