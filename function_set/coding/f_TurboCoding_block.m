function codedSeq = f_TurboCoding_block(signal, G)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% clc,clear,close all
% G=[
%     1, 0, 0, 0, 1, 0, 1
%     0, 1, 0, 0, 1, 1, 1,
%     0, 0, 1, 0, 1, 1, 0,
%     0, 0, 0, 1, 0, 1, 1
%     ];
% signal = reshape(randi(2, 4, 4)*2-3, 1, [])
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sign_len = size(G, 1);
if length(signal) ~= sign_len*sign_len
    error('please check the length of signal and the rows of G')
end
signal = reshape(signal, sign_len, sign_len);
ph=mod(-0.5*(signal-1)*G,2);
pv=mod(-0.5*(signal'-1)*G,2);
Code = [signal, 1-2*ph(:, sign_len+1:end), 1-2*pv(:, sign_len+1:end)];
Code = reshape(Code, 1, []);
codedSeq = Code;

% [sign_len, coded_len] = size(G);
% if mod(length(signal), sign_len*sign_len) ~= 0
%     error('please check the length of signal and the rows of G')
% end
% codeBlock = reshape(signal, [], sign_len*sign_len);
% codedSignalLen = sign_len * (coded_len * 2 - sign_len);
% codedSeq = zeros(1, size(codeBlock, 1) * codedSignalLen);
% for codeIndex = 1:size(codeBlock, 1)
%     signal_t = reshape(codeBlock(codeIndex, :), sign_len, sign_len);
%     ph=mod(-0.5*(signal_t-1)*G,2);
%     pv=mod(-0.5*(signal_t'-1)*G,2);
%     Code = [signal_t, 1-2*ph(:, sign_len+1:end), 1-2*pv(:, sign_len+1:end)];
%     Code = reshape(Code, 1, []);
%     codedSeq((codeIndex-1)*codedSignalLen + 1:codeIndex*codedSignalLen) = Code;
% end
