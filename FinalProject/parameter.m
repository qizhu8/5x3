% parameter
userNum = 2;
userCodeBlockLen = 1;
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
