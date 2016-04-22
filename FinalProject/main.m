clc,clear,close all;
addpath('../function_set/Coding/')
addpath('../function_set/Modulation/')
addpath('../function_set/Package/')

% load parameters
parameter

% generate random 0,1 bits.
userBits = randi(2, userNum, infoBits_block * userCodeBlockLen)-1;

% form package
% testInfoBits = randi(2, 1, 1000)*100;
preIndex = 0;
[package, endIndex] = f_formPackage(userBits, packageFormator, preIndex, 1);


chCoded = f_TurboCoding(package, G);

waveForm_send = f_userOutput(...
    chCoded,... %,...             % data
    spreadCodeSet(1,:),...  % spread code 1
    kron(ones(1, endIndex - preIndex), packageFormator.trainingSeq),... % training
    spreadCodeSet(2,:));    % spread code 2


% % % % % % % % % % % % % 
waveForm_rec = waveForm_send + sigma * rand(size(waveForm_send));


% % % % % % % % % % % % % 
testCov = conv(waveForm_rec, fliplr(kron(packageFormator.trainingSeq, spreadCodeSet(2,:))));
% plot(testCov)

seqOut = chopper_decimator(waveForm_rec, testCov, packageFormator, spreadCodeSet(1,:), 5000);


chDecoded = f_TurboDecoding(seqOut, G, sigma, E, f_generateCodeBook(G), iteration);
% chDecoded = f_TurboDecoding(chCoded, G, sigma, E, f_generateCodeBook(G), iteration);
[outputBits, packageIndex, address, storageInfo, CRC_bin] = f_splitPackage(chDecoded, packageFormator);
nnz(outputBits - userBits)