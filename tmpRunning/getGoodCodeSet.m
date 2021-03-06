% get the set of codes with the minimum correlation
% the result is a cell
tic
clc,clear,close all;
% addpath('../function_set/coding/')

codeLen = 16;
codeNum = (2^codeLen)/2;
codebook = f_generateCodeBook(eye(codeLen))*2-1;
% codebook = codebook(1:codeNum, :);

resume = 1;
codeScore = zeros(codeNum, codeNum);
codeAutoCorr = zeros(codeNum);

for codeIndex = 1:codeNum
    code = codebook(codeIndex, :);
    codeAutoCorr(codeIndex) = sum(abs(conv(code, code)));
end

startNum = codeNum;
if resume == 1
    load codeScore
    startNum = codeIndex_row;
else
    delete codeScore.mat
end

for codeIndex_row = startNum:-1:1
    fprintf('%d out of %d\n', codeIndex_row, codeNum);
    for codeIndex_col = 1:codeIndex_row
        % for codeIndex_col = 1:codeNum
        code_row = codebook(codeIndex_row, :);
        code_col = codebook(codeIndex_col, :);
        codeScore(codeIndex_row, codeIndex_col) = sum(abs(conv(code_row, code_col))) + codeAutoCorr(codeIndex_row) + codeAutoCorr(codeIndex_col);
    end
    if mod(codeIndex_row, round(codeNum/100))
        save codeScore -v7
    end
end

% remove the effects of auto-correlation
for codeIndex_row = 1:codeNum
    codeScore(codeIndex_row, codeIndex_row) = codeScore(codeIndex_row, codeIndex_row) - codeLen;
end

% searching for good pairs of codes
% good pairs of codes should have low modified auto-correlation(removed the perfectly aligned effect), and low pairwise auto-correlation
% so, we only need to search the down-tri matrix of the codeScore. Note that, we don't need to search the diagnoal one
globalMin = codeLen * codeLen * 3;
goodPairIndex = [];
for codeIndex_row = 2:codeNum
    for codeIndex_col = 1:codeIndex_row - 1
        if codeScore(codeIndex_row, codeIndex_col) < globalMin
            globalMin = codeScore(codeIndex_row, codeIndex_col);
            goodPairIndex = [codeIndex_row, codeIndex_col];
        elseif codeScore(codeIndex_row, codeIndex_col) == globalMin
            goodPairIndex = [goodPairIndex;codeIndex_row, codeIndex_col];
        end
    end
end


% goodPairIndex
% globalMin
% code1 = codebook(goodPairIndex(1, 1), :)
% code2 = codebook(goodPairIndex(1, 2), :)
goodPairIndex_copy = goodPairIndex;

uniqCodeIndex = unique(reshape(goodPairIndex, 1, []));
setIndex = 1;
while length(uniqCodeIndex) && length(goodPairIndex) > 0
    goodSeqSet{setIndex} = goodPairIndex(1,:);
    startCode = goodPairIndex(1);
    % delete one line
    uniqCodeIndex(find(uniqCodeIndex == startCode)) = [];
    goodPairIndex(1,:) = [];
    
    pairLen = size(goodPairIndex, 1);
    indexSet = find(goodPairIndex == startCode);
    while length(indexSet) >0
        loc = (indexSet(1) > pairLen);
        row = mod(indexSet(1), pairLen);
        if row == 0
            row = row + pairLen;
        end
        startCode = goodPairIndex(row, ~loc + 1);
        
        uniqCodeIndex(find(uniqCodeIndex == startCode)) = [];
        goodPairIndex(row, :) = [];
        
        if ~ismember(startCode, goodSeqSet{setIndex})
            goodSeqSet{setIndex} = [goodSeqSet{setIndex}, startCode];
        end
        indexSet = find(goodPairIndex == startCode);
    end
    setIndex = setIndex + 1;
end
goodPairIndex = goodPairIndex_copy;

% goodSeqSet
codeSet = cell(length(goodSeqSet), 1);
for index = 1:length(goodSeqSet)
    codeSet{index} = codebook(goodSeqSet{index}, :);
    codebook(goodSeqSet{index}, :)
end
save codeSeq14 codeSet goodPairIndex
toc
