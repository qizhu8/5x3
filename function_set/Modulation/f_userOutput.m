function outSeq = f_userOutput(infoBits, spreadCode_info, trainingBits, spreadCode_train)
if nargin == 2
    outSeq = kron(infoBits, spreadCode_info);
elseif nargin == 4
    outSeq = kron(infoBits, spreadCode_info) + kron(trainingBits, spreadCode_train);
else
    error('please check the inputs')
end