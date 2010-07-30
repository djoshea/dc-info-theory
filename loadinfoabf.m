function [ traces epscs time si ] = loadinfoabf( fname )

if(~exist('fname','var'))
   [file path] = uigetfile({'*.abf', 'Axon Binary File'}, ...
        'Choose an ABF File to Load');
    if isequal(file,0) || isequal(path,0)
        % canceled
       return
    end
    fname = strcat(path,file);
end

[data si h] = abfload(fname);

time = data(:,1);
traces = data(:,2:2:end);
epscs = data(:,3:2:end);

end

