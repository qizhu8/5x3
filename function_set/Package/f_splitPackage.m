function [outputBits, packageIndex, address, storageInfo, CRC_bin] = f_splitPackage(packageInfo, packageFormator, forceChop)

% package format
% ----------------------------------------------------
% |  index | address | storage | CRC |   info bits   |
% ----------------------------------------------------
% |       H   E   A   D   E   R      |   info bits   |
% ----------------------------------------------------

% packageFormator.indexLen = indexLen;
% packageFormator.addLen = addLen;
% packageFormator.capLen = capLen;
% packageFormator.CRCLen = CRCLen;
% packageFormator.packageCap = packageCap;
% packageFormator.headerLen = headerLen;
% packageFormator.packageLen = packageLen;
% packageFormator.trainingSeq = trainingSeq;

numberOfPackage = length(packageInfo)/packageFormator.packageLen;
packageInfo = reshape(packageInfo, packageFormator.packageLen, numberOfPackage)';
preLen = 0;
packageIndex = bin2dec(num2str(packageInfo(:, preLen+1:preLen + packageFormator.indexLen)));

preLen = preLen + packageFormator.indexLen;
address = bin2dec(num2str(packageInfo(:, preLen+1:preLen + packageFormator.addLen)));

preLen = preLen + packageFormator.addLen;
storageInfo = bin2dec(num2str(packageInfo(:, preLen+1:preLen + packageFormator.capLen)));
storageInfo(storageInfo == 0) = packageFormator.packageCap;

preLen = preLen + packageFormator.capLen;
CRC_bin = packageInfo(:, preLen+1:preLen + packageFormator.CRCLen);

preLen = preLen + packageFormator.CRCLen;
infoBits = packageInfo(:, preLen+1:end);

outputBits = zeros(1, sum(storageInfo));
preLen = 0;
if forceChop == 1
    outputBits = reshape(infoBits', 1, []);
else
    for index = 1:numberOfPackage
        %     [preLen + 1, preLen+storageInfo(index)]
        outputBits(preLen + 1:preLen+storageInfo(index)) = infoBits(index,1:storageInfo(index));
        preLen = preLen+storageInfo(index);
    end
end
