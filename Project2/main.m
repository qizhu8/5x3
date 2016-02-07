clc,clear,close all;
addpath('../function_set/Source')
addpath('../function_set/Synchronize')
addpath('../function_set/Filter')

%%--parameters--%%
% Ns = 1;                               % # of sumbols
fmax = 1;                                % max freq for signal /Hz
fs = 2*fmax;                           % sampling rat /Hz
T = 1/fmax;                            % transmition period /sec // Duration of symboll /sec
alpha = 0.35;                          % Square Root Raise Cosine filter's alpha
freq_offset = 0.3;                    % preset frequency offset /Hz
phase_offset = pi/5;                %  phase offset /rad
delay = 0;                                % delay for reveiver  /chip
freq_est_resolution = 0.001;    % the density/resolution of freq scan
freq_est_range = -fmax: freq_est_resolution: fmax;  % the freq offset we are going to scan
N0_2 = 0.0002;

freq_est_switcher = 1;              % 0: disable, else enable
phase_est_switcher = 1;           % 0: disable, else enable

phase_est_resolution = pi/3600;

%%--pre-allocated variable--%%
xlen = 0;                               % code length / chirp number
slen = 0;                               % symbol length
f_range = [];
t_range = [];
% % % % % % % % % % % % % % % % % % % % % %
%                                                                                 %
%                              Signal Part                                  %
%                                                                                 %
% % % % % % % % % % % % % % % % % % % % % %
%%--signal generation--%%
symbol = f_mseq([1, 3, 6], [1, 0, 0, 0, 0], 1);
% symbol = [1, -1, 1, 1];
% symbol = [1, 0, 0, 0, 1, 1, 1, 0, 1, 1];
% symbol = [-1, +1, +1, +1, -1, -1, -1, +1, -1, -1];

databits = [1, 1, 1, 1, 1, 1, 1, 0, 0, 1]*2-1;
% databits = [1];
% databits = [1]
x = kron([0, databits], symbol); %  the 0 here is to aviod negative frequence parts

xlen = length(x) * T * fs;
slen = length(symbol);
% xlen = 100;
df = fs/xlen;
dt = 1/fs;
% dt = 1/ df/xlen;

% turn to freq domain
[xf, f_range] = f_signalPulse_f(x, T, xlen, fs);
%     pf = Tb * sinc(f_range * Tb) .* exp(-j * pi * f_range * Tb); % the h(f) of a gate
%     data  = xf .* pf;
%     y = ifft(data)/dt;
%     plot(abs(y));

%%--generate the h(f) of the pulse-shaping filter--%%
hf = f_SRRC_generator(T, alpha, f_range);
% hf = Tb * sinc(f_range * Tb) .* exp(-j * pi * f_range * Tb);

%%--form the signal--%%
sign_f = xf .* hf;
sign_out_t = ifft(sign_f);

%%--form the time axis--%%
t_range = (0:xlen-1 + delay)/fs;
% % % % % % % % % % % % % % % % % % % % % %
%                                                                                 %
%                               Channel Part                              %
%                                                                                 %
% % % % % % % % % % % % % % % % % % % % % %
%%--channel--%%
sign_ch_out_t = [zeros(1, delay), sign_out_t]  ;
% add freq & phase offset
sign_ch_out_t = sign_ch_out_t .* exp(j*2*pi * t_range * freq_offset + j * phase_offset);

% add noise
noise_r = sqrt(N0_2*fmax/2) * randn(1, xlen);
noise_i = sqrt(N0_2*fmax/2) * randn(1, xlen) * j;
sign_ch_out_t = sign_ch_out_t + noise_r + noise_i;
% % % % % % % % % % % % % % % % % % % % % %
%                                                                                 %
%                               Receiver Part                              %
%                                                                                 %
% % % % % % % % % % % % % % % % % % % % % %
%%%--pre-generate symbol--%%%
%%--generate the signal for m-seq--%%

% same as the transmitter
[sf, f_range_s] = f_signalPulse_f(symbol, T, xlen, fs);  % f_range_s = f_range

%%--generate the matched filter--%%
hf_r = f_SRRC_generator(T, alpha, f_range);
% hf_r = hf;
matchfilter_f = conj(sf .* hf_r);

%%--freq&time estimation--%%
% save vars sign_ch_out_t matchfilter_f freq_est_range fs freq_offset delay
if freq_est_switcher
    [freq_est, delay_est] = f_freq_time_est(sign_ch_out_t, matchfilter_f, freq_est_range, fs);
    freq_est
    sign_ch_out_t = sign_ch_out_t .*exp(-j * 2 * pi * t_range * freq_est); % kill the frequency offset
end
sign_ch_out_t = sign_ch_out_t(delay+1:end);                                    % kill the delay

% % % % figure(5)
% % % % plot(real(sign_ch_out_t))
%%--phase estimation--%%
% save vars sign_ch_out_t matchfilter_f phase_est_resolution
if phase_est_switcher
    phase_est = f_phase_est(sign_ch_out_t, matchfilter_f, phase_est_resolution);
    phase_est
    sign_ch_out_t = sign_ch_out_t .* exp(-j * phase_est);
end

rec_sign_f = fft(sign_ch_out_t);


%%--impliment match filter--%%
match_out_f= rec_sign_f .* matchfilter_f;

%%--plot--%%
% figure(1);
% plot((0:xlen-1)*dt,  real(ifft(sign_f)) /dt);
% hold on;
% plot((0:xlen-1)*dt,  ones(1, xlen)/sqrt(T), 'r');
% hold on;
% plot((0:xlen-1)*dt,  -ones(1, xlen)/sqrt(T), 'r');
% hold on;
% title('signal transmated in channel');
% xlabel('time/sec')
% ylabel('amplitude/V')
% 
% figure(2);
% plot((0:xlen-1)*dt,  real(ifft(rec_sign_f)) /dt);
% hold on;
% plot((0:xlen-1)*dt,  ones(1, xlen)/sqrt(T), 'r');
% hold on;
% plot((0:xlen-1)*dt,  -ones(1, xlen)/sqrt(T), 'r');
% hold on;
% grid on
% title('signal after SRRC-filter in channel');
% xlabel('time/sec')
% ylabel('amplitude/V')

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
% plot((0:xlen-1)*dt,  real(ifft(match_out_f)) /dt/sqrt(T));
plot((0:xlen-1)*dt,  real(ifft(match_out_f)) /dt/sqrt(T));
hold on;
plot((0:xlen-1)*dt,  slen*ones(1, xlen)/sqrt(T), 'r');
hold on;
plot((0:xlen-1)*dt,  slen*-ones(1, xlen)/sqrt(T), 'r');
hold on;
grid on;
hold on;
xlabel('time/sec')
ylabel('amplitude/V')