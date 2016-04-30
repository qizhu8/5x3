function seq = f_mseq(header, initstat, polarfying)
% % % % % % % % % % % % % % % 
% header = [1, 2, 5]; % rank = 4
% initstat = [1, 0, 0, 0];
% polarfying = 1;
% % % % % % % % % % % % % % % 
if nargin < 1 || nargin > 3
    error('parameter of f_mseq is ''header'', ''initstat'', and ''polarfying'', please check');
end

% if header(1) ~= 1
%     error('the first entry of ''header'' must be 1');
% end

if nargin < 3
    polarfying = 0;
end 

rank = max(header) -1;

if nargin < 2
    initstat = [1, zeros(1, rank-1)];
end

if length(initstat) ~= rank
    error('please check the rank of the initial state\n');
end
if max(initstat) > 1 || min(initstat) < 0
    error('the initial state should only contain 0s and 1s\n');
end

connection = header(2:end-1);
round = 2^rank - 1;
state_next = initstat;
seq_buf = zeros(1, round);
seqLen = 0;
for index_r = 1:round
    endbit = state_next(end);
    state_next(2:end) = state_next(1:end-1); % shift
    state_next(connection) = mod(state_next(connection) + endbit, 2);
    state_next(1) = endbit;

    seq_buf(index_r) = endbit;
    seqLen = seqLen + 1;
    if nnz(state_next - initstat) == 0
        break;
    end
end
seq = seq_buf(1:seqLen);

if polarfying
    seq = seq .*(-2) + 1;
end