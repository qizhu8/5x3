clc,clear,close all;
addpath('../function_set/coding/')
addpath('../function_set/Package/')
addpath('../function_set/Modulation/')
userNum = 2;
userCodeBlockLen = 1;
spreadCodeLen = 8;
threshold = spreadCodeLen * 0.8;
G=[
    1, 0, 0, 0, 1, 0, 1
    0, 1, 0, 0, 1, 1, 1,
    0, 0, 1, 0, 1, 1, 0,
    0, 0, 0, 1, 0, 1, 1
    ];
% spreadCodeLib = f_getGoodCorrCodeSet(spreadCodeLen);
% spreadCodeSet = spreadCodeLib{1};
% save spreadCodeSet spreadCodeSet
load spreadCodeSet
% spreadCodeSet = [
%     1,1,1,1,-1,1,1,-1
%     -1,1,-1,1,-1,-1,-1,-1
%     ];



codeLen = size(G, 1) * size(G, 1) * userCodeBlockLen;
sourceSeq = randi(2, 1, codeLen)*2 - 3;
sourceSeq = reshape(sourceSeq, 1, []);
coded = f_TurboCoding(sourceSeq, G);

userOutput = zeros(userNum, length(coded)*spreadCodeLen);
for userIndex = 1:userNum
    userOutput(userIndex, :) = f_userOutput(coded, spreadCodeSet(userIndex, :));
end

RF_signal_send = sum(userOutput, 1);
RF_signal_rec = RF_signal_send;


userCor = zeros(userNum, length(RF_signal_rec) + spreadCodeLen - 1);
userDecor = zeros(userNum, length(RF_signal_rec)/spreadCodeLen);
% hold on
for userIndex = 1:userNum
    userCor(userIndex, :) = conv(RF_signal_rec, fliplr(spreadCodeSet(userIndex, :)));
%     plot(userCor(userIndex, :))
    bitIndex = 1;
    for chipIndex = 1:length(userCor(userIndex, :))
        if userCor(userIndex, chipIndex) > threshold
            userDecor(userIndex, bitIndex) = 1;
            bitIndex = bitIndex + 1;
        elseif userCor(userIndex, chipIndex) < -threshold
            userDecor(userIndex, bitIndex) = -1;
            bitIndex = bitIndex + 1;
        end
        if bitIndex > 40
            chipIndex
            break;
        end
    end
end

% decoding
userDecoded = zeros(userNum, floor(length(RF_signal_rec)/spreadCodeLen/40)*16);
for userIndex = 1:userNum
    userDecoded(userIndex, :) = f_TurboDecoding(userDecor(userIndex, :), G, 1, 1, f_generateCodeBook(G), 1);
end
% decoded = f_TurboDecoding(coded, G, 1, 1, f_generateCodeBook(G), 1);
nnz(ones(userNum, 1) * sourceSeq - userDecoded)