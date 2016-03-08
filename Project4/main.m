clc,clear,close all

alpha = 0:0.01:1.1;
sigma2 = 0.1;
pdf = zeros(1, length(alpha));

for index = 1:length(alpha)
	pdf(index) = f_RayleighPDF(sigma2, alpha(index));
end

plot(alpha, pdf)