function cpsUnifyAxes(varargin)
    
    %plcUnifyAxes Unify axes of multiple (sub)plots
    %   plcUnifyAxes unifies the X, Y, Z, and C (color) axes of all
    %   subplots in the current figure.
    %
    %   plcUnifyAxes(AXSTR) unifies the axes defined in AXSTR, a string
    %   containing any or all of 'XYZC', of all subplots (Axes-objects) in
    %   the current figure.
    %
    %   plcUnifyAxes(AX,AXSTR), where AX is an array of Axes-object,
    %   unifies only the specified (sub)plots (which can be in multiple
    %   figures).
    %
    %   plcUnifyAxes([],AXSTR) scales the axes in the current figure,
    %   equivalent to plcUnifyAxes(AXSTR).
    %
    %   Examples:
    %      cpsFindFig('Fig1');
    %      subplot(1,2,1)
    %      imagesc(rand(10)); colorbar;
    %      subplot(1,2,2)
    %      imagesc(rand(10)*10); colorbar;
    %      cpsUnifyAxes('C');
    %
    %      h(1)=cpsFindFig('Fig2');
    %      plot(randn(100,1)*5,randn(100,1),'ro');
    %      h(2)=cpsFindFig('Fig3');
    %      plot(randn(100,1),randn(100,1)*10,'bo');
    %      cpsUnifyAxes(cpsGetAxes(h),'XY');
    %      cpsTileFigs;
    %
    %   Part of <a href="matlab:plcInfo">cpsPlotTools</a>.
    %
    %   See also: cpsGetAxes, cpsUnifyWithinAxes
    
    %   Copyright 2016 Jacob Duijnhouwer
    
    if numel(varargin)>2
        error('Too many input arguments');
    end

    % Note: 'Panel' is synonymoous with an 'Axes-object'
    
    % Get the Axes-object to scale one or more axes in
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
    
    % Now check AXSTR
    if numel(varargin)==1
        axStr=varargin{1};
    else
        axStr='XYZC';
    end
    if ~ischar(axStr)
        error('Second argument should be string containing any or all of ''XYZC''.');
    end
    if numel(axStr)~=numel(unique(upper(axStr)));
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
    
    % Collect the current axis-values
    for a=upper(axStr)
        s.(a)=[];
        for h=panels(:)'
            s.(a)=[ s.(a) get(h,[a 'lim']) ];
        end
    end
    % Set all axes to the the global minima and maxima
    for a=upper(axStr)
        set(panels,[a 'lim'],[min(s.(a)) max(s.(a))]);
    end
    %
    drawnow;
end
