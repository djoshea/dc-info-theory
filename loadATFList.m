function atfs = loadATFList(fname)
% takes in the ATF list CSV file with columns as below and converts it into a struct array

colList = {'cellid', 'path', 'filenum', 'include', 'mousetype', 'celltype', 'expressing', 'gAMPA', 'opsinState', 'currentInjType', 'freqMod'};
out = [];

if(~exist('fname','var'))
   [file path] = uigetfile({'*.csv', 'CSV File'}, ...
        'Choose the ATF Log File to Load');
    if isequal(file,0) || isequal(path,0)
        error('No CSV file chosen. Aborting.');
        return % canceled
    end
    fname = strcat(path,file)
end

fid = fopen(fname);
header = fgetl(fid);

atfs = struct();
j = 0;


while true
   j = j+1;
   ln = fgetl(fid);
   if ~ischar(ln), break, end
   
   % split the string by commas
   for fld = 1:length(colList)
       [part ln] = strtok(strtrim(ln), ',');
       if(fld == 1 && isempty(part)) % empty lines with just commas?
           break;
       end
       
       [num ok] = str2num(part); % convert to number if possible
       if(ok), part = num; end
       atfs(j).(colList{fld}) = part;
   end
end

fclose(fid);

end

