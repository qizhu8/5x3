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

package = -ones(size(package));
waveForm_send = f_userOutput(...
    package,...             % data
    spreadCodeSet(1,:),...  % spread code 1
    kron(ones(1, endIndex - preIndex), packageFormator.trainingSeq),... % training
    spreadCodeSet(2,:));    % spread code 2


% % % % % % % % % % % % % 
testCov = conv(waveForm_send, fliplr(kron(packageFormator.trainingSeq, spreadCodeSet(2,:))));
plot(testCov)




[outputBits, packageIndex, address, storageInfo, CRC_bin] = f_splitPackage(package, packageFormator);
