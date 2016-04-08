function labelHandles=cpsLabelPanels(varargin)
    
    %cpsLabelPanels  Add one-character labels to panels (subplots)
    %   cpsLabelPanels adds labels A, B, C, etc. to the subplots in the
    %   current figure window, in the order in which they have been
    %   created.
    %
    %   cpsLabelPanels(LBLS) String LBLS contains
    %   the characters by which the panels will be labeled. Insert a space
    %   to skip a panel. LBLS contains typically a single letter that will
    %   be used as the label for the first panel, cycling through the ASCII
    %   table for subsequent panels will be labeled by cycling through the
    %   ASCII table from that starting point. The default for LBLS is
    %   'A'.
    %
    %   By default, cpsLabelPanels(...) will label all panels in the
    %   current figure. Optionally, use cpsLabelPanels(H,...) where
    %   argument H can be an:
    %       Array of Axes-objects: label these panels;
    %       Figure-object: label the panels in this object;
    %       Empty array: label the panels in the current figure;
    %
    %   cpsLabelPanels(H,LBLS,POS) String POS is used to make the labels
    %   appear 'inside' or (default) 'outside' the panels.
    %
    %   cpsLabelPanels takes 1 optional parameter-value pair:
    %       Parameter   Value:
    %       'position'  Place the labels 'inside' or (default) 'outside'] 
    %                    the panels
    %
    %   Any further arguments are relayed to the internal text command that
    %   prints the letters, e.g., cpsLabelPanels(...,'FontSize',14).
    %
        % EXAMPLES:
    %   % Standard
    %   subplot(2,2,1);
    %   subplot(2,2,2);
    %   subplot(2,2,[3 4]);
    %   cpsLabelPanels;
    %
    %   % Big bold font
    %   subplot(2,2,1);
    %   subplot(2,2,2);
    %   subplot(2,2,[3 4]);
    %   cpsLabelPanels([],[],'FontSize',14,'FontWeight','bold');
    %
    %   % Alternatively, set the properties afterwards
    %   subplot(2,2,1);
    %   subplot(2,2,[2 4]);
    %   subplot(2,2,3);
    %   h=cpsLabelPanels;
    %   set(h,'Color',[0 0 1],'FontSize',18)
    %
    %   % Explicit figure referencing, two methods
    %   h = findfig('Test2');
    %   subplot(2,1,1);
    %   subplot(2,1,2);
    %   if rand>.5
    %       cpsLabelPanels(h); % handle reference
    %   else
    %       cpsLabelPanels('Test2'); % title reference
    %   end
    %
    %   % Freestyle labels (albeit limited to 1 or no character)
    %   h = findfig('Test2');
    %   subplot(2,2,1);
    %   subplot(2,2,2);
    %   subplot(2,2,3);
    %   subplot(2,2,4);
    %   cpsLabelPanels(h,'A2 Z');
    %
    %   Part of <a href="matlab:cpsInfo">cpsPlotTools</a>.
    %
    %   See also: text, cpsFindFig
    
    %   Copyright 2016 Jacob Duijnhouwer
    
    
    % labelHandles=cpsLabelPanels(h,labels,varargin)
    %
    % DESCRIPTION:
    %   Provide labels A B C etc to the subplots in a figure.
    %   Optional argument H can be a handle to a figure, or a string representing the
    %   title of the figure. When omitted, the current figure window wil be used (gcf)
    %
    % EXAMPLES:
    %   % Standard
    %   subplot(2,2,1);
    %   subplot(2,2,2);
    %   subplot(2,2,[3 4]);
    %   cpsLabelPanels;
    %
    %   % Big bold font
    %   subplot(2,2,1);
    %   subplot(2,2,2);
    %   subplot(2,2,[3 4]);
    %   cpsLabelPanels([],[],'FontSize',14,'FontWeight','bold');
    %
    %   % Alternatively, set the properties afterwards
    %   subplot(2,2,1);
    %   subplot(2,2,[2 4]);
    %   subplot(2,2,3);
    %   h=cpsLabelPanels;
    %   set(h,'Color',[0 0 1],'FontSize',18)
    %
    %   % Explicit figure referencing, two methods
    %   h = findfig('Test2');
    %   subplot(2,1,1);
    %   subplot(2,1,2);
    %   if rand>.5
    %       cpsLabelPanels(h); % handle reference
    %   else
    %       cpsLabelPanels('Test2'); % title reference
    %   end
    %
    %   % Freestyle labels (albeit limited to 1 or no character)
    %   h = findfig('Test2');
    %   subplot(2,2,1);
    %   subplot(2,2,2);
    %   subplot(2,2,3);
    %   subplot(2,2,4);
    %   cpsLabelPanels(h,'A2 Z');
    %
    % AUTHOR:
    %   Jacob Duijnhouwer, 2015-12-10
    %
    % See also: text, findfig
    
    
    % Check that there are open figures
    if isempty(findobj(get(0,'children')))
        warning('There is no open figure.');
        return;
    end
    
    
    % Get the panels (axes-objects) to add labels to.
    if isempty(varargin{1})
        % Get all the panels (axes-objects) in the current figure
        ax=findobj(get(get(0,'currentFigure'),'Children'),'flat','Type','axes');
        varargin(1)=[];
    elseif isa(varargin{1},'matlab.graphics.axis.Axes')
        % Array of axes-objects
        ax=varargin{1};
        varargin(1)=[];
    elseif ischar(varargin{1})
        % maybe a tag to an open figure was used
        figh=cpsFindFig(varargin{1},'create',false);
        if ~isempty(figh)
            ax=get(figh,'Children');
        end
        varargin(1)=[];
    else
        % axis argument is ommited, default to all axes on the current figure
        ax=get(get(0,'currentFigure'),'Children');
    end
    %
    if isempty(ax)
        return
    end
    
    
    
    % parse the optional parameter in varargin that should not be piped to
    % text.m. The option will be removed from varargin, if the option
    % string occurs multiple times in varargin, only the first one is used
    % by cpsPanelLabel, the others are relayed to text
    labelPos='outside';
    if ~isempty(varargin)
        idx=strcmpi('inside',varargin{:});
        if ~isempty(idx)
            labelPos='inside';
            varargin(idx(1))=[]; % remove first 'inside' from the varargin list
        end
    end
    if ~isempty(varargin)
        if any(strcmpi('outside',varargin{:}))
            if strcmpi(labelPos,'inside');
                error('You defined both ''inside'' and ''outside''.');
            end
            labelPos=categorical({'outside'});
            varargin=varargin(~strcmpi('inside',varargin{:})); % remove the optipm
        end
    end
    
    if ~exist('h','var') || isempty(h)
        h=get(0,'currentfigure'); % gcf creates an empty figure if non exists, this is better
        if isempty(h)
            warning([ '[' mfilename '] No figure to find axes to label in']);
            return;
        end
    end
    if ischar(h)
        h=findfig(h,'create',false);
        if isempty(h)
            error(['Could not find figure with title ''' h '''.']);
        end
    end
    if ~isa(h,'matlab.ui.Figure')
        error('Unexpected error, not a figure??');
    end
    A=findobj(h,'Type','Axes');
    if isempty(A)
        warning([ '[' mfilename '] No axes to label']);
        return;
    end
    A=A(end:-1:1);
    if ~exist('labels','var') || isempty(labels)
        labels=char(64+(1:numel(A)));
    elseif numel(A)>numel(labels)
        warning('More panels than provided labels, appending whitespace to label array');
        labels=[labels repmat(' ',1,numel(A)-numel(labels))];
    elseif numel(A)<numel(labels)
        warning('Less panels than provided labels, ignoring superfluous labels');
        labels=labels(1:numel(A));
    elseif ~ischar(labels)
        error('labels should be char or empty');
    end
    wids=nans(size(A));
    for i=1:numel(A)
        if labels(i)==' ';
            continue;
        end
        oldUnits=A(i).Units;
        A(i).Units='pixels';
        wids(i)=A(i).Position(3);
        A(i).Units=oldUnits;
    end
    medianWid=nanmedian(wids); clear wids;
    labelHandles=[];
    for i=1:numel(A)
        if isnan(labels(i))
            continue;
        end
        axes(A(i)); %#ok<LAXES>
        oldUnits=A(i).Units;
        A(i).Units='pixels';
        wid=A(i).Position(3);
        A(i).Units=oldUnits;
        if strcmpi(labelPos,'outside')
            xPos=-0.1*medianWid/wid;
            yPos=1;
        else
            xPos=0.025*medianWid/wid;
            yPos=0.95;
            % warning('need to make hei also adaptive to different panel heights')
        end
        try
            t=text(xPos,1,labels(i),varargin{:},'Units','normalized');
        catch me
            try
                warning(me.message)
                t=text(xPos,1,labels(i),'Units','normalized');
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
            error(['Unknown label position option: ''' labelPos '''.']);
        end
        labelHandles(end+1)=t; %#ok<AGROW>
    end
end
