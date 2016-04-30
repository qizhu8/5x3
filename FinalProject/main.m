clc,clear,close all;

SNR_range = -25:-5;

% errorThres_low = 30;
% errorThres_mid = 200
% errorThres_high = 30000;
% SNR_thres_mid = -15;
% SNR_thres_high = -7;

error = zeros(size(SNR_range));
baseNum = zeros(size(SNR_range));

resume = 0; % if resume = 0, start from scratch, or start from last result


if resume ~= 0;
    load tmpProgress.mat
    startPoint = SNR_index;
else
    delete tmpProgress.mat
    startPoint = 1;
end

for SNR_index = startPoint:length(SNR_range)
    SNR = SNR_range(SNR_index);
%     if SNR >= SNR_thres_high
%         errorThres = errorThres_low;
%     elseif SNR >= SNR_thres_mid
%         errorThres = errorThres_mid;
%     else
%         errorThres = errorThres_low;
%     end
    errorThres = (3*exp(-0.31*SNR)-2);
    drawSwitch = 1;
    while error(SNR_index) < errorThres
        [error(SNR_index), errorThres]
        [errorBits, infoBits] = f_txrxch(SNR, drawSwitch);
        error(SNR_index) = error(SNR_index) + errorBits;
        baseNum(SNR_index) = baseNum(SNR_index) + infoBits;
        save tmpProgress SNR_index SNR_range error baseNum
        drawSwitch = 0;
    end
    BER = error./ baseNum;
    figure(2)
    semilogy(SNR_range, BER);
end
load train
delete tmpProgress.mat
sound(y,Fs)
