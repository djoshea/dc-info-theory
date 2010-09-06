function compare = gatherComparison(atfData, templates, varargin)
% templates is a struct containing the same fields as atfData(i)
% a trace is included if all of the fields match the template
% a cell's traces are included if it has traces matching each of the templates

def.groupfield = 'cellid'; % the organizational unit, each cell must have all conditions listed under templates array in order to be included
def.includeFilenamesInLegend = 0;
assignargs(def,varargin);

% template describes fields that must match values in the datatable

compareData = [];
compareDataGroupNames = {};
groupids = unique({atfData.(groupfield)}); % typically each cell

for g = 1:length(groupids)
    includeGroup = 1;
    fromGroup = []; % holds the matches to each template from this cell
    for ti = 1:length(templates) % grab one row for each template
        glist = atfData(strcmp(groupids{g}, {atfData.(groupfield)}));
        t = templates(ti);
        flds = fieldnames(t);
        for fld = 1:length(flds) % match each of the fields in the template
            if(ischar(t.(flds{fld})))
                glist = glist( strcmp({glist.(flds{fld})}, t.(flds{fld})) );
            else
                glist = glist( [glist.(flds{fld})] == t.(flds{fld}) );
            end
            
            if(isempty(glist))
                break;
            end
        end
        
        if(isempty(glist)) % couldn't find a match in this group
            includeGroup = 0;
            break;
        else % found a match, take the first and move to the next template
            if(isempty(fromGroup))
                fromGroup = glist(1);
            else
                fromGroup(ti) = glist(1);
            end
        end
    end
    
    if(includeGroup)
        if(isempty(compareData))
            compareData = fromGroup;
            compareDataGroupNames{1} = groupids{g};
        else
            compareData = [compareData; fromGroup];
            compareDataGroupNames{end+1} = groupids{g};
        end
    
        if(includeFilenamesInLegend)
            name = [groupids{g} ' ['];
            for ti = 1:length(templates)
                name = sprintf('%s %04d',name, fromGroup(ti).filenum);
            end
            name = [name ' ]'];
            compareDataGroupNames{end} = name;
        end
    end
end

compare.data = compareData;
compare.groupNames = compareDataGroupNames;
compare.N = size(compareData,1);
