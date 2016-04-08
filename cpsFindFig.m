function [h,created] = cpsFindFig(tag,varargin)
    %cpsFindFig Create or find a figure-window by name.
    %   cpsFindFig(TAG) creates a new figure named and tagged with string
    %   TAG. Or, if a figure tagged with TAG already exists, brings it into
    %   focus.
    %
    %   cpsFindFig takes 3 optional parameter-value pairs:
    %
    %       Parameter   Value:
    %       'visible'   Figure visibility upon creation [true] | false
    %       'position'  Figure position in pixels [leftx topy wid hei],
    %                   or an empty array ([], the default) which produces
    %                   a standard-size window.
    %       'create':   Toggle creation of figure if novel TAG is provided
    %                   [true] | false
    %
    %   [H,CREATED] = cpsFindFig(...) Returns the figures's class object
    %   and a logical which indicates if a novel figure has been created or
    %   not.
    %
    %   Part of <a href="matlab:cpsInfo">cpsPlotTools</a>.
    %
    %   See also: figure
    
    %   Copyright 1998 Bart Krekelberg, 2016 Jacob Duijnhouwer
    
    p=inputParser;
    p.addRequired('tag',@ischar);
    p.addOptional('visible',true,@islogical);
    p.addOptional('position',[],@(x)isempty(x) || isnumeric(x) && numel(x)==4);
    p.addOptional('create',true,@(x)islogical(x) || x==1 || x==0);
    p.parse(tag,varargin{:});
    
    if p.Results.visible
        visi='on';
    else
        visi='off';
    end
    
    h = findobj(get(0,'children'),'flat','tag',tag);
    if ~isempty(h)
        % set focus to already existing figure
        set(h,'visible',visi);
        figure(h);
        created=false;
    elseif p.Results.create
        h = figure('visible','off');
        set(h,'resize','on','tag',tag,...
            'visible','off','name',tag,'menubar','figure',...
            'numbertitle','off',...
            'paperunits','centimeters');
        if ~isempty(p.Results.position)
            set(h,'Position',p.Results.position);
        end
        drawnow;
        set(h,'visible',visi);p.Results.create
        created=true;
    else
        h=[];
        created=false;
        return;
    end
end
