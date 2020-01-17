
function [h, varargout] = bonferroni_holm(A, B, alpha)
% MW 2017-08-24
% function [h, p, p_indices] = bonferroni_holm(A,B, alpha)
% runs pairwise students ttest with Bonferroni-Holm 'ordered sequential correction' for multiple tests

%A and B are expected to be matrices of row vectors

%% Outputs:
%   h: result of the corrected hypothesis test, vector 1 x size(A,2)
%   with h=1 indicates significant difference of means
%   p: p-values from the ttest in original order
%   p_indices : subscript indices from the original vectors A,B where
%   column means were significantly different, subscripts are in order
%   of descending p-values
%%
nout = 0;

if numel(A)~=numel(B)
    disp('input matrix dimensions must match')
    h = NaN;
    varargout = {NaN};
%     return
else
alphavec = alpha*(1:size(A,2))/size(A,2);
[~,p]=ttest2(A, B, 'Alpha', alpha, 'Vartype', 'unequal');
[p_sorted,p_idcs] = sort(p);
hsorted = alphavec>p_sorted;
h = zeros(1,length(A));
h(p_idcs(hsorted)) = 1;

nout = max(nargout,1) - 1;

s{1} = p;
s{2} = p_idcs(hsorted);
end

for k = 1:nout
   varargout{k} = s{k};
end