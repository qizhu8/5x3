clc,clear,close all;
prefix = './resultMAT/';
matfile = cell(1, 7);
matfile{1}.matname = 'spread14';
matfile{1}.name = 'BS 14';
matfile{1}.curveColor = [0, 0, 0];
matfile{1}.pointType = '-x';

matfile{2}.matname = 'spread15';
matfile{2}.name = 'BS 15';
matfile{2}.curveColor = [1, 0, 0];
matfile{2}.pointType = '-x';

matfile{3}.matname = 'spread16_1';
matfile{3}.name = 'BS 16-1';
matfile{3}.curveColor = [0, 1, 0];
matfile{3}.pointType = '-x';

matfile{4}.matname = 'spread16_2';
matfile{4}.name = 'BS 16-1';
matfile{4}.curveColor = [0, 0, 1];
matfile{4}.pointType = '-x';

matfile{5}.matname = 'gold15_1';
matfile{5}.name = 'goldseq 15-1';
matfile{5}.curveColor = [0.7, 0.4, 0];
matfile{5}.pointType = '-o';

matfile{6}.matname = 'gold15_2';
matfile{6}.name = 'goldseq 15-2';
matfile{6}.curveColor = [1, 0, 1];
matfile{6}.pointType = '-o';

matfile{7}.matname = 'm_seq15';
matfile{7}.name = 'M-seq 15';
matfile{7}.curveColor = [0, 1, 1];
matfile{7}.pointType = '-d';

hold on
legendStr = '';
for fileIndex = 1:length(matfile)
    matname = [prefix, matfile{fileIndex}.matname, '.mat'];
    load(matname)
    legendStr = [legendStr, ',', matfile{fileIndex}.name];
    removedIndex = (error == 0);
    if length(removedIndex) > 1
        removedIndex = removedIndex(2:end);
    end
    error(removedIndex) = [];
    baseNum(removedIndex) = [];
    SNR_range(removedIndex) = [];
    plot(SNR_range, 10*log10(error./baseNum), matfile{fileIndex}.pointType, 'color', matfile{fileIndex}.curveColor);
    clear error baseNum
end
h_legend = legend(matfile{1}.name, matfile{2}.name, matfile{3}.name, matfile{4}.name, matfile{5}.name, matfile{6}.name, matfile{7}.name, 'location', 'NorthEastOutside');
set(h_legend,'FontSize',14);
grid on
print('finalCurve','-dpng');