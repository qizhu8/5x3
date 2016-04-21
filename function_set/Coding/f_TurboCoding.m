function codedSignal = f_TurboCoding(signal, G)
signalBlock = reshape(signal, 16, [])';
blockLen = length(signal) / 16;
codedSignal = zeros(1, blockLen * 40);
for blockIndex = 1:blockLen
    codedSignal((blockIndex - 1)*40+1: blockIndex*40) = f_TurboCoding_block(signalBlock(blockIndex, :), G);
end