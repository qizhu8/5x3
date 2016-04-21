function decodedSignal = f_TurboDecoding(signal_r_s, G, sigma, E, cb, iter)
signalBlock = reshape(signal_r_s, 40, [])';
blockLen = length(signal_r_s) / 40;
decodedSignal = zeros(1, blockLen * 16);
for blockIndex = 1:blockLen
    decoded = f_TurboDecoding_block(signalBlock(blockIndex, :), G, sigma, E, cb, iter);
    decodedSignal((blockIndex-1)*16+1:blockIndex*16) = decoded;
end
