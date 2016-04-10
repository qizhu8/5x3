function Code = f_TurboCoding(signal, G)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% clc,clear,close all
% G=[
%     1, 0, 0, 0, 1, 0, 1
%     0, 1, 0, 0, 1, 1, 1,
%     0, 0, 1, 0, 1, 1, 0,
%     0, 0, 0, 1, 0, 1, 1
%     ];
% signal = randi(2, 4, 4)*2-3
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[sign_len, codedSign_len] = size(G);
if length(signal) ~= sign_len*sign_len
    error('please check the length of signal and the rows of G')
end
signal = reshape(signal, sign_len, sign_len);
ph=mod(-0.5*(signal-1)*G,2);
pv=mod(-0.5*(signal'-1)*G,2);
Code = [signal, 1-2*ph(:, sign_len+1:end), 1-2*pv(:, sign_len+1:end)];
Code = reshape(Code, 1, []);