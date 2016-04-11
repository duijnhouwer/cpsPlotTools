function lh=cpsRefLine(varargin)
    
    %cpsRefLine Draw reference lines
    %   cpsRefLine(LINETYPE,PAR) draws the line specified by LINETYPE with
    %   optional numerical options PAR into the current axes. LINETYPE
    %   options are:
    %       '-': Draws y=PAR. Default PAR is 0; 
    %       '|': Draws x=PAR. Default PAR is 0;
    %       '/': Draws y=PAR(2)+x*PAR(2). Default PAR is [1 0]; 
    %       '\': Also draws y=PAR(2)+x*PAR(2), but PAR defaults to [-1 0];
    %       '+': Draws a cross x=PAR(1), y=PAR(2). Default PAR is [0 0].
    %
    %   PAR can be a vector or a comma separated list, i.e.,
    %   cpsRefLine('/',[1 0]) and cpsRefLine('/',1,0) are equivalent
    %
    %   The line segments drawn by cpsRefLine are limited by the axis
    %   limits at the time of calling. Therefore, it is typically best to
    %   call cpsRefLine after all the data have been plotted or the final
    %   axis limits are otherwise fixed.
    %
    %   cpsRefLine(AX,LINETYPE) draws the reference lines in the panels
    %   specified by the Axes class handle(s) in H.
    %
    %   cpsRefLine([],LINETYPE) is equivalent to cpsRefLine(LINETYPE).
    %
    %   Multiple lines can be drawn with one call. For example,
    %   cpsRefLine('+',10,0,'/') draws the cross x=10, y-0, and the
    %   unity line.
    %
    %   cpsRefLine(...,'below') draws the line underneath existing graphics
    %   elements instead of on top.
    %
    %   cpsRefLine(...,'noreplace') By default, an existing cpsRefLine with
    %   the same LINETYPE and PAR values as the one being added is deleted.
    %   This is useful in situation where data is dynamically added to a
    %   graph which changes the axis limits. The option 'noreplace'
    %   overrides this default behavior.
    %
    %   Any further arguments are relayed to the internal plot command that
    %   draws the lines. cpsRefLine('|','-','k--','LineWidth',5) draws a
    %   thick, dashed black cross. The default LineWidth is 0.5.
    %
    %   H=cpsRefLine(...) returns the handles to the lines drawn (class:
    %   Line).
    %
    %   Example:
    %       cpsFindFig('cpsRefLine example1');
    %       gcf;
    %       subplot(1,2,1)
    %       plot(randn(100,1),randn(100,1),'ro','MarkerFaceColor','r');
    %       subplot(1,2,2)
    %       plot(randn(100,1),randn(100,1)/2,'ro','MarkerFaceColor','r');
    %       ax=cpsGetAxes;
    %       cpsRefLine(ax,'/','k','LineWidth',1);
    %       cpsRefLine(ax,'+','k--','below'); 
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
    % Get what linetype to draw (-|/\+) and their optional 1-number parameter
    lineTypes=''; % char -|/\+
    lineParms={}; % cell with number array per lineType only
    while true
        if numel(varargin)>0 && ischar(varargin{1}) && numel(varargin{1})==1 && any(varargin{1}=='-|/\+')
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
    %
    % See if the remainder of varargin has cpsRefline specific options
    idx=find(strcmpi(varargin,'below'));
    if ~isempty(idx)
        below=true;
        varargin(idx)=[];
    else
        below=false;
    end
    idx=find(strcmpi(varargin,'noreplace'));
    if ~isempty(idx)
        noreplace=false;
        varargin(idx)=[];
    else
        noreplace=true;
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
        error('No refline-type provided (''-|/\+'').');
    end
    % If the lineType '+' has been provided, expand it to '|-'
    idx=find(lineTypes=='+');
    if ~isempty(idx)
        % Replace + with |-
        lineTypes=strrep(lineTypes, '+', '|-');
        % Copy the corresponding parameter(s) if any
        if numel(lineParms{idx})<=1 
            lineParms={lineParms{1:idx} lineParms{idx} lineParms{idx+1:end}};
        elseif numel(lineParms{idx})>1
            lineParms={lineParms{1:idx-1} lineParms{idx}(1) lineParms{idx}(2)  lineParms{idx+1:end}};
        end
    end
    %
    % Loop over ax and lineTypes and draw the linesdbq
    lh=[];
    axLims=axis(ax);
    for ai=1:numel(ax)
        for li=1:numel(lineTypes)
            lh(end+1)=drawLine(ax(ai),lineTypes(li),lineParms{li} ...
                ,plops,noreplace,below); %#ok<AGROW>
        end
    end
    % reset the starting limits of the axis or axes. Do this at the very
    % end, not in the drawing loop, because drawing in one Axes may change
    % the limits in another. (I find this weird, but that's how it works at
    % least in Matlab R2014b)
    if numel(ax)==1
        axis(ax,axLims);
    else
        for ai=1:numel(ax)
            axis(ax(ai),axLims{ai});
        end
    end
end

function lh=drawLine(ax,oriChar,nops,plops,noreplace,below)
    %
    % Create the tag for this line
    tagStr=[mfilename oriChar num2str(nops,'%.6e')];
    %
    if ~noreplace
        % Delete previous line with the same linetype and pars
        delete(findobj(get(ax,'children'),'Tag',tagStr))
    end
    %
    areHolding=ishold;
    if ~areHolding
        hold(ax,'on');
    end
    %
    axLims=axis(ax);
    minx=min(axLims(1:2));
    maxx=max(axLims(1:2));
    miny=min(axLims(3:4));
    maxy=max(axLims(3:4));
    if any(oriChar=='/\')
        if numel(nops)==0
            if oriChar=='/'
                slope=1;
            elseif oriChar=='\'
                slope=-1;
            end
            intercept=0;
        elseif numel(nops)==1
            slope=nops;
            intercept=0;
        elseif numel(nops)==2
            slope=nops(1);
            intercept=nops(2);
        else
            warning(['''' oriChar '''-plot takes at most 2 numerical parameters, ignoring the superfluous ' num2str(numel(nops)-2) '.']);
            v=nops(1);
        end
        XX=[minx maxx];
        YY=XX*slope+intercept;
        % Might now want to truncate the line the axis-limits to be more
        % consistent with the - and | behavior but don't think it's needed
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
            XX=[minx maxx];
            YY=[v v];
        else
            XX=[v v];
            YY=[miny maxy];
        end
    end
    %
    % plot the line segment
    lh=plot(ax,XX,YY,plops{:});
    %
    % Tag the line so that this function can remove it in case the function gets called
    % again with the same arguments (necessary after rescaling the axes for example).
    set(lh,'Tag',tagStr);
    %
    % Put the line at the bottom, underneath the data, if requested
    if below
        kids=get(ax,'Children');
        set(ax,'Children',[kids(2:end); kids(1)]);
    end
    % reset the hold state, if necessary
    if ~areHolding
        axis auto;
        hold(ax,'off')
    end
end
