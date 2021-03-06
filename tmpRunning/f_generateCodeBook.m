function codeBook = f_generateCodeBook(GeneratorMatrix)
codeLen = size(GeneratorMatrix, 1);
infoBitsMatrix = dec2bin(0:2^codeLen - 1, codeLen);
codeBook = mod(infoBitsMatrix * GeneratorMatrix, 2);