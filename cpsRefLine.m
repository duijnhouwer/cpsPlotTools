function lh=cpsRefLine(varargin)
    
    %cpsRefLine Draw reference lines
    %   cpsRefLine(LINETYPE) draws the line specified by LINETYPE into the
    %   current axes. LINETYPE options are:
    %       '-': Draws the line Y=0;
    %       '|': Draws the line X=0;
    %       '/': Draws the unity line, Y=X;
    %       '\': Draws the line Y=-X.
    %
    %   cpsRefLine(H,LINETYPE) draws the reference lines in the axes
    %   specified by the (array of) Axes-object(s) H.
    %
    %   cpsRefLine([],LINETYPE) is equivalent to cpsRefLine(LINETYPE).
    %
    %   cpsRefLine('-',PAR), where PAR is a number, draws the line Y=PAR
    %   and cpsRefLine('|',PAR) draws the line X=PAR.
    %
    %   Multiple lines can be drawn with one call. For example,
    %   cpsRefLine('-',10,'|','/') draws a cross at X=0, Y=10, and the
    %   unity line.
    %
    %   Any further arguments are relayed to the internal plot command that
    %   draws the lines. cpsRefLine('|','-','k--','LineWidth',5) draws a
    %   thick, dashed black cross. The default LineWidth is 0.5.
    %
    %   H=cpsRefLine(...) returns the handles to the lines drawn (class:
    %   Line).
    %
    %   Example:
    %       cpsFindFig('cpsRefLine example');
    %       subplot(1,2,1)
    %       plot(randn(10,1),randn(10,1),'o');
    %       subplot(1,2,2)
    %       plot(randn(10,1),randn(10,1),'o');
    %       ax=cpsGetAxes;
    %       cpsRefLine(ax,'/','k');
    %       cpsRefLine(ax,'|','-','k--','LineWidth',0.5);
    %       
    %
    %   Part of <a href="matlab:plcInfo">cpsPlotTools</a>.
    
    %   Copyright 2016 Jacob Duijnhouwer
    
    if nargin==0
        error('Not enough input arguments.');
    end
    %
    % Get the axes to draw in
    if isempty(varargin{1})
        % The default for cpsRefLines in the current axes ((sub)plot)
        ax=get(get(0,'CurrentFigure'),'CurrentAxes'); % like gca, but no creation
        varargin(1)=[];
    elseif isa(varargin{1},'matlab.graphics.axis.Axes')
        % One or more (sub)plots explicitely defined.
        ax=varargin{1};
        varargin(1)=[];
    elseif ischar(varargin{1})
        % The 'what panels to draw in' arguments is omitted. The first
        % argument is the LINETYPE. Default to drawing the line in the
        % current panel. all panels in the current figure
        ax=get(get(0,'CurrentFigure'),'CurrentAxes');      
    else
        ax=get(get(0,'CurrentFigure'),'CurrentAxes');
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
    % Add the default linewidth to plops unless one has been explicitely
    % specified
    if ~any(strcmpi('LineWidth',plops))
        plops=[plops {'LineWidth',0.5}];
    end
    % Check that lineTypes have been provided
    if isempty(lineTypes)
        error('No refline-type provided (''-|/\'').');
    end
    %
    % Loop over ax and lineTypes and draw the lines
    lh=[];
    for ai=1:numel(ax)
        for li=1:numel(lineTypes)
            drawLine(ax(ai),lineTypes(li),lineParms{li},plops); %#ok<AGROW>
            drawnow;
            lh(end+1)=drawLine(ax(ai),lineTypes(li),lineParms{li},plops); %#ok<AGROW>
        end
    end
end

function lh=drawLine(ax,oriChar,nops,plops)
    %
    % Create the tag for this line
    tagStr=[mfilename oriChar num2str(nops,'%.6e')];
    %
    % See if ax already has a cpsRefline of the current oriChar-type, delete that one first
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
        axis auto;
        hold(ax,'off')
    end
end
