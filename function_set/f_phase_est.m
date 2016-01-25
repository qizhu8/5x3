function phase_est = f_phase_est(sign_t, matchfilter_f, phase_est_resolution)

% % % % % % % % % % %
% clc,clear,close all
% load vars
% sign_t = sign_ch_out_t;
% clear sign_ch_out_t;
% % % % % % % % % % %
phase_range = [0, 2*pi];
matchVal = [-1, -inf];
matchVal(1) = sum(real(sign_t) .* real(sign_t)); 
minloc = 2; % matchVal(minloc) is the minimum
phase_delat = phase_range(2) - phase_range(1);
index = 0;
while phase_delat >= phase_est_resolution && index < 10000
    phase_try = min(phase_range) + phase_delat / 2;
    sign_test_t = real(sign_t * exp(-j * phase_try)); 
    matchVal(minloc) = sum(sign_test_t .* sign_test_t);
    phase_range(minloc) = phase_try;
    [~, minloc] = min(matchVal);
    phase_delat = max(phase_range) - min(phase_range);
    index = index + 1;
%     [phase_range, matchVal, minloc]
end
phase_est = -phase_try;