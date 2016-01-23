clc,clear,close all;
addpath('../function_set/')

Tb = 1;                                 % Duration of signal
Ns = 1;                                 % # of sumbols
fmax = 1;                             % max freq for signal
fs = 32*fmax;                       % sampling rat
T = 1/fmax;                          % transmition period
alpha = 0.35;                          % Square Root Raise Cosine filter's alpha 

xlen = 0;                               % code length / chirp number
slen = 0;                               % symbol length
%%--signal--%%
symbol = f_mseq([1, 3, 6], [1, 0, 0, 0, 0], 1);
% symbol = [1, -1, 1, 1];
% symbol = [1, 0, 0, 0, 1, 1, 1, 0, 1, 1];
% symbol = [-1, +1, +1, +1, -1, -1, -1, +1, -1, -1];

databits = [1, 1, 1, 1, 1, 1, 1, 0, 0, 1]*2-1;
% databits = [1]
x = kron([0, databits], symbol); %  the 0 here is to aviod negative frequence parts

xlen = length(x) * Tb * fs;
slen = length(symbol);
% xlen = 100;
df = fs/xlen;
dt = 1/fs;
% dt = 1/ df/xlen;

% turn to freq domain
[xf, f_range] = f_signalPulse_f(x, Tb, xlen, fs);
%     pf = Tb * sinc(f_range * Tb) .* exp(-j * pi * f_range * Tb); % the h(f) of a gate
%     data  = xf .* pf;
%     y = ifft(data)/dt;
%     plot(abs(y));
    
%%--generate the h(f) of the pulse-shaping filter--%%
hf = f_SRRC_generator(T, alpha, f_range);
% hf = Tb * sinc(f_range * Tb) .* exp(-j * pi * f_range * Tb); 

%%--form the signal--%%
sign_f = xf .* hf;

%%--channel--%%
sign_out_f = sign_f;

%%--after SRRC-filter on Reciver--%%
rec_sign_f = sign_out_f;

%%--generate the signal for m-seq--%%
[sf, f_range_s] = f_signalPulse_f(symbol, Tb, xlen, fs);  % f_range_s = f_range
%%--generate the matched filter--%%
% hf_r = f_SRRC_generator(T, alpha, f_range);
hf_r = hf;
matchfilter_f = conj(sf .* hf_r);


%%--impliment match filter--%%
match_out_f = rec_sign_f .* matchfilter_f;



%%--plot--%%
figure(1);
plot((0:xlen-1)*dt,  real(ifft(sign_f)) /dt);
hold on;
plot((0:xlen-1)*dt,  ones(1, xlen)/sqrt(T), 'r');
hold on;
plot((0:xlen-1)*dt,  -ones(1, xlen)/sqrt(T), 'r');
hold on;
title('signal transmated in channel');
xlabel('time/sec')
ylabel('amplitude/V')

figure(2);
plot((0:xlen-1)*dt,  real(ifft(rec_sign_f)) /dt);
hold on;
plot((0:xlen-1)*dt,  ones(1, xlen)/sqrt(T), 'r');
hold on;
plot((0:xlen-1)*dt,  -ones(1, xlen)/sqrt(T), 'r');
hold on;
title('signal after SRRC-filter in channel');
xlabel('time/sec')
ylabel('amplitude/V')

% figure(3);
% % plot((0:xlen-1)*dt,  real(ifft(match_out_f)) /dt);
% plot((0:xlen-1)*dt,  real(ifft(conj(matchfilter_f))) /dt);
% hold on;
% plot((0:xlen-1)*dt,  ones(1, xlen)/sqrt(T), 'r');
% hold on;
% plot((0:xlen-1)*dt,  -ones(1, xlen)/sqrt(T), 'r');
% hold on;

figure(4);
% plot((0:xlen-1)*dt,  real(ifft(match_out_f)) /dt);
plot((0:xlen-1)*dt,  real(ifft(match_out_f)) /dt/sqrt(T));
hold on;
plot((0:xlen-1)*dt,  slen*ones(1, xlen)/sqrt(T), 'r');
hold on;
plot((0:xlen-1)*dt,  slen*-ones(1, xlen)/sqrt(T), 'r');
hold on;
xlabel('time/sec')
ylabel('amplitude/V')