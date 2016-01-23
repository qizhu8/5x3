% function [freq_offset, delay] = f_freq_time_est(sign, matchfilter_f, freq_range, fs)

% % % % % % % % % % % % % % 
clc,clear,close all;
load vars
sign = sign_ch_out_t;
freq_range = freq_est_range;
clear sign_ch_out_t freq_est_range freq_est_resolution;
% % % % % % % % % % % % % % 

A = exp(-j * 2 * pi )
for index = 1:length(freq_range)
    
end
