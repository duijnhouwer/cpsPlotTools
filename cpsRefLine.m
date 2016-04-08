function lh=cpsRefLine(varargin)
    
    %plcUnifyAxes Unify axes of multiple (sub)plots
    %   plcUnifyAxes unifies the X, Y, Z, and C (color) axes of all the
    %   subplots in the current figure.
    %
    %   plcUnifyAxes(AXSTR) unifies the axes defined in AXSTR, a string
    %   containing any or all of 'xyzc', of all subplots (Axes-objects) in
    %   the current figure.
    %
    %   plcUnifyAxes(AX,AXSTR) where AX is an array of Axes-object unifies
    %   only the specified (sub)plots (which can be in multiple figures).
    %
    %   plcUnifyAxes([],AXSTR) scales the axes in the current figure,
    %   equivalent to plcUnifyAxes(AXSTR).
    %
    %   plcUnifyAxes(...,AXSTR) scales only the axes defined in AXSTR,
    %   which is a string containing any or all of 'xyzc'.
    %
    %   Examples:
    %      plcFindFig('plcUnifyAxes Fig1');
    %      subplot(1,2,1)
    %      imagesc(rand(10)); colorbar;
    %      subplot(1,2,2)
    %      imagesc(rand(10)*10); colorbar;
    %      plcUnifyAxes('c');
    %
    %      plcFindFig('plcUnifyAxes Fig2');
    %      plot(randn(100,1)*5,randn(100,1),'ro');
    %      h=gca;
    %      plcFindFig('plcUnifyAxes Fig3');
    %      plot(randn(100,1),randn(100,1)*10,'bo');
    %      h(end+1)=gca;
    %      plcUnifyAxes(h,'XY');
    %      plcTileFigs;
    %
    %   Part of <a href="matlab:plcInfo">cpsPlotTools</a>.
    
    %   Copyright 2016 Jacob Duijnhouwer
    
    if nargin==0
        error('Not enough input arguments.');
    end
    %
    % Get the axes to draw in
    if isempty(varargin{1})
        % Get all the panels (axes-objects) in the current figure
        ax=cpsGetAxes('currentFigure');
        varargin(1)=[];
    elseif isa(varargin{1},'matlab.graphics.axis.Axes')
        ax=varargin{1};
        varargin(1)=[];
    elseif ischar(varargin{1})
        % First argument is the AXSTR. Default to all axes current figure
        ax=cpsGetAxes('currentFigure');        
    else
        ax=get(0,'currentFigure'); % doesn't open a window unlike gca
    end
    %
    % Get what linetype to draw (-|/\) and their optional 1-number parameter
    lineTypes=''; % char -|/\
    lineParms={}; % cell with number array per lineType only
    while true
        if numel(varargin)>0 && ischar(varargin{1}) && numel(varargin{1})==1 && any(varargin{1}=='-|/\')
            lineTypes(end+1)=varargin{1}; %#ok<AGROW>
            varargin(1)=[];
            optionalNumbers=[];
            while numel(varargin)>0 && isnumeric(varargin{1})
                optionalNumbers=[optionalNumbers varargin{1}(:)']; %#ok<AGROW>
                varargin(1)=[];
            end
            lineParms{end+1}=optionalNumbers; %#ok<AGROW>
        else
            break;
        end
    end
    % Whatever is left of varargin will be relayed to 'plot' as options
    plops=varargin; % PLot OPtionS
    % Check that lineTypes have been provided
    if isempty(lineTypes)
        error('No refline-type provided (''-|/\'').');
    end
    %
    % Loop over ax and lineTypes and draw the lines
    lh=[];
    for ai=1:numel(ax)
        for li=1:numel(lineTypes)
            lh(end+1)=drawLine(ax(ai),lineTypes(li),lineParms{li},plops); %#ok<AGROW>
        end
    end
end

function lh=drawLine(ax,oriChar,nops,plops)
    %
    % Create the tag for this line
    tagStr=[mfilename oriChar num2str(nops,'%.6e')];
    %
    % See if ax already has a jdRefline of the current oriChar-type, delete that one first
    delete(findobj(get(ax,'children'),'Tag',tagStr))
    %
    areHolding=ishold;
    if ~areHolding
        hold(ax,'on');
    end
    %
    mini=min(axis(ax));
    maxi=max(axis(ax));
    if any(oriChar=='/\')
        if numel(nops)>0
            warning(['''' oriChar '''-plot does not take numerical arguments, ignoring the ' num2str(numel(nops)) ' provided.']);
        end
        if oriChar=='/'
            XX=[mini maxi];
            YY=[mini maxi];
        elseif oriChar=='\'
            XX=[mini maxi];
            YY=[maxi mini];
        end
    elseif any(oriChar=='-|')
        if numel(nops)==0
            v=0; % the default
        elseif numel(nops)==1
            v=nops;
        elseif numel(nops)>1
            warning(['''' oriChar '''-plot takes at most 1 numerical argument, ignoring all ' num2str(numel(nops)) ' but 1st provided.']);
            v=nops(1);
        end
        if oriChar=='-'
            XX=[mini maxi];
            YY=[v v];
        else
            XX=[v v];
            YY=[mini maxi];
        end
    end
    %
    % plot the line segment
    lh=plot(ax,XX,YY,plops{:});
    %
    % Tag the line so that this function can remove it in case the function gets called
    % again with the same arguments (necessary after rescaling the axes for example).
    set(lh,'Tag',tagStr);
    % reset the hold state, if necessary
    if ~areHolding
        hold(ax,'off')
    end
end
