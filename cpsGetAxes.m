function ax=cpsGetAxes(lvl)
    
    %cpsGetAxes Return handles to axes-objects.
    %   cpsGetAxes(LVL) where LVL is empty, or the string 'currentFigure'
    %   returns the Axes-objects in the current figure.
    %
    %   cpsGetAxes with no argument is equivalent to cpsGetAxes([]);
    %
    %   cpsGetAxes(LVL) where LVL is a Figure-object returns the
    %   Axes-objects in that figure. cpsGetAxes(gcf) is therefore similar
    %   to cpsGetAxes except that gcf creates a new figure window when
    %   there are none. LVL can also be an array of Figure-objects.
    %
    %   cpsGetAxes('session') returns all Axes-objects in the
    %   current Matlab session.
    %
    %   Example:
    %       close all; % figures
    %       h=cpsFindFig('a');
    %       plot(rand(10,1));
    %       h(end+1)=cpsFindFig('b');
    %       subplot(2,1,1);
    %       subplot(2,1,2);
    %       h(end+1)=cpsFindFig('c');
    %       subplot(2,1,1);
    %       subplot(2,1,2);
    %       cpsTileFigs;
    %       currentFigureAxes=cpsGetAxes
    %       allAxes=cpsGetAxes('session')
    %       abAxes=cpsGetAxes(h(1:2))
    %       acAxes=cpsGetAxes([cpsFindFig('a') cpsFindFig('b')])     
    %
    %   Part of <a href="matlab:cpsInfo">cpsPlotTools</a>.
    
    %   Copyright 2016 Jacob Duijnhouwer
    
    if ~exist('lvl','var') || isempty(lvl)
        ax=findobj(get(get(0,'currentFigure'),'Children')','Type','axes');
    elseif isa(lvl,'matlab.ui.Figure')
        ax=[];
        for i=1:numel(lvl)
            ax=[ax; findobj(get(lvl(i),'Children'),'Type','axes')];
        end
    elseif ischar(lvl)
        if strcmpi(lvl,'currentFigure') || isempty(lvl)
            ax=findobj(get(get(0,'currentFigure'),'Children')','Type','axes');
        elseif strcmpi(lvl,'session')
            ax=findobj(get(0,'Children'),'Type','axes');
        else
            error(['Unknown string argument: ' lvl]);
        end
    else
        error('Incorrect argument');
    end
    %
    % Reverse the order so that the first Axes object created is first in
    % the list
    ax=ax(end:-1:1);
end