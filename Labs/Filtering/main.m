%% Lab 3 - DSP - Filtering 
% Jamilson Pinheiro - 87025
% Mauro Pungo - 87467
%% R1a) Listen to the sound
% We hear a great classic by the Fugees, unfortunately ruined by some
% noise that I describe as "crepitante": some "ticks" similar to the noise of popcorn in the making.
[y, Fs] = audioread('fugee.wav');
%sound(y, Fs);
%% R1b)Plot the Signal
% We can clearly distinguish the music's component and the noisy components
% as the latter are sort of impulses, with very short duration and much higher
% amplitude than the signal.
figure()
plot(y);
title("Signal")
xlabel("Sample")
ylabel("Amplitude")
%% R1c) Visualise Signal�s Magnitude Spectrum
% If we only at the right half of the spectrum,we can see that the
% amplitude decreases with the frequency, being that the highest amplitudes
% are located near the central frequency. This makes sense considering the additive
% noise is of the type impulse with lower frequency than the signal's, as mentioned before.
%vIn the spectrum this means that it is near the beginning of the spectrum (central
% frequency) that the noise and signal components sum, leading to the
% higher amplitudes near the center.

Y = fft(y);
figure()
semilogy(abs(fftshift(Y)))

title("Signal�s Magnitude Spectrum");
xlabel("Sample");
ylabel("Amplitude");
grid on
%% LTI filter
%% R2a)
% At the sample 257 (~807.4 rad), which is half of the total amount of samples, the
% amplitude is approximately 0.707, which is exactly the -3 dB of the DC gain of the
% filter ,1. This corresponds to loss of half of the signal's power at this frequency.

%repetimos com f_c = 3/4,1/4,1/8
[b,a] = butter(10, 0.5); 
[h, w] = freqz(b, a);
plot(abs(h));

title("Spectrum of 10th order Butterworth filter");
xlabel("Frequency");
ylabel("Amplitude");
%% R2b) / R2c)
% f = (f_cutoff*Fs)/w = (f_cutoff*Fs)/(2*pi) = 0.5*pi*8/(2*pi) = 2 kHz
y_filtered = filter(b,a,y);
plot(y_filtered);
figure()
plot(y);
hold on
plot(y_filtered);

title("Comparison of (un-)filtered signals");
xlabel("Sample");
ylabel("Amplitude");
%sound(y_filtered, Fs);

% On the graph of the filtered signal, the amplitude of the signal is
% globally lower than the unfiltered version. Furthermore, the atenuated
% components are essentially the impulses identified in question 1, while
% the other components of the signal did not vary much in amplitude
%% R2d)
Y_filtered = fft(y_filtered);
figure()
semilogy(abs(fftshift(Y))) 
hold on
semilogy(abs(fftshift(Y_filtered)))
grid on

title("Comparison of (un)filtered signals' spectrum");
xlabel("Sample");
ylabel("Amplitude");

% As stated before, the atenuation is visibly higher for frequencies above
% f_r = 2 kHz

%% R2e
% By playing the signal, the amount and amplitude of the noisy "clicks" is notably lower, although
% always present. Like all filtering operations, some of the components of
% the music are also atenuated. In this case, due to the nature of the used
% filter, the highest notes are also atenuated, which doesn't make justice
% to Lauryn Hill's voice.

%% R2f

% Repeating the above operations with f_c = [3/4 , 1/4 , 1/8] we conclude
% the same as before: a tradeoff between signal preservation and noise
% atenuation has to be made. With lower f_c, more noise is atenuated but so
% are the higher notes of the song. Likewise, by increasing f_c we maintain
% the signal's integrity in detriment of more audible noisy components.

%% R3a/b) Filtering with a median filter

%  CAUSALITY
% For an index n, the output y(n) depends only on lower (or equal) indexes. Therefore
% the filter is causal.


%  LINEARITY

% Given 2 inputs x1(n) and x2(n)  (and their responses y1,y2), and x3(n) = x1(n) + x2(n), it's clear
% that y3(n), the response of x3, is not equal to y2 + y1. Therefore the
% filter is non-linear

% TIME INVARIANCE

% The shape of the filter does not change upon changes in sample. It is
% time invariant


% STABILITY

% for x(n) = delta(n) -> y(n) = 0 . Therefore the filter is stable


figure()
y_median_filtered = medfilt1(y,3);
plot(y)
hold on 
plot(y_median_filtered);

xlabel("Samples")
ylabel("Amplitude")
legend("Unfiltered Signal","Filtered Signal [median filter]");
title("Signal");
%sound(y_median_filtered, Fs);


%% R3 c)
Y_filtered_median = fft(y_median_filtered);
figure()
semilogy(abs(fftshift(Y))) 
hold on
semilogy(abs(fftshift(Y_filtered_median)))
xlabel("Frequency")
ylabel("Amplitude")
legend("Unfiltered Signal","Filtered Signal [median filter]");
title("Frequency spectrum of median-(un)filtered signal");
grid on


%% R3 d)

% The signal is much clearer, the noisy components are almost inaudible
% now. There are parts which voice clarity took a toll but overall the signal is audible 
%and with a tolerable noise threshold.

%% R3 e)

% Tested with orders 2,4,6,8
signal = medfilt1(y,8);

%sound(signal,Fs);

% For median filters of order 1 and 2, the noise is barely atenuated in
% comparison with the original signal since the filtering window is too
% small to really change the values locally enough to atenuate the
% impulses.
% For median filters of order higher than 3, the ticking noises are still
% greatly atenuated, inaudible. But the higher the order, the higher the
% distortion in the voice, due to the fact that the sliding window is now
% too big to maintain local coherence of the signal.

%% R3 f)

% If we describe the signal as y(n) = x(n) + s(n) , where s(n) is the
% additive noise, then using a LIT filter, the output will always have a
% noise component due to the linearity. The influence of s(n) on the output
% is linear to the influence of x(n). Higher frequencies of the signal will also be filtered.
% Therefore there's only so much we can filter the noise without affecting the quality of the song.

% The tradeoff between noise atenuation and signal integrity is less when
% using a non-linear filter such as the median filter. With such filter,
% the only drawbacks are the meticulous choice of the parameters (filter
% order in this case), and possibly a more complex/expensive hardware conception of the filter.



