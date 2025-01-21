function cpsUnifyAxes(varargin)
    %cpsUnifyAxes Unify axes limits within or between (sub)plots
    %   cpsUnifyAxes unifies the limits of the X, Y, Z, and C (color) axes
    %   of all Axes-objects, i.e., (sub)plots, in the current figure.
    %
    %   cpsUnifyAxes(AXSTR) unifies the axes defined in AXSTR, a
    %   string containing any or all of 'XYZC', of all subplots
    %   (Axes-objects) in the current figure.
    %
    %   cpsUnifyAxes(AX,AXSTR), where AX is an array of Axes-objects,
    %   unifies only the specified axes (which can be in multiple
    %   figure windows).
    %
    %   cpsUnifyAxes([],AXSTR) is equivalent to cpsUnifyAxes(AXSTR).
    %
    %   cpsUnifyAxes(...,'between') unifies the corresponding axes between
    %   all Axes-object the funtion is operating on. For example: 
    %       subplot(1,2,1)
    %       plot(randn(100,1));
    %       subplot(1,2,2)
    %       imagesc(randn(1000,1)*10);
    %       cpsUnifyAxes('Y','between');
    %   unifies the Y-axes between the two subplots.
    %
    %   cpsUnifyAxes(AXSTR,'within') unifies the axes indicated in
    %   AXSTR. For example:
    %       plot(randn(100,1),randn(100,1)*10,'o')
    %       cpsUnifyAxes('XY','within');
    %   sets the limits of the x and y axes to their combined maximums. 
    %
    %   When the 'within' and 'between' options are both not provided, 
    %   cpsUnifyAxes defaults to 'within' when there is only one panel to
    %   operate on, 'between' otherwise.
    %
    %   When the 'within' option is provided, the 'between' default is
    %   overridden. However, both options can be used at the same time. For
    %   example:
    %       subplot(2,1,1)
    %       plot(randn(100,1),randn(100,1)*2,'o');
    %       subplot(2,1,2)
    %       plot(randn(100,1)*10,randn(100,1)*20,'o');
    %       cpsUnifyAxes('within','between'); 
    %
    %   Additional example 1. Unify the color limits of images:
    %       cpsFindFig('Fig1');
    %       subplot(1,2,1)
    %       imagesc(rand(10)); colorbar;
    %       subplot(1,2,2)
    %       imagesc(rand(10)*10); colorbar;
    %       cpsUnifyAxes('C');
    %
    %   Additional example 2. Unify axes in multiple figures:
    %       h(1)=cpsFindFig('Fig2');
    %       plot(randn(100,1)*5,randn(100,1),'ro');
    %       h(2)=cpsFindFig('Fig3');
    %       plot(randn(100,1),randn(100,1)*10,'bo');
    %       cpsUnifyAxes(h,'XY');
    %       cpsTileFigs;
    %
    %   Part of <a href="matlab:help cpsPlotTools">cpsPlotTools</a>.
    %
    %   See also: cpsGetAxes
    
    %   Copyright 2016 Jacob Duijnhouwer
    
    narginchk(0,4)
    % Note: in the comments, 'Panel' is synonymoous with an 'Axes-object'
    % Get the panels to scale one or more axes in
    if isempty(varargin) ||  ischar(varargin{1})
        % No arguments provided, or the first argument is the AXSTR.
        % Default to all axes current figure
        panels=cpsGetAxes('currentFigure');    
    elseif isempty(varargin{1})
        % Get all the panels (axes-objects) in the current figure
        panels=cpsGetAxes('currentFigure');
        varargin(1)=[];
    elseif isa(varargin{1},'matlab.graphics.axis.Axes')
        % A panel or an array of panels
        panels=varargin{1};
        varargin(1)=[];
    elseif isa(varargin{1},'matlab.ui.Figure')
        % A figure or an array of figures, get all their Axes children 
        panels=[];
        for i=1:numel(varargin{1})
            panels=[panels cpsGetAxes(varargin{1}(i))]; %#ok<AGROW>
        end
        varargin(1)=[];     
    else
        error('Incorrect arguments, unexpected error');
    end
    
    if numel(panels)<=1
        % nothing to unify
        return;
    end
        
    
    % Check if the within and between arguments have been provided
    between = false;
    within = false;
    if any(strcmpi(varargin,'within'))
        within = true;
        varargin(strcmpi(varargin,'within')) = [];
    end
    if any(strcmpi(varargin,'between'))
        between = true;
        varargin(strcmpi(varargin,'between')) = [];
    end
    if ~between && ~within
        % if between and within are both unspecified, use within if there
        % is only one panel to operate on, between otherwise
        if isscalar(panels)
            within = true;
        else
            between = true;
        end
    end
    
    % Finally check AXSTR, if it is provided this should be the only
    % remaining argument, if there are no arguments left use the default.
    % if there are more than 1 argument left, issue an error. Could be that
    % "within" was misspelled for example.
    if numel(varargin)>1
        error('Incorrect argument(s).');
    elseif isscalar(varargin)
        axStr=varargin{1};
    else
        axStr='XYZC';
    end
    if ~ischar(axStr)
        error('Second argument should be string containing any or all of ''XYZC''.');
    end
    if numel(axStr)~=numel(unique(upper(axStr)))
        warning(['Second argument (''' axStr ''') contains one or more duplicates.']);
        axStr=unique(axStr);
    end
    ok=true(size(axStr));
    for i=1:numel(axStr)
        ok(i)=ismember(upper(axStr(i)),'XYZC');
    end
    if any(not(ok))
        error(['Second argument (''' axStr ''') contains illegal characters: ''' axStr(~ok) '''.']);
    end
     
    if between
        % scale between Axes-panels
        % Collect the current axis-values of all the selected axes
        for A=upper(axStr) % e.g. X, Y, Z, C
            s.(A) = [];
            for h = panels(:)'
                s.(A) = [ s.(A) get(h,[A 'lim']) ];
            end
        end
        % Set all axes to the the global minima and maxima of that
        % particular kind of axis across the Axes-panels
        for A = upper(axStr)
            set(panels,[A 'lim'],[min(s.(A)) max(s.(A))]);
        end
    end
    if within
        % Scale within Axes-panels. E.g. the X and Y axis will get the same
        % limits.
        for h=panels(:)'
            los = [];
            his = [];
            for A = upper(axStr) % e.g. X, Y, Z, C
                los = [los min(get(h,[A 'lim']))];
                his = [his max(get(h,[A 'lim']))];
            end
            for A = upper(axStr)
                set(h,[A 'lim'],[min(los) max(his)]);
            end
        end
    end
    drawnow;
end
