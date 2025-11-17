function out = getTrialData(dat,idx1,idx2)

x = dat(idx1 & idx2);

if iscell(x)
    x = cell2mat(x);
end

if isempty(x) || sum(idx1 & idx2) == 0
    out	= nan;
else
    out = x;
end

end