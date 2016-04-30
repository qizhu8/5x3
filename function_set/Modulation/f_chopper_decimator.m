function seqout = f_chopper_decimator( seqin, control, formatter, spreadCode, training_th)
%   chopper_decimator Summary of this function goes here
%   Detailed explanation goes here

packageLen = formatter.trainingLen;
spreadCodeLen = formatter.spreadCodeLen;
kronLen = length(spreadCode) * packageLen;

pos = 1;
% peakIndex = find(control >= training_th);
% if length(peakIndex) == 0
    peakIndex = packageLen * spreadCodeLen;
% end
for i = peakIndex
%     i
    packet = seqin(i-kronLen+1 : i);
    conv_result = conv(packet, fliplr(spreadCode));
    seqin_conv(1, pos : pos + kronLen - 1) = conv_result(1, 1 : kronLen);
    pos = pos + kronLen;
end
% plot(seqin_conv, 'bx-')
seqout = seqin_conv(fliplr(peakIndex(end):-spreadCodeLen:1));
end