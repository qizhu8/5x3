function [package, lastIndex, infoBits] = f_formPackage(infoBits, packageFormator, index, address, toSerial)
if nargin < 2
    error('you must input the infobits and packageFormator')
end
if nargin < 3
    index = 0;
end
if nargin < 4
    address = 0;
end
if nargin < 5
    toSerial = 1;
end

if length(address) == 1
    address = dec2bin(address, packageFormator.addLen) - '0';
end
% package format
% ----------------------------------------------------
% |  index | address | storage | CRC |   info bits   |
% ----------------------------------------------------
% |       H   E   A   D   E   R      |   info bits   |
% ----------------------------------------------------

% get package number
numberOfPackage = ceil(length(infoBits) / packageFormator.packageCap);
numberOfAddedZeros = numberOfPackage * packageFormator.packageCap - length(infoBits);
infoBits = reshape([infoBits, zeros(1, numberOfAddedZeros)], packageFormator.packageCap, numberOfPackage)';
% allocate package space
package = zeros(numberOfPackage, packageFormator.packageLen);

% form index
lastIndex = index+numberOfPackage;
packageIndex = mod(index+1:lastIndex, 2^packageFormator.indexLen);
packageIndex_bin = dec2bin(packageIndex, packageFormator.indexLen) - '0';

% form storage info
storageInfo = zeros(numberOfPackage, packageFormator.capLen);
storageInfo(numberOfPackage, :) = dec2bin(mod(packageFormator.packageCap - numberOfAddedZeros, packageFormator.packageCap), packageFormator.capLen) - '0';

% form address
addressInfo = ones(numberOfPackage, 1) * address - '0';

% form the whole package
preLen = 0;
package(:, preLen+1:preLen + packageFormator.indexLen) = packageIndex_bin;

preLen = preLen + packageFormator.indexLen;
package(:, preLen+1:preLen + packageFormator.addLen) = addressInfo;

preLen = preLen + packageFormator.addLen;
package(:, preLen+1:preLen + packageFormator.capLen) = storageInfo;

preLen = preLen + packageFormator.capLen;
package(:, preLen+1:preLen + packageFormator.CRCLen) = zeros(numberOfPackage, packageFormator.CRCLen);

% preLen = preLen + packageFormator.capLen;
% package(:, preLen+1:preLen + packageFormator.CRCLen) = zeros(numberOfPackage, packageFormator.CRCLen);

preLen = preLen + packageFormator.CRCLen;
package(:, preLen+1:end) = infoBits;

% now we can calculate the crc
% reshape
if toSerial ~= 0
    package = reshape(package', 1, []);
end