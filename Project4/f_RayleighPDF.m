function f = f_RayleighPDF(sigma2, alpha)
%%%%%%%%%%
% clc,clear,close all;
% sigma2 = 1;
% alpha = 0;

%%%%%%%%%%%

if alpha < 0
	f = 0;
else
	f = alpha / sigma2 * exp(-alpha * alpha / 2 / sigma2);
end
