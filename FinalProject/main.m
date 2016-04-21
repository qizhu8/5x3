clc,clear,close all;



% load parameters
parameter

% generate random 0,1 bits.
userBits = randi(2, userNum, infoBits_block * userCodeBlockLen)-1;

userOutput = 
