function [data, f] = f_signalPulse_f(x, Tb, N, fs)
% % % % % % % % % % % % % % 
% This function is to generate the signal in frequency domain
% 
% Input:
%         x:            the sequence of bits   e.g. 0 1 1 0 0 1
%         Tb:          the duration of the bits, (sec)
%         N:           # of sample points we need for the whole simulation
%         fs:           sample rate
% Output:
%         data:       data in the frequency domain
%         f:            frequency-axis
% % % % % % % % % % % % % %
if nargin ~= 4
    error('please check the input. input should be: ''x'', ''Tb'', ''N'', ''fs''\n');
end

plotOn = 0;

% % % % % % % % % % % % % % 
% clc,clear,close all
% x =[1, 0, 0, 0, 1, 1, 1, 0, 1, 1];
% Tb = 1;
% N = 10*2^8;
% fs = 2^8;
% plotOn = 1; % for debug
% % % % % % % % % % % % % % 

df = fs / N;        % by DSP, the frequency gap for the result of fft is df = fs/N 
f = zeros(1, N);
halfPoint = floor(N/2);
f(1: halfPoint) = (1 : halfPoint) * df - df;        % the positive part of the frequency axis
f(halfPoint+1 : N) = (0 : halfPoint-1) * df - fs/2; % the symmetrical negative part of the frequency axis

data = zeros(1, N);
for index = 1:length(x)
    data = data + x(index) * exp(-j * 2 * pi * f * (index-1) * Tb);
end

if plotOn
    dt = 1/fs/N;
    pf = Tb * sinc(f * Tb) .* exp(-j * pi * f * Tb); % the h(f) of a gate
    data  = data .* pf;
    y = ifft(data)/dt;
    plot(abs(y));
end













