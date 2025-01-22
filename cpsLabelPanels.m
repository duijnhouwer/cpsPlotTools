function labelHandles=cpsLabelPanels(varargin)
    
    %cpsLabelPanels     Add lettering to multipart figures
    %   cpsLabelPanels adds labels A, B, C, etc. to the subplots in the
    %   current figure window, in the order in which they have been
    %   created.
    %
    %   cpsLabelPanels(LBLS)  LBLS typically contains a single letter that
    %   will be used as the label for the first panel, subsequent panels
    %   will be labeled by cycling through the ASCII table from that
    %   starting point. The default for LBLS is 'A'. Alternatively, LBLS
    %   may contain the characters by which the panels will be labeled.
    %   Insert a space to skip a panel.
    %
    %   By default, cpsLabelPanels(...) will label all panels in the
    %   current figure. Optionally, use cpsLabelPanels(H,...) where
    %   argument H can be an:
    %       Array of Axes-objects: label these panels;
    %       Figure-object: label the panels in this object;
    %       Empty array: label the panels in the current figure;
    %    
    %   cpsLabelPanels takes 1 optional parameter-value pair:
    %       Parameter   Value:
    %       'Location'  Place the labels 'inside' or (default) 'outside' 
    %                   the panels
    %
    %   Any further arguments are relayed to the internal text command that
    %   prints the letters, e.g., cpsLabelPanels(...,'FontSize',14).
    %
    %   Examples:
    %       % Standard
    %       subplot(2,2,1);
    %       subplot(2,2,2);
    %       subplot(2,2,[3 4]);
    %       cpsLabelPanels;
    %
    %       % Big bold font
    %       subplot(2,2,1);
    %       subplot(2,2,2);
    %       subplot(2,2,[3 4]);
    %       cpsLabelPanels([],[],'FontSize',14,'FontWeight','bold');
    %
    %       % Alternatively, set the properties afterwards
    %       subplot(2,2,1);
    %       subplot(2,2,[2 4]);
    %       subplot(2,2,3);
    %       h=cpsLabelPanels;
    %       set(h,'Color',[0 0 1],'FontSize',18)
    %
    %       % Explicit figure referencing, two methods
    %       h = cpsFindFig('Test');
    %       subplot(2,1,1);
    %       subplot(2,1,2);
    %       cpsFindFig('Test2');
    %       cpsLabelPanels(h,'1'); % handle reference
    %       cpsLabelPanels('Test2','a'); % title reference
    %
    %       % Freestyle labels (albeit limited to 1 or no character)
    %       h = findfig('Test2');
    %       subplot(2,2,1);
    %       subplot(2,2,2);
    %       subplot(2,2,3);
    %       subplot(2,2,4);
    %       cpsLabelPanels(h,'A2 Z');
    %
    %   Part of <a href="matlab:help cpsPlotTools">cpsPlotTools</a>.
    %
    %   See also: text, cpsFindFig
    %
    % BUG 20161109: inadvertently resets colormap!
    
    %   Copyright 2016 Jacob Duijnhouwer
    
    
  
 
    
    % Check that there are open figures
    if isempty(findobj(get(0,'children')))
        warning('No figure to label.');
        return;
    end
    
    
    % Get the panels (axes-objects) to add labels to.
    if numel(varargin)==0
        % Get all the panels (axes-objects) in the current figure
        ax=cpsGetAxes('CurrentFigure');
    elseif isempty(varargin{1})
        % Get all the panels (axes-objects) in the current figure
        ax=cpsGetAxes('CurrentFigure');
        varargin(1)=[];
    elseif isa(varargin{1},'matlab.ui.Figure') 
        % Get all the panels (axes-objects) in the specified figure
        ax=cpsGetAxes(varargin{1});
        varargin(1)=[];
    elseif isa(varargin{1},'matlab.graphics.axis.Axes')
        % Add labels to the (array of) Axes-object(s)
        ax=varargin{1};
        varargin(1)=[];
    else
        % Axis argument ommited, default to all axes in the current figure
        ax=cpsGetAxes('CurrentFigure');
    end

    % There can be at most one parameter left and N parameter-value pairs.
    % Therefore, if the remaining number of varargin is even, the label
    % string (the letters that should be used) is not provided and should
    % default. If it's odd and larger than 1, then
    % check if the first label is a string and the subsequent varargin (if
    % any) is also a string (that should be a parameter name.
    if numel(varargin)==0 || mod(numel(varargin),2)==0
        % labels were not provided
        labels=char('A'+(0:numel(ax)-1)); % ABCD... is the default
    else
        labels=varargin{1};
        varargin(1)=[];
        % Check the values of labels
        if isempty(labels)
            labels=char('A'+(0:numel(ax)-1)); % ABCD... is the default
        elseif isscalar(labels)
            if ~ischar(labels)
                error(['Start-letter must be a char, but a ' class(labels) ' was provided.']);
            else
               labels=char(labels+(0:numel(ax)-1)); % if labels was 'a', the labels will be 'abcd...'
            end
        elseif numel(ax)>numel(labels) && numel(labels)>1
            % warning('More panels than provided labels, appending whitespace to label array');
            labels=[labels repmat(' ',1,numel(ax)-numel(labels))];
        elseif numel(ax)<numel(labels)
            % warning('Less panels than provided labels, ignoring superfluous labels');
            labels=labels(1:numel(ax));
        elseif ~ischar(labels)
            error('labels should be a string, a cell array of strings, or empty');
        end
    end
    
    % parse the optional parameters in varargin that should not be piped to
    % text.m. The option will be removed from varargin, if the option
    % string occurs multiple times in varargin, only the first one is used
    % by cpsPanelLabel, the others are relayed to text.
    % As of 20160409, there's only one option: Location
    idx=find(strcmpi('Location',varargin));
    if ~isempty(idx)
        if numel(idx)==numel(varargin)
            error('Invalid parameter-value pair ''Location'', no value provided');
        end
        labelPos=varargin{idx+1};
        varargin(idx:idx+1)=[];
    else
        labelPos='outside'; % the default Location
    end
    
    % Determine the median panel width. The horizontal offset of the labels
    % will be scaled to that width
    panelWids=nan(size(ax));
    for i=1:numel(ax)
        if labels(i)==' '
            continue;
        end
        oldUnits=ax(i).Units;
        ax(i).Units='pixels';
        panelWids(i)=ax(i).Position(3);
        ax(i).Units=oldUnits;
    end
    medianWid=median(panelWids,'omitnan');
    clear panelWids;

    %
    labelHandles=[];
    for i=1:numel(ax)
        if isnan(labels(i))
            continue;
        end
        %axes(ax(i));
        oldUnits=ax(i).Units;
        ax(i).Units='pixels';
        wid=ax(i).Position(3);
        ax(i).Units=oldUnits;
        if strcmpi(labelPos,'outside')
            xPos=-0.1*medianWid/wid;
            yPos=1.01;
        else
            xPos=0.05*medianWid/wid;
            yPos=0.95;
            % warning('need to make hei also adaptive to different panel heights')
        end
        try
            t=text(ax(i),xPos,yPos,labels(i),varargin{:},'Units','normalized');
        catch me
            try
                warning(me.message)
                t=text(ax(i),xPos,yPos,labels(i),'Units','normalized');
            catch me
                rethrow(me);
            end
        end
        % If FontSize wasn't defined, use default 14
        if ~any(strcmpi('FontSize',varargin))
            t.FontSize=14;
        end
        if strcmpi(labelPos,'outside')
            t.HorizontalAlignment='right';
            t.VerticalAlignment='bottom';
        elseif strcmpi(labelPos,'inside')
            t.HorizontalAlignment='left';
            t.VerticalAlignment='top';
        else
            error(['Unknown label Location option: ''' labelPos '''.']);
        end
        labelHandles(end+1)=t; %#ok<AGROW>
    end
end
