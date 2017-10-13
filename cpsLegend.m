function legendhandle=cpsLegend(ax)
    
 % EXAMPLE:
 %   cpsFindFig('cpsAddLegend example');
 %   clf
 %   h=plot(rand(10,1));
 %   h.Tag='legend:Line#1';
 %   hold on
 %   h=plot(rand(10,1));
 %   h.Tag='legend:Line#2';
 %   cpsLegend
    
    if nargin==0
        ax=gca;
    end
    % remove existing legends if there are any
    ch=get(ax,'Children');
    for i=1:numel(ch)
        if isa(ch(i),'matlab.graphics.illustration.Legend')
            delete(ch(i));
           %ch(i)=[];
        end
    end
    h=[];
    lbl={};
    for i=1:numel(ch)
        start=strfind(lower(ch(i).Tag),'<lgnd>')+numel('<lgnd>');
        if ~isempty(start)
            stop=strfind(lower(ch(i).Tag),'</lgnd>');
            if isempty(stop)
                stop=numel(ch(i).Tag);
            end
            h(end+1)=ch(i); %#ok<AGROW>
            lbl{end+1}=ch(i).Tag(start:stop-1); %#ok<AGROW>
        end
    end
    if ~isempty(h)
        legendhandle=legend(ax,h,lbl);
    end
end
