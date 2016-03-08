clc,clear,close all;
result_awgn_channel = 'product_awgn.mat';
result_ray_no_side_info = 'product_ray_no_side.mat';
result_ray_with_side_info = 'product_ray_with_side.mat';

load(result_awgn_channel);
ber_awgn = ber;
save ber;
clear;

% load(result_ray_with_side_info);
load('product_ray_with_side.mat')
ber_with_side = ber;
load ber
save ber ber_awgn ber_with_side
clear;

% load(result_ray_no_side_info);
load('product_ray_no_side.mat');
ber_no_side = ber;
load ber
save ber ber_awgn ber_with_side ber_no_side ebn0db
clear;

load ber
semilogy(ebn0db(1:17), ber_awgn, 'rd'); hold on;
semilogy(ebn0db, ber_no_side(1:length(ebn0db)), 'gx'); hold on;
semilogy(ebn0db, ber_with_side(1:length(ebn0db)), 'bo'); hold on;

delete ber.mat

grid on;
legend('AWGN Channel', 'Rayleigh Fading without Side Info', 'Rayleigh Fading with Side Info');

pause(200)