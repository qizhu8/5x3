clc,clear,close all
G=[
    1, 0, 0, 0, 1, 0, 1
    0, 1, 0, 0, 1, 1, 1,
    0, 0, 1, 0, 1, 1, 0,
    0, 0, 0, 1, 0, 1, 1
    ];
niterations = 4;
sigma2 = 0.5;

signal = reshape(randi(2, 4, 4)*2-3, 1, []);
Code = f_TurboCoding(signal, G);
signal_dec = f_TurboDecoding(Code, G, sigma2, 1, f_generateCodeBook(G), niterations);

nnz(signal-signal_dec)
