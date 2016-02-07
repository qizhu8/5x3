function [freq_offset, delay] = f_freq_time_est(sign_t, matchfilter_f, freq_range, fs)

% % % % % % % % % % % % % % 
% clc,clear,close all;
% load vars
% sign_t = sign_ch_out_t;
% freq_range = freq_est_range;
% clear sign_ch_out_t freq_est_range freq_est_resolution;
% % % % % % % % % % % % % % 

parallel_filter_len = length(freq_range);
sign_len = length(sign_t);

sign_array_f = zeros(parallel_filter_len, sign_len);

% freq_range = 1:3;
% fs = 1;
% sign_len = 5;
A =exp(freq_range' * (0: sign_len-1) /fs * (-j * 2 * pi));       % array manifolds for estimation
sign_array_t = ones(parallel_filter_len, 1) * sign_t .* A;   % generate signal cluster for each match filter after freq modification

% transfer to frequency domain
for index = 1:parallel_filter_len
    sign_array_f(index , :) = fft(sign_array_t(index , :));
end

matchfilter_array = ones(parallel_filter_len, 1) * matchfilter_f;

sign_array_after_filter_f = sign_array_f .* matchfilter_array;

[~, maxIndex] = max(sum((sign_array_after_filter_f .* sign_array_after_filter_f)' ));
freq_offset = freq_range(maxIndex);
delay = 0;
