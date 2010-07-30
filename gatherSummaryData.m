fnames = {...
    '/Users/djoshea/Documents/Research/dLab/dlab data/2010_06_11/cell0611_1.mat',...
    '/Users/djoshea/Documents/Research/dLab/dlab data/2010_07_09/cell0709_1.mat',...
    '/Users/djoshea/Documents/Research/dLab/dlab data/2010_07_09/cell0709_2.mat',...
    };

prs = [];
res = {};

for fi = 1:length(fnames)
    fprintf('Loading %s...\n', fnames{fi});
    vars = load(fnames{fi});
    fields = fieldnames(vars);
    i = find(cellfun(@length,strfind(fields, '_prs')));
    prsi = vars.(fields{i});
    i = find(cellfun(@length,strfind(fields, '_res')));
    resi = vars.(fields{i});
    
    prs = cat(2,prs,prsi);
    res = cat(2,res,resi);
end

fprintf('Total Comparisons Loaded: %d\n', length(prs));