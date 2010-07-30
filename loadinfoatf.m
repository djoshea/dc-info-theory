function [ traces epscs time si ] = loadinfoatf( fname )
% loads an atf file from the cc sweeps dc info protocol
% traces is the cell voltage, epscs is the copy of the dc input, time is the time trace, si is in microseconds

if(~exist('fname','var'))
   [file path] = uigetfile({'*.atf', 'Axon Text File'}, ...
        'Choose an ATF File to Load');
    if isequal(file,0) || isequal(path,0)
        % canceled
       return
    end
    fname = strcat(path,file);
end

DELIMITER = '\t';
HEADERLINES = 10;

% Import the file
% fprintf('\tLoading from %s...\n', fname);
newData = importdata(fname, DELIMITER, HEADERLINES);

% Create new variables in the base workspace from those fields.
vars = fieldnames(newData);
for i = 1:length(vars)
    assignin('base', vars{i}, newData.(vars{i}));
end

data = newData.('data');

time = data(:,1);
traces = data(:,2:2:end);
epscs = data(:,3:2:end);
si = 10^6 * (time(2) - time(1));

end

