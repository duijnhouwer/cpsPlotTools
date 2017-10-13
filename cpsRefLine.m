function lh=cpsRefLine(varargin)
    
    %cpsRefLine Draw reference lines
    %   cpsRefLine(LINETYPE,PAR) draws the line specified by LINETYPE with
    %   optional numerical options PAR into the current axes. LINETYPE
    %   options are:
    %       '-': Draws y = PAR. Default PAR is 0
    %       '|': Draws x = PAR. Default PAR is 0
    %       '/': Draws y = PAR(2) + PAR(1)*x. Default PAR is [1 0]
    %       '\': Draws y = PAR(2) + PAR(1)*x, but PAR defaults to [-1 0]
    %       '+': Draws a cross x = PAR(1), y = PAR(2). Default PAR is [0 0]
    %
    %   Specifying PAR as an Nx1 (or 1xN) vector results in N lines with
    %   the specified offsets (for LINETYPEs '-' and '|') or slopes (for
    %   the diagonal LINETYPEs '/' and '\'. To specify the offset for
    %   multiple diagonals, provide a Nx2 PAR matrix, where column 1
    %   represents the slopes and column 2 the intercepts. An Nx2 PAR for
    %   LINETYPE '+' specifies N crosses at x = PAR(:,1) y = PAR(:,2). An
    %   Nx1 (or 1xN) PAR for LINETYPE '+' specifies N crosses at x = y =
    %   PAR(:).
    %
    %   The line segments drawn by cpsRefLine are limited by the axis
    %   limits at the time of calling. Therefore, it is typically best to
    %   call cpsRefLine after all the data have been plotted or the final
    %   axis limits are otherwise fixed.
    %
    %   cpsRefLine(H,LINETYPE) draws the reference lines in the panels
    %   specified by the Axes class handle(s) in H. H can be a single Axes
    %   object or an array of those. H can also be a figure or an array of
    %   figures, in which case cpsRefLine will draw in all their Axes-class
    %   children (all their (sub)plots).
    %
    %   cpsRefLine([],LINETYPE) is equivalent to cpsRefLine(LINETYPE).
    %
    %   Multiple lines can be drawn with one call. For example,
    %   cpsRefLine('+',10,0,'/') draws the cross x=10, y-0, and the
    %   unity line.
    %
    %   cpsRefLine(...,'back') draws the line behind existing graphics
    %   elements instead of on top.
    %
    %   cpsRefLine(...,'noreplace') By default, an existing cpsRefLine with
    %   the same LINETYPE and PAR values as the one being added is deleted.
    %   This is useful in situation where data is dynamically added to a
    %   graph which changes the axis limits. The option 'noreplace'
    %   overrides this default behavior.
    %
    %   Any further arguments are relayed to the internal plot command that
    %   draws the lines. cpsRefLine('+','k--','LineWidth',5) draws a
    %   thick, dashed, red cross. The default LineWidth is 0.5.
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
    %       cpsRefLine(ax,'/',[.5 1 2],'k','LineWidth',1);
    %       cpsRefLine(ax,'+','k--','back'); 
    %
    %   Part of <a href="matlab:help cpsPlotTools">cpsPlotTools</a>.
    %
    %   See also: refline
    
    %   Copyright 2016 Jacob Duijnhouwer
    
    if nargin==0
        error('Not enough input arguments.');
    end
    %
    % Get the axes to draw in
    if isempty(varargin{1})
        % The default for cpsRefLine is the current axes, i.e., (sub)plot
        ax=get(get(0,'CurrentFigure'),'CurrentAxes'); % like gca, but no creation
        varargin(1) = [];
    elseif ischar(varargin{1})
        % The 'what Axes to draw in' arguments is omitted. The first
        % argument is the LINETYPE. Default to drawing the line in the
        % current Axes
        ax=get(get(0,'CurrentFigure'),'CurrentAxes');
    elseif isa(varargin{1},'matlab.graphics.axis.Axes')
        % One or more (sub)plots explicitely defined.
        ax=varargin{1};
        varargin(1) = [];
    elseif isa(varargin{1},'matlab.ui.Figure')
        % A Figure or an array of Figures, get all their Axes children
        ax = [];
        for i=1:numel(varargin{1})
            ax = [ax cpsGetAxes(varargin{1}(i))]; %#ok<AGROW>
        end
        varargin(1) = [];
    else
        error(['First argument can''t be of type ''' class(varargin{1}) '''.']);
    end
    %
    if isempty(ax)
        error('No Axes to draw cpsRefLines in');
    end
    %
    % Get what linetype to draw (-|/\+) and their optional 1-number parameter
    lineTypes = ''; % char -|/\+
    lineParms = {}; % cell with number array per lineType only
    while true
        if numel(varargin)>0 && ischar(varargin{1}) && numel(varargin{1})==1 && any(varargin{1}=='-|/\+')
            lineTypes(end+1) = varargin{1}; %#ok<AGROW>
            varargin(1) = [];
            optionalNumbers = [];
            if numel(varargin)>0 && isnumeric(varargin{1})
                optionalNumbers = varargin{1};
                varargin(1) = [];
                if isvector(optionalNumbers)
                    % if vector make column to ensure each row is a line
                    optionalNumbers = optionalNumbers(:);
                end
            end
            lineParms{end+1} = optionalNumbers; %#ok<AGROW>
        else
            break;
        end
    end
    %
    % See if the remainder of varargin has cpsRefline specific options
    idx = find(strcmpi(varargin,'back'));
    if ~isempty(idx)
        back = true;
        varargin(idx) = [];
    else
        back = false;
    end
    idx = find(strcmpi(varargin,'noreplace'));
    if ~isempty(idx)
        noreplace = true;
        varargin(idx) = [];
    else
        noreplace = false;
    end    
    % Whatever is left of varargin will be relayed to 'plot' as options
    plops=varargin; % PLot OPtionS
    % Add the default linewidth to plops unless one has been explicitely
    % specified
    if ~any(strcmpi('LineWidth',plops))
        plops = [plops {'LineWidth',0.5}];
    end
    % Check that lineTypes have been provided
    if isempty(lineTypes)
        error('No refline-type provided (''-|/\+'').');
    end
    % If the lineType '+' has been provided, expand it to '|-'
    idx=find(lineTypes=='+');
    if ~isempty(idx)
        % Replace + with |-
        lineTypes = strrep(lineTypes, '+', '|-');
        % Copy the corresponding parameter(s) if any
        if ~isempty(lineParms{idx})
            lineParms = {lineParms{1:idx-1} lineParms{idx}(:,1) lineParms{idx}(:,end)  lineParms{idx+1:end}};
        else
            lineParms = {lineParms{1:idx-1} {} {}  lineParms{idx+1:end}};
        end
    end
    %
    % Loop over ax, lineTypes, lineParms and draw the lines
    lh=[];
    if numel(ax)==1
         axLims{1} = axis(ax);
    else
        axLims = axis(ax);
    end
    for a = 1:numel(ax)
        for t = 1:numel(lineTypes)
            axis(ax(a),axLims{a}); % make sure that the axis limits are up to date, drawLine needs them
            if isempty(lineParms{t})
                lh(end+1) = drawLine(ax(a),lineTypes(t),[],plops,noreplace,back); %#ok<AGROW>
            else
                for p = 1:size(lineParms{t},1)
                    lh(end+1) = drawLine(ax(a),lineTypes(t),lineParms{t}(p,:),plops,noreplace,back); %#ok<AGROW>
                end
            end
           % axis(ax(a),axLims{a});
        end
    end
    % reset the starting limits of the axis or axes. Do this at the very
    % end, not in the drawing loop, because drawing in one Axes may change
    % the limits in another. I find this very odd, but that's how it works
    % at least in Matlab R2014b.
    for a = 1:numel(ax)
        axis(ax(a),axLims{a});
    end
end

function lh=drawLine(ax,oriChar,nops,plops,noreplace,back)
    %
    % Step 1: Calculate the left/right XX and bottom/top YY
    % 1a. These depend on the current axis limits
    axLims = axis(ax);
    minx = min(axLims(1:2));
    maxx = max(axLims(1:2));
    miny = min(axLims(3:4));
    maxy = max(axLims(3:4));
    % 1b. And on the oriChar and numerical options
    if any(oriChar=='/\')
        if numel(nops)==0
            if oriChar=='/'
                slope = 1;
            elseif oriChar=='\'
                slope = -1;
            end
            intercept = 0;
        elseif numel(nops)==1
            slope = nops;
            intercept = 0;
        elseif numel(nops)==2
            slope = nops(1);
            intercept = nops(2);
        else
            warning(['''' oriChar '''-plot takes at most 2 numerical parameters, ignoring the superfluous ' num2str(numel(nops)-2) '.']);
            v = nops(1);
        end
        XX = [minx maxx];
        YY = XX*slope+intercept;
        % Might now want to truncate the line the axis-limits to be more
        % consistent with the - and | behavior but don't think it's needed
    elseif any(oriChar=='-|')
        if numel(nops)==0
            v = 0; % the default
        elseif numel(nops)==1
            v = nops;
        elseif numel(nops)>1
            warning(['''' oriChar '''-plot takes at most 1 numerical argument, ignoring all ' num2str(numel(nops)) ' but 1st provided.']);
            v = nops(1);
        end
        if oriChar=='-'
            XX = [minx maxx];
            YY = [v v];
        else
            XX = [v v];
            YY = [miny maxy];
        end
    end
    %
    % Step 2. Create the tag for this line so the object handles can be
    % recognized easily. In previous version, this was used to delete
    % identical cpsRefLines in case the noreplace options was false, but
    % looking directly at the XData and YData is more precise.
    tagStr = [mfilename ',' oriChar num2str(nops(:)',',%g')];
    tagStr(tagStr==' ') = '';
    %
    if ~noreplace
        % Delete previous congruent lines
        congruentLine = findobj(get(ax,'children'),'XData',XX,'YData',YY);
        delete(congruentLine);
    end
    %
    areHolding = ishold;
    if ~areHolding
        hold(ax,'on');
    end
    %
    % plot the line segment
    lh = plot(ax,XX,YY,plops{:});
    %
    % Tag the line so that this function can remove it in case the function
    % gets called again with the same arguments (which may be necessary after
    % rescaling the axes for example).
    set(lh,'Tag',tagStr);
    %
    % Put the line at the bottom, behind the data, if requested
    if back
        kids = get(ax,'Children');
        set(ax,'Children',[kids(2:end); kids(1)]);
    end
    % reset the hold state, if necessary
    if ~areHolding
        axis auto;
        hold(ax,'off')
    end
end
