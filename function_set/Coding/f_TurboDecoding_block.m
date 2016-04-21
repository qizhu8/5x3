function decodedSignal = f_TurboDecoding_block(signal_r_s, G, sigma, E, cb, iter)
% % % % % % % % % % % % % % % % % % % %
% clc,clear,close all;
% signal_r = [
%     1    -1    -1    -1     1    -1     1     1    -1     1
%     -1     1     1     1    -1     1    -1     1    -1    -1
%     -1    -1    -1     1    -1     1     1     1     1     1
%     -1     1    -1     1     1    -1    -1    -1     1    -1
%     ];
% G=[
%     1, 0, 0, 0, 1, 0, 1
%     0, 1, 0, 0, 1, 1, 1,
%     0, 0, 1, 0, 1, 1, 0,
%     0, 0, 0, 1, 0, 1, 1
%     ];
% signal =[
%     1    -1    -1    -1
%     -1     1     1     1
%     -1    -1    -1     1
%     -1     1    -1     1
%     ];
% E = 1;
% sigma = 1;
% iter = 2;
% cb = f_generateCodeBook(G);
% % % % % % % % % % % % % % % % % % % %
[sign_len, codedSign_len] = size(G);
signal_r_s = reshape(signal_r_s, sign_len, codedSign_len*2-sign_len);

LHRCVD=2*signal_r_s(:, 1:codedSign_len)*sqrt(E)/sigma^2;                   % This is the extrinisic H information
LVRCVD=2*[signal_r_s(:,1:sign_len)' signal_r_s(:,codedSign_len+1:end)]*sqrt(E)/sigma^2;      % This is the extrinisic V information
LVext=zeros(sign_len,sign_len);            %Initialize the likelihoods with the apriori information (if any)

for j=1:iter
    Ltemp=[LHRCVD(1:sign_len,1:sign_len)+LVext(1:sign_len,1:sign_len)' LHRCVD(:,sign_len+1:codedSign_len)];   %This is the likelihood combining the
    % extrinsic and apriori information
    LHN=zeros(sign_len,sign_len);
    LHD=zeros(sign_len,sign_len);
    for kcolbit=1:sign_len
        for krowbit=1:sign_len
            for m=1:(2^sign_len)
                A=exp((1-cb(m,:))*Ltemp(krowbit,:)');            % Determine the likelihood for codeword m
                if cb(m,kcolbit)==0 LHN(krowbit,kcolbit)=LHN(krowbit,kcolbit)+A;
                else LHD(krowbit,kcolbit)=LHD(krowbit,kcolbit)+A; end
            end	% End loop for codewords
        end       % End loop for row bits
    end          % End loop for column bits
    
    LH=log(LHN./LHD);
    LHext= LH-LVext'-LHRCVD(1:sign_len,1:sign_len);    % Subtract off the extrinisic and apriori likelihoods
    
    
    %====================================================%
    %  Compute the likelihoods based on vertical         %
    %  parity checks                                     %
    %====================================================%
    Ltemp=[LVRCVD(1:sign_len,1:sign_len)+LHext(1:sign_len,1:sign_len)' LVRCVD(:,sign_len+1:codedSign_len)];
    LVN=zeros(sign_len,sign_len);
    LVD=zeros(sign_len,sign_len);
    for kcolbit=1:sign_len
        for krowbit=1:sign_len
            for m=1:(2^sign_len)        % Look at each of the 16 codewords for each information bit
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
    LVext= LV-LHext'-LVRCVD(1:sign_len,1:sign_len);
    
    
end;   % End of loop for number of iteration
%=========================================================%
%                                                    %
%  Compute the decisions based on likelihoods        %
%                                                    %
%=========================================================%

signal_dec = sign(LHRCVD(1:sign_len,1:sign_len)+LVext(1:sign_len,1:sign_len)'+LHext(1:sign_len,1:sign_len));
signal_dec = reshape(signal_dec, 1, []);
decodedSignal = signal_dec;


% [sign_len, codedSign_len] = size(G);
% blockCodedLen = (codedSign_len*2 - sign_len)*sign_len;
% decodedCodeLen = sign_len * sign_len;
% codeBlock = reshape(signal_r_s, blockCodedLen, []);
% 
% decodedSignal = zeros(1, length(signal_r_s)/ blockCodedLen*decodedCodeLen);
% 
% for codeIndex = 1:length(signal_r_s)/ blockCodedLen
%     signal_r = codeBlock(:, codeIndex);
% signal_r = reshape(signal_r, sign_len, codedSign_len*2-sign_len);
% 
% LHRCVD=2*signal_r(:, 1:codedSign_len)*sqrt(E)/sigma^2;                   % This is the extrinisic H information
% LVRCVD=2*[signal_r(:,1:sign_len)' signal_r(:,codedSign_len+1:end)]*sqrt(E)/sigma^2;      % This is the extrinisic V information
% LVext=zeros(sign_len,sign_len);            %Initialize the likelihoods with the apriori information (if any)
% 
% for j=1:iter
%     Ltemp=[LHRCVD(1:sign_len,1:sign_len)+LVext(1:sign_len,1:sign_len)' LHRCVD(:,sign_len+1:codedSign_len)];   %This is the likelihood combining the
%     % extrinsic and apriori information
%     LHN=zeros(sign_len,sign_len);
%     LHD=zeros(sign_len,sign_len);
%     for kcolbit=1:sign_len
%         for krowbit=1:sign_len
%             for m=1:(2^sign_len)
%                 A=exp((1-cb(m,:))*Ltemp(krowbit,:)');            % Determine the likelihood for codeword m
%                 if cb(m,kcolbit)==0 LHN(krowbit,kcolbit)=LHN(krowbit,kcolbit)+A;
%                 else LHD(krowbit,kcolbit)=LHD(krowbit,kcolbit)+A; end
%             end	% End loop for codewords
%         end       % End loop for row bits
%     end          % End loop for column bits
%     
%     LH=log(LHN./LHD);
%     LHext= LH-LVext'-LHRCVD(1:sign_len,1:sign_len);    % Subtract off the extrinisic and apriori likelihoods
%     
%     
%     %====================================================%
%     %  Compute the likelihoods based on vertical         %
%     %  parity checks                                     %
%     %====================================================%
%     Ltemp=[LVRCVD(1:sign_len,1:sign_len)+LHext(1:sign_len,1:sign_len)' LVRCVD(:,sign_len+1:codedSign_len)];
%     LVN=zeros(sign_len,sign_len);
%     LVD=zeros(sign_len,sign_len);
%     for kcolbit=1:sign_len
%         for krowbit=1:sign_len
%             for m=1:(2^sign_len)        % Look at each of the 16 codewords for each information bit
%                 A=exp((1-cb(m,:))*Ltemp(krowbit,:)');
%                 if cb(m,kcolbit)==0
%                     LVN(krowbit,kcolbit)=LVN(krowbit,kcolbit)+A;
%                 else
%                     LVD(krowbit,kcolbit)=LVD(krowbit,kcolbit)+A;
%                 end
%             end
%         end
%     end
%     LV=log(LVN./LVD);
%     LVext= LV-LHext'-LVRCVD(1:sign_len,1:sign_len);
%     
%     
% end;   % End of loop for number of iteration
% %=========================================================%
% %                                                    %
% %  Compute the decisions based on likelihoods        %
% %                                                    %
% %=========================================================%
% 
% signal_dec = sign(LHRCVD(1:sign_len,1:sign_len)+LVext(1:sign_len,1:sign_len)'+LHext(1:sign_len,1:sign_len));
% signal_dec = reshape(signal_dec, 1, [])
% decodedSignal((codeIndex - 1)*decodedCodeLen+1:codeIndex*decodedCodeLen) = signal_dec;
% end