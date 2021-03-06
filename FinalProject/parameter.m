% parameter
addpath('../function_set/Coding/')
addpath('../function_set/Modulation/')
addpath('../function_set/Package/')
addpath('../function_set/Source/')

userNum = 1;
userCodeBlockLen = 16 * 100;
spreadCodeLen = 15;
G=[
    1, 0, 0, 0, 1, 0, 1
    0, 1, 0, 0, 1, 1, 1
    0, 0, 1, 0, 1, 1, 0
    0, 0, 0, 1, 0, 1, 1
    ];
iteration = 2;
sigma = 10;
E = 1;
codeBook = f_generateCodeBook(G);
forceChop = 1;

[G_row, G_col] = size(G);
infoBits_block = G_row * G_row;
totalBits_block = G_row * (2 * G_col - G_row);
if spreadCodeLen > 16
    error('spreading code too long!!!')
elseif spreadCodeLen == 8
    load spreadCodeSet
elseif spreadCodeLen <= 13
    spreadCodeLib = f_getGoodCorrCodeSet(spreadCodeLen);
    spreadCodeSet = spreadCodeLib{1};
elseif spreadCodeLen == 14
    spreadCodeSet = [
        -1, 1, 1, -1, -1, -1, -1, -1, 1, 1, -1, 1, -1, 1
        -1, -1, 1, 1, -1, 1, -1, 1, 1, -1, -1, -1, -1, -1
        ];
elseif spreadCodeLen == 15
    % Gold
    seq1 = f_mseq([1, 2, 5], [1, 0, 0, 0], 1);
    seq2 = f_mseq([3, 4, 5], [1, 0, 0, 0], 1);
    seq1(seq1 == -1) = 0;
    seq2(seq2 == -1) = 0;
    chunkIndex = 7;
    spreadCodeSet = [
        seq1 + [seq2(chunkIndex:15), seq2(1:chunkIndex-1)]
        seq1 + [seq2(4:15), seq2(1:4-1)]
        ];
    spreadCodeSet = mod(spreadCodeSet, 2)*2-1;
    spreadCodeSet = spreadCodeSet * -1;
    sum(spreadCodeSet')
    % M-seq
    %     spreadCodeSet = [
    %         f_mseq([1, 2, 5], [1, 0, 0, 0], 1)
    %         f_mseq([3, 4, 5], [1, 0, 0, 0], 1)
    %         ];
    % searched
    %     spreadCodeSet = [
    %         -1, 1, -1, -1, 1, -1, -1, -1, 1, -1, -1, -1, 1, 1, 1
    %         -1, -1, -1, 1, 1, 1, -1, 1, 1, 1, -1, 1, 1, -1, 1
    %         ];
elseif spreadCodeLen == 16
    % searched
    spreadCodeSet = [
        -1, -1, 1, -1, 1, 1, -1, 1, -1, -1, -1, 1, -1, -1, -1, 1
        -1, 1, 1, 1, -1, 1, 1, 1, -1, 1, -1, -1, 1, -1, 1, 1
        ];
end

% package
% package format
% ----------------------------------------------------
% |  index | address | storage | CRC |   info bits   |
% ----------------------------------------------------
% |       H   E   A   D   E   R      |   info bits   |
% ----------------------------------------------------

indexLen = 8;   % store the index info for package
addLen = 16;    % address
capLen = 8;    % store how many bits are in this package
CRCLen = 16;    % number for crc check

packageCap = 2^capLen; % length of info bits in this package


headerLen = indexLen + addLen + capLen + CRCLen;
packageLen = headerLen + packageCap;

trainingSeq = randi(2, 1, packageLen / infoBits_block * totalBits_block)*2-3; % a training seq of the same length of the package

packageFormator.indexLen = indexLen;
packageFormator.addLen = addLen;
packageFormator.capLen = capLen;
packageFormator.CRCLen = CRCLen;
packageFormator.packageCap = packageCap;
packageFormator.headerLen = headerLen;
packageFormator.packageLen = packageLen;
packageFormator.trainingSeq = trainingSeq;
packageFormator.trainingLen = packageLen / infoBits_block * totalBits_block;
packageFormator.spreadCodeLen = spreadCodeLen;
% address
userAdd = dec2bin(1:userNum, packageFormator.addLen);