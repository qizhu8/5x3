function coe = f_SRRC_generaRtor(T, alpha, range, timeDomain_onoff)

if nargin == 3
    timeDomain_onoff = 0;
end
if nargin ~= 3 && nargin ~= 4
    error('please check the number of input. the input should be ''T'', ''alpha'', ''range'', ''timeDomain_onoff');
end

plotOn = 0;

% % % % % % % % % % % % % % %
% clc,clear,close all
% T = 1;
% alpha = 0.125;
% % range = -1 : 0.1 : 1;
% range = linspace(-1, 1, 100);
% timeDomain_onoff = 0;
% plotOn = 1; % for debug
% % % % % % % % % % % % % % %

coe = zeros(size(range));
if ~timeDomain_onoff
    f = range;
    % freq domain
        coe = sqrt( T/2 * ( 1 - sin( pi * T .* (abs(f) - 1/2/T)/alpha  ) ) ); % there is something wrong with the last formula
%     coe = sqrt(T .* cos( pi * T / 2 / alpha .* (abs(f) - (1 - alpha)/2/T) ).^2);
    
    % flat part
    freq_thres1 = (1 - alpha) /2/T;
    index = and((f <= freq_thres1) , (f >= -freq_thres1));
    coe(index) = sqrt(T);
    
    freq_thres2 = (1 + alpha) /2/T;
    index = or( (f <= -freq_thres2), (f >= freq_thres2) );
    coe(index) = 0;
else
    % time domain
    t = range;
    
    sincNum = sin(pi * t / T); % numerator of the sinc function
    sincDen = (pi * t / T); % denominator of the sinc function
    sincDenZero = abs(sincDen) < eps;%the eps is 2.2204e-016
    sincOp = sincNum ./ sincDen;
    sincOp(sincDenZero) = 1; % sin(pix/(pix) =1 for x =0 L'Hospital Rule, or the position is NaN
    
    
    cosNum = cos(alpha * pi * t / T);
    cosDen = (1 - ( 2 * alpha * t / T ).^2);
    cosDenZero = abs(cosDen) < eps;
    cosOp = cosNum ./ cosDen;
    cosOp(cosDenZero) = pi/4;
    coe = sqrt(sincOp.*cosOp);
end

if plotOn
    grid on
    hold on
%     coe = fftshift(ifft(coe));
    plot(range, coe, 'b-');hold on;
    plot(range, coe, 'r*');
end


