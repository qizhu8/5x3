clc,clear,close all;
fs = 20;
% we define T = 1,so we ignore it!!
% defining the sinc filter
sincNum = sin(pi* (-fs:1/fs:fs)); % numerator of the sinc function
sincDen = (pi*(-fs:1/fs:fs)); % denominator of the sinc function
sincDenZero = abs(sincDen) < eps;%the eps is 2.2204e-016
sincOp = sincNum./sincDen;
sincOp(sincDenZero) = 1; % sin(pix/(pix) =1 for x =0 L'Hospital Rule, or the position is NaN

alpha = 0;
cosNum = cos(alpha*pi*(-fs:1/fs:fs));
cosDen = (1-(2*alpha*(-fs:1/fs:fs)).^2);
cosDenZero = abs(cosDen) < eps;
cosOp = cosNum./cosDen;
cosOp(cosDenZero) = pi/4;
gt_alpha0 = sincOp.*cosOp;
N = length(gt_alpha0);
GF_alpha0 = fft(gt_alpha0,N);

alpha = 0.5;
cosNum = cos(alpha*pi*(-fs:1/fs:fs));
cosDen = (1-(2*alpha*(-fs:1/fs:fs)).^2);
cosDenZero = abs(cosDen) < eps;
cosOp = cosNum./cosDen;
cosOp(cosDenZero) = pi/4; % L'Hospital Rule
gt_alpha5 = sincOp.*cosOp;
N = length(gt_alpha5);
GF_alpha5 = fft(gt_alpha5,N);

alpha = 1;
cosNum = cos(alpha*pi*(-fs:1/fs:fs));
cosDen = (1-(2*alpha*(-fs:1/fs:fs)).^2);
cosDenZero = find(abs(cosDen)<eps);
cosOp = cosNum./cosDen;
cosOp(cosDenZero) = pi/4;
gt_alpha1 = sincOp.*cosOp;
N = length(gt_alpha5);
GF_alpha1 = fft(gt_alpha1, N);

close all
figure
plot(-fs:1/fs:fs, gt_alpha0, 'r', 'LineWidth', 2)
hold on
plot(-fs:1/fs:fs, gt_alpha5, 'g', 'LineWidth', 2)
plot(-fs:1/fs:fs, gt_alpha1, 'b', 'LineWidth', 2)
legend('alpha=0', 'alpha=0.5', 'alpha=1');
grid on
xlabel('Time, t')
ylabel('Amplitude, g(t)')
title('Figure for Time Field')

figure
%除以fs的原因是因为采样导致幅度加权了。
plot((-N/2:N/2-1)/N*fs, abs(fftshift(GF_alpha0))/fs,'r','LineWidth',2);
hold on
plot((-N/2:N/2-1)/N*fs, abs(fftshift(GF_alpha5))/fs,'g','LineWidth',2);

plot((-N/2:N/2-1)/N*fs, abs(fftshift(GF_alpha1))/fs,'b','LineWidth',2);
legend('alpha=0','alpha=0.5','alpha=1');
axis([-2 2 0 1.2])
grid on
xlabel('Frequency, f')
ylabel('Amplitude, |G(f)|')
title('Figure for Freq Field')