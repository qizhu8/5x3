%=======================================================%
%                                                       %
%  This program simulates the performance of a product  %
%  of a (7,4) Hamming codes.  The overall code is a     %
%  (40,16) product code.                                %
%                                                       %
%=======================================================%
clc,clear,close all
addpath('../function_set/coding/')
tic
parameter % load some pre-ser parameters

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
    while nerrors < threshold,
        ntrials=ntrials+1;
        b=sign(rand(4,4)-0.5);
        ph=mod(-0.5*(b-1)*G,2);
        pv=mod(-0.5*(b'-1)*G,2);
        LVext=zeros(4,4);            %Initialize the likelihoods with the apriori information (if any)
        %=========================================================%
        %  Generate as 4 by 10 arrary.  First 4 cols are info,
        %  next three are horizontal parity checks and last
        %  three are vertical parity checks.
        %=========================================================%
        c=[b 1-2*ph(:,5:7) 1-2*pv(:,5:7)];      % This is the transmitted codeword (4 x 10)
        attenuation = raylrnd(sigma2, size(c));
        r=attenuation .* sqrt(E)*c+sigma*randn(4,10);          % This is the received vector (4 x 10)
        %         LHRCVD=2*r(:,1:7)*sqrt(E)/sigma^2;                   % This is the extrinisic H information
        %         LVRCVD=2*[r(:,1:4)' r(:,8:10)]*sqrt(E)/sigma^2;      % This is the extrinisic V information
        
        tmpr = [r(:,1:4)' r(:,8:10)];
        for row = 1:4
            for col = 1:7
                LHRCVD(row, col) = f_likelihood_soft(r(row, col), N0, sigma2, E);
                LVRCVD(row, col) = f_likelihood_soft(tmpr(row, col), N0, sigma2, E);
            end
        end
        
        
        %=========================================================%
        %  Compute The likelihoods based on horizontal            %
        %  parity checks (including extrinisic and aprior)        %
        %=========================================================%
        
        
        for j=1:niterations
            Ltemp=[LHRCVD(1:4,1:4)+LVext(1:4,1:4)' LHRCVD(:,5:7)];   %This is the likelihood combining the
            % extrinsic and apriori information
            LHN=zeros(4,4);
            LHD=zeros(4,4);
            for kcolbit=1:4
                for krowbit=1:4
                    for m=1:16
                        A=exp((1-cb(m,:))*Ltemp(krowbit,:)');            % Determine the likelihood for codeword m
                        if cb(m,kcolbit)==0 LHN(krowbit,kcolbit)=LHN(krowbit,kcolbit)+A;
                        else LHD(krowbit,kcolbit)=LHD(krowbit,kcolbit)+A; end
                    end	% End loop for codewords
                end       % End loop for row bits
            end          % End loop for column bits
            
            LH=log(LHN./LHD);
            LHext= LH-LVext'-LHRCVD(1:4,1:4);    % Subtract off the extrinisic and apriori likelihoods
            
            
            %====================================================%
            %  Compute the likelihoods based on vertical         %
            %  parity checks                                     %
            %====================================================%
            Ltemp=[LVRCVD(1:4,1:4)+LHext(1:4,1:4)' LVRCVD(:,5:7)];
            LVN=zeros(4,4);
            LVD=zeros(4,4);
            for kcolbit=1:4
                for krowbit=1:4
                    for m=1:16        % Look at each of the 16 codewords for each information bit
                        A=exp((1-cb(m,:))*Ltemp(krowbit,:)');
                        if cb(m,kcolbit)==0
                            LVN(krowbit,kcolbit)=LVN(krowbit,kcolbit)+A;
                        else
                            LVD(krowbit,kcolbit)=LVD(krowbit,kcolbit)+A;
                        end
                    end
                end
            end
            LV=log(LVN./LVD);
            LVext= LV-LHext'-LVRCVD(1:4,1:4);
            
            
        end;   % End of loop for number of iteration
        %=========================================================%
        %                                                    %
        %  Compute the decisions based on likelihoods        %
        %                                                    %
        %=========================================================%
        
        bh=sign(LHRCVD(1:4,1:4)+LVext(1:4,1:4)'+LHext(1:4,1:4));
        nerrors=nerrors+16-sum(sum(bh==b));
        if mod(ntrials,2000)==0    %save results periodically in case of crashes
            [ntrials nerrors]
            %    save product4
            semilogy(ebn0db,ber,'r')
            axis([-3 6 1e-5 1])
            xlabel('E_b/N_0 (dB)','FontSize',16)
            ylabel('Bit Error Probability','FontSize',16)
            grid on
        end
    end;                         % End of loop for the number of trials
    ntrials
    ber(k)=nerrors/ntrials/16
    save product_ray_no_side
    semilogy(ebn0db,ber,'r')
    axis([-3 6 1e-6 1])
    grid on
    pause(.1)
end;                         % End of loop for E_b/N_0
semilogy(ebn0db,ber,'r','LineWidth',2)
grid on
