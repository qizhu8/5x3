% parameter
userNum = 1;
userCodeBlockLen = 80;
spreadCodeLen = 8;
G=[
    1, 0, 0, 0, 1, 0, 1
    0, 1, 0, 0, 1, 1, 1
    0, 0, 1, 0, 1, 1, 0
    0, 0, 0, 1, 0, 1, 1
    ];
[G_row, G_col] = size(G);
infoBits_block = G_row * G_row;
totalBits_block = G_row * (2 * G_col - G_row);
if spreadCodeLen > 14
    error('spreading code too long!!!')
elseif spreadCodeLen ~= 8
    spreadCodeLib = f_getGoodCorrCodeSet(spreadCodeLen);
    spreadCodeSet = spreadCodeLib{1};
else
    load spreadCodeSet
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

trainingSeq = randi(2, 1, packageLen)*2-3; % a training seq of the same length of the package

packageFormator.indexLen = indexLen;
packageFormator.addLen = addLen;
packageFormator.capLen = capLen;
packageFormator.CRCLen = CRCLen;
packageFormator.packageCap = packageCap;
packageFormator.headerLen = headerLen;
packageFormator.packageLen = packageLen;
packageFormator.trainingSeq = trainingSeq;

% address
userAdd = dec2bin(1:userNum, packageFormator.addLen);