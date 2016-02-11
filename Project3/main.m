clc,clear,close all
addpath('../funcset/coding')

G = [
    1, 0, 0, 0, 1, 0, 1
    0, 1, 0, 0, 1, 1, 1
    0, 0, 1, 0, 1, 1, 0
    0, 0, 0, 1, 0, 1, 1
    ];									% (7, 4) Hamming code's generator matrix
k = -6:10;
niterations = 4;
ebn0db = k/2;
ber = zeros(size(k));
cb = f_generateCodeBook(G);

for k_index = 1:length(k)
    ebn0 = 10^(ebn0db(k_index) / 10);			% Eb/N0 in voltage
    EN0 = ebn0 * 16 / 40;                          % info code bit's amplitude / N0
    E = 1;                                      % symbol energy
    N0 = 1 / EN0;                                 % N0 / info code bit's amplitude
    sigma = sqrt(N0 / 2);                         % amplitude for noise
    nerrors = 0;                            	% number of error bits
    ntrials = 0;                                % number of total bits
    if (k_index < 13)							% set threshold for simulation
        threshold = 2000;
    else
        threshold = 1000;
    end
    while nerrors < threshold                   % run until collect enough error
        ntrials = ntrials + 1;                  % each time, the number of total round +1
        b = sign(rand(4, 4) - 0.5);             % generate some random signal
        ph = mod(-0.5 * (b - 1) * G, 2);        % horizontal parity check
        pv = mod(-0.5 * (b' - 1) * G, 2);       % vertical parity check
        LVext = zeros(4, 4);                    % initial the prior info of info bits
        LHext = zeros(4, 4);
        c = [b, 1 - 2*ph(:, 5:7), 1-2*pv(:, 5:7)];	% translated codeword 4x10.
        r = sqrt(E) * c + sigma * randn(4, 10);		% received vector + noise
        LHRCVD = 2*r(:, 1:7) * sqrt(E) / sigma^2;   % extrinisic Horizontal information
        LVRCVD = 2*[r(:,1:4)' r(:,8:10)]*sqrt(E)/sigma^2;   % extrinisic Vertical information
        
        for j = 1 : niterations
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %  Compute the likelihoods based on horizontal         %
            %  parity checks (including extrinisic and apriori)    %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            Ltemp = [LHRCVD(1:4,1:4)+LVext(1:4,1:4)' LHRCVD(:,5:7)];
                        
            LHN = zeros(4,4);
            LHD = zeros(4,4);
            for kcolbit = 1 : 4
                for krowbit = 1 : 4
                    for m = 1 : 16
                        A = exp((1-cb(m,:))*Ltemp(krowbit,:)');
                        if cb(m,kcolbit) == 0
                            LHN(krowbit,kcolbit) = LHN(krowbit,kcolbit) + A;
                        else
                            LHD(krowbit,kcolbit) = LHD(krowbit,kcolbit) + A;
                        end
                    end
                end
            end
            
            LH = log(LHN./LHD);
            LHext = LH - LVext' - LHRCVD(1:4,1:4);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %  Compute the likelihoods based on vertical           %
            %  parity checks (including extrinisic and apriori)    %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            Ltemp = [LVRCVD(1:4,1:4)+LHext(1:4,1:4)' LVRCVD(:,5:7)];
            
            LVN = zeros(4,4);
            LVD = zeros(4,4);
            for kcolbit = 1 : 4
                for krowbit = 1 : 4
                    for m = 1 : 16
                        A = exp((1-cb(m,:))*Ltemp(krowbit,:)');
                        if cb(m,kcolbit) == 0
                            LVN(krowbit,kcolbit) = LVN(krowbit,kcolbit) + A;
                        else
                            LVD(krowbit,kcolbit) = LVD(krowbit,kcolbit) + A;
                        end
                    end
                end
            end
            LV = log(LVN./LVD);
            LVext = LV - LHext' - LVRCVD(1:4,1:4);
        end;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %  Compute the decisions based on likelihoods          %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
        
        bh = sign(LHRCVD(1:4,1:4) + LVext(1:4,1:4) + LHext(1:4,1:4));
        nerrors = nerrors + 16 - sum(sum(bh == b));
        if mod(ntrials,500) == 0
            [ntrials nerrors]
            save product4
            semilogy(ebn0db, ber, 'r')
            axis([-3, 6, 1e-5 1])
            grid on
        end
    end;
    ntrials
    ber(k_index) = nerrors/ntrials/16
end;
semilogy(ebn0db, ber, 'r', 'LineWidth', 2)
axis([-3 6 1e-5 1])
grid on
xlabel('E_b/N_0 (dB)', 'FontSize', 16)
ylabel('BER', 'FontSize', 16)