% This is used for simulation only!
% Not a good way to write code like this
function [error, bitNum] = f_txrxch(SNR, draw)
% SNR = -30;
close all;
if nargin < 2
    draw = 1;
end
parameter

ebn0db = SNR / 2;
ebn0=10^(ebn0db / 10.0);
EN0=ebn0*infoBits_block/totalBits_block/spreadCodeLen;
% EN0=ebn0*infoBits_block/totalBits_block;
N0=1/EN0;
sigma=sqrt(N0/2);

load img
% generate random 0,1 bits.
% userBits = randi(2, userNum, infoBits_block * userCodeBlockLen)-1;
% userBits = ones(userNum, infoBits_block * userCodeBlockLen);
userBits = reshape(img, 1, []);

% receBits = randi(2, userNum, infoBits_block * userCodeBlockLen)-1;
receBits = ones(size(userBits));

% form package
% testInfoBits = randi(2, 1, 1000)*100;
preIndex = 0;
[package_all, ~, payload_all] = f_formPackage(userBits, packageFormator, preIndex, userAdd(1,:), 0);

showingBlock = uint8(ones(size(payload_all))*255);
totalPackageNum = size(package_all, 1);

img_rec = uint8(ones(size(img))*100);

lastRecIndex = 0;
for packageIndex = 1:totalPackageNum
    fprintf('SNR = %d %d %%\n', SNR, round(packageIndex / totalPackageNum*100));
    package = package_all(packageIndex, :);
    chCoded = f_TurboCoding(package, G);
    
    waveForm_send = f_userOutput(...
        chCoded,... %,...             % data
        spreadCodeSet(1,:),...  % spread code 1
...%         kron(ones(1, 1), packageFormator.trainingSeq),... % training
        kron(ones(1, 1), randi(2, 1, packageLen / infoBits_block * totalBits_block)*2-3),...
        spreadCodeSet(2,:));    % spread code 2
    
    % % % % % % % % % % % % %
    %        Channel        %
    % % % % % % % % % % % % %
    waveForm_rec = waveForm_send + sigma * rand(size(waveForm_send));
    
    % % % % % % % % % % % % %
    testCov = conv(waveForm_rec, fliplr(kron(packageFormator.trainingSeq, spreadCodeSet(2,:))));
    
    seqOut = f_chopper_decimator(waveForm_rec, testCov, packageFormator, spreadCodeSet(1,:), 5000);
    
    chDecoded = f_TurboDecoding(seqOut, G, sigma, E, codeBook, iteration);
    % chDecoded = f_TurboDecoding(chCoded, G, sigma, E, f_generateCodeBook(G), iteration);
    [outputBits, ~, ~, ~, ~] = f_splitPackage(chDecoded, packageFormator, forceChop);
    
    % save userbits
    infoBitStartLoc = (packageIndex-1)*packageCap + 1;
    receBits(infoBitStartLoc:infoBitStartLoc+length(outputBits)-1) = outputBits;
    
    showingBlock(packageIndex, :) = 0;
    showingBlock(packageIndex, outputBits ~= payload_all(packageIndex, :)) = 200;
    img_rec(lastRecIndex+1:lastRecIndex+length(outputBits)) = outputBits*255;
    lastRecIndex = lastRecIndex + length(outputBits);
    if draw ~= 0
        fig = figure(1);
        pause(0.01);
        hold on;
        %     imshow(showingBlock);
        imshow(img_rec)
        title(['SNR=', num2str(SNR)])
    end
end
if draw ~= 0
    print(fig, ['sigma_is_', num2str(sigma)],'-dpng');
end
error = nnz(receBits - userBits);
bitNum = prod(size(receBits));
% end