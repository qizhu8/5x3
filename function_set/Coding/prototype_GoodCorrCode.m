% get the set of codes with the minimum correlation
% the result is a cell

% clc,clear,close all;
% addpath('../function_set/coding/')

codeLen = 4;
codeNum = 2^codeLen;
codebook = f_generateCodeBook(eye(codeLen))*2-1;

codeScore = zeros(codeNum, codeNum);
codeAutoCorr = zeros(codeNum);

for codeIndex = 1:codeNum
    code = codebook(codeIndex, :);
    codeAutoCorr(codeIndex) = sum(abs(conv(code, code)));
end

for codeIndex_row = codeNum:-1:1
    fprintf('%d out of %d\n', codeIndex_row, codeNum);
    for codeIndex_col = 1:codeIndex_row
        % for codeIndex_col = 1:codeNum
        code_row = codebook(codeIndex_row, :);
        code_col = codebook(codeIndex_col, :);
        codeScore(codeIndex_row, codeIndex_col) = sum(abs(conv(code_row, code_col))) + codeAutoCorr(codeIndex_row) + codeAutoCorr(codeIndex_col);
    end
end

% remove the effects of auto-correlation
codeScore = codeScore - codeLen*eye(codeNum);

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
while ~isempty(uniqCodeIndex)
    goodSeqSet{setIndex} = goodPairIndex(1,:);
    startCode = goodPairIndex(1);
    % delete one line
    uniqCodeIndex(uniqCodeIndex == startCode) = [];
    uniqCodeIndex(uniqCodeIndex == (codeNum - startCode + 1)) = []; % the conjugate code
    goodPairIndex(1,:) = [];
    
    pairLen = size(goodPairIndex, 1);
    indexSet = find(goodPairIndex == startCode);
    while ~isempty(indexSet)
        loc = (indexSet(1) > pairLen);
        row = mod(indexSet(1), pairLen);
        if row == 0
            row = row + pairLen;
        end
        startCode = goodPairIndex(row, ~loc + 1);
        
        uniqCodeIndex(uniqCodeIndex == startCode) = [];
        uniqCodeIndex(uniqCodeIndex == (codeNum - startCode + 1)) = []; % the conjucate code 
        goodPairIndex(row, :) = [];
        
        if ~ismember(startCode, goodSeqSet{setIndex})
            goodSeqSet{setIndex} = [goodSeqSet{setIndex}, startCode];
        end
        indexSet = find(goodPairIndex == startCode);
    end
    setIndex = setIndex + 1;
end
goodPairIndex = goodPairIndex_copy;

% remove the conjugate code  e.g. 111 <->-1 -1 -1   1 -1 1 <-> -1 1 -1
% for index = 1:length(goodSeqSet)
%     for 
%     end
% end


% goodSeqSet
goodSeqSet{1}
codeSet = cell(length(goodSeqSet), 1);
for index = 1:length(goodSeqSet)
    codeSet{index} = codebook(goodSeqSet{index}, :);
end
