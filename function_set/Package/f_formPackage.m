function [package, lastIndex] = f_formPackage(infoBits, packageFormator, index, address)
if nargin < 2
    error('you must input the infobits and packageFormator')
elseif nargin < 3
    index = 0;
    address = 0;
elseif nargin < 4
    address = 0;
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
packageIndex = index+1:lastIndex;
packageIndex_bin = dec2bin(packageIndex, packageFormator.indexLen) - '0';

% form storage info
storageInfo = zeros(numberOfPackage, packageFormator.capLen);
storageInfo(numberOfPackage, :) = dec2bin(mod(packageFormator.packageCap - numberOfAddedZeros, packageFormator.packageCap), packageFormator.capLen) - '0';

% form address
addressInfo = ones(numberOfPackage, 1) * address;

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
package = reshape(package', 1, []);