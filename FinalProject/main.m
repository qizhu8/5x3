clc,clear,close all;
addpath('../function_set/Coding')
addpath('../function_set/Modulation')


% load parameters
parameter

% generate random 0,1 bits.
userBits = randi(2, userNum, infoBits_block * userCodeBlockLen)-1;

% form package
testInfoBits = randi(2, 1, 1000)*100;
preIndex = 0;
[package, endIndex] = f_formPackage(testInfoBits, packageFormator, preIndex, 1);


waveForm_send = f_userOutput(...
    package,...             % data
    spreadCodeSet(1,:),...  % spread code 1
    kron(ones(1, endIndex - preIndex), packageFormator.trainingSeq),... % training
    spreadCodeSet(2,:));    % spread code 2






[outputBits, packageIndex, address, storageInfo, CRC_bin] = f_splitPackage(package, packageFormator);
