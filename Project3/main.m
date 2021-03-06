clc,clear,close all
addpath('../function_set/coding/')
tic
G=[
    1, 0, 0, 0, 1, 0, 1
    0, 1, 0, 0, 1, 1, 1,
    0, 0, 1, 0, 1, 1, 0,
    0, 0, 0, 1, 0, 1, 1
    ];
niterations = 4;
SNR_range = -6:10;
ebn0db = SNR_range / 2;
ber = zeros(size(SNR_range));
cb = f_generateCodeBook(G);
for SNR_index = 1 : length(SNR_range)
    fprintf('processing %d/%d\n', SNR_index, length(SNR_range));
    SNR = SNR_range(SNR_index);
    ebn0=10^(ebn0db(SNR_index) / 10.0); %
    EN0=ebn0*16/40;
    E=1;
    N0=1/EN0;
    sigma=sqrt(N0/2);
    nerrors=0;
    ntrials=0;
    if (SNR < 7) threshold=2000; end
    if (SNR >= 7) threshold=1000; end
    
    while nerrors < threshold
        ntrials=ntrials+1;
        b=sign(rand(4,4)-0.5);
        ph=mod(-0.5*(b-1)*G,2);
        pv=mod(-0.5*(b'-1)*G,2);
        LVext=zeros(4,4);
        LHext=zeros(4,4);
        
        %=========================================================%
        % Generate as 4 by 10 arrary. First 4 cols are info,
        % next three are horizontal parity checks and last
        % three are vertical parity checks.
        %=========================================================%
        
        
        c=[b 1-2*ph(:,5:7) 1-2*pv(:,5:7)];
        r=sqrt(E)*c+sigma*randn(4,10);
        LHRCVD=2*r(:,1:7)*sqrt(E)/sigma^2;
        LVRCVD=2*[r(:,1:4)' r(:,8:10)]*sqrt(E)/sigma^2;
        
        for j = 1 : niterations
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %  Compute the likelihoods based on horizontal         %
            %  parity checks (including extrinisic and apriori)    %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            Htemp = [LHRCVD(1:4,1:4)+LVext' LHRCVD(:,5:7)];
            LHN = zeros(4,4);
            LHD = zeros(4,4);
            for krowbit = 1 : 4
                for kcolbit = 1 : 4
%                     Htemp = [LHRCVD(1:4,1:4)+LVext' LHRCVD(:,5:7)];
%                     Htemp(:, kcolbit) = 0;
                    for m = 1 : size(cb, 1)
                        A = exp((1-cb(m,:))*(Htemp(krowbit,:)'));
                        if cb(m,kcolbit) == 0
                            LHN(krowbit,kcolbit) = LHN(krowbit,kcolbit) + A;
                        else
                            LHD(krowbit,kcolbit) = LHD(krowbit,kcolbit) + A;
                        end
                    end
                end
            end
            LHext = log(LHN./LHD);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %  Compute the likelihoods based on vertical           %
            %  parity checks (including extrinisic and apriori)    %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            Ltemp = [LVRCVD(1:4,1:4)+LHext' LVRCVD(:,5:7)];
            
            LVN = zeros(4,4);
            LVD = zeros(4,4);
            for krowbit = 1 : 4
                for kcolbit = 1 : 4
                    Ltemp = [LVRCVD(1:4,1:4)+LHext' LVRCVD(:,5:7)];
%                     Ltemp(:, kcolbit) = 0;
                    for m = 1 : size(cb, 1)
                        A = exp((1-cb(m,:))*Ltemp(krowbit, :)');
                        if cb(m, kcolbit) == 0
                            LVN(krowbit,kcolbit) = LVN(krowbit,kcolbit) + A;
                        else
                            LVD(krowbit,kcolbit) = LVD(krowbit,kcolbit) + A;
                        end
                    end
                end
            end
            LVext = log(LVN./LVD);
        end;
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %  Compute the decisions based on likelihoods          %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
        
        bh=sign(LHRCVD(1:4,1:4)+LVext(1:4,1:4)'+LHext(1:4,1:4));
        nerrors=nerrors+16-sum(sum(bh==b));
        if mod(ntrials,500)==0
            [ntrials nerrors];
            save product4
            semilogy(ebn0db,ber,'r')
            axis([-3 6 1e-5 1])
            grid on
        end
    end;
    ntrials;
    ber(SNR_index)=nerrors/ntrials/16;
end;
semilogy(ebn0db,ber,'r','LineWidth',2)
axis([-3 6 1e-5 1])
grid on
xlabel('E_b/N_0 (dB)','FontSize',16)
ylabel('BER','FontSize',16)
toc