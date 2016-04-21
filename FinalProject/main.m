clc,clear,close all;
addpath('../function_set/Coding')
addpath('../function_set/Modulation')


% load parameters
parameter

% generate random 0,1 bits.
userBits = randi(2, userNum, infoBits_block * userCodeBlockLen)-1;

% form package
testInfoBits = randi(2, 1, 1000)*100;
[package, index] = f_formPackage(testInfoBits, packageFormator, 0, 1);
[outputBits, packageIndex, address, storageInfo, CRC_bin] = f_splitPackage(package, packageFormator);

nnz(outputBits - testInfoBits)