function h=cpsText(varargin)
    
    %cpsText Add text in standard locations
    %   This function is a wrapper around Matlab's built-in text to
    %   conveniently position text in standard locations. For example,
    %   cpsText(STR) prints the string STR in the top-left corner of the
    %   current Axes.
    %
    %   cpsText(AX,STR) prints STR in Axes-object (or array of
    %   Axes-objects) AX. If AX is empty or ommited, the current Axes are
    %   used.
    %
    %   STR may be a cell array of strings that will be printed on
    %   separate lines.
    %
    %   cpsText takes 3 comma separated parameter-value pairs:
    %       Parameter   Value:
    %       'Location'  Position of the text. Valid values are 'TopLeft'
    %                   (the default), 'TopRight', 'BottomLeft',
    %                   'BottomRight', 'Free', or 'Central'. The alignment
    %                   of the printed string itself is adjusted to
    %                   correspond to the chosen location.
    %       'dx'        Determines the horizontal offset from the specified
    %                   location in normalized units. For example, a value
    %                   of 0.02 (the default), and a 'topleft' location,
    %                   means that STR will be printed 0.02 x-axis lengths
    %                   to the right of the lefthand axis.
    %       'dy'        Like 'dx' but for the vertical direction.
    %
    %   All other parameters are relayed to matlab built-in text command.
    %
    %   H=cpsText(...) returns a handle to the created Text-object.
    %
    %   Part of <a href="matlab:help cpsPlotTools">cpsPlotTools</a>.
    %
    %   See also: text
    
    %   Copyright 2016 Jacob Duijnhouwer
    
    
    
    % We will need at least a STR to print...
    if nargin==0
        error('Not enough input arguments.');
    end
    
    % Get the Axes to print the text in
    if isempty(varargin) || ischar(varargin{1}) || iscell(varargin{1})
        % The 'what panels to draw in' arguments is omitted. The first
        % argument is the STR. Default to printing in the current open Axes
        AX=get(get(0,'CurrentFigure'),'CurrentAxes');
    elseif isempty(varargin{1})
        AX=get(get(0,'CurrentFigure'),'CurrentAxes');
        varargin(1)=[];
    elseif isa(varargin{1},'matlab.graphics.axis.Axes')
        % One or more (sub)plots explicitely defined.
        AX=varargin{1};
        varargin(1)=[];
    elseif ischar(varargin{1})
        % The 'what panels to draw in' arguments is omitted. The first
        % argument is the STR. Default to printing in the current open Axes
        AX=get(get(0,'CurrentFigure'),'CurrentAxes');
    else
        AX=get(get(0,'CurrentFigure'),'CurrentAxes');
    end
    
    % Get STR to print
    if numel(varargin)==0 || ~ischar(varargin{1}) && ~iscell(varargin{1})
        error('No string (or cell array of strings) to print');
    else
        STR=varargin{1};
        varargin(1)=[];
    end
    if ~iscell(STR)
        STR={STR};
    else
        if ~all(cellfun(@ischar,STR))
            error('Not all elements of cell array STR are strings');
        end
    end
    % Get the location to print
    validLocs={'TopLeft','TopRight','BottomLeft','BottomRight','Free','Central'};
    idx=find(strcmpi('Location',varargin));
    if ~isempty(idx)
        varargin(idx)=[];
        if numel(varargin)<idx
            error('Parameter ''Location'' has no value');
        elseif ~ischar(varargin{idx}) || ~any(strcmpi(varargin{idx},validLocs))
            error(['Invalid ''Location''. Valid values are:' sprintf(' ''%s''',validLocs{:}) '.'])
        else
            LOC=varargin{idx};
             varargin(idx)=[];
        end
    else
        LOC='topleft';
    end
    % Get the DX
    idx=find(strcmpi('DX',varargin));
    if ~isempty(idx)
        varargin(idx)=[];
        if numel(varargin)<idx
            error('Parameter ''dx'' has no value');
        elseif ~isnumeric(varargin{idx})
            error('Invalid ''dx''. Should be a number (typically between 0 and 1).')
        else
            DX=varargin{idx};
            varargin(idx)=[];
        end
    else
        DX=0.02;
    end
    % Get the DY
    idx=find(strcmpi('DY',varargin));
    if ~isempty(idx)
        varargin(idx)=[];
        if numel(varargin)<idx
            error('Parameter ''dy'' has no value');
        elseif ~isnumeric(varargin{idx})
            error('Invalid ''dy''. Should be a number (typically between 0 and 1).')
        else
            DY=varargin{idx};
            varargin(idx)=[];
        end
    else
        DY=0.02;
    end
    
    for ai=1:numel(AX)
        if strcmpi(get(gca,{'XDir'}),'reverse')
            DX=-DX+1;
        end
        if strcmpi(get(gca,{'YDir'}),'reverse')
            DY=-DY+1;
        end
        switch lower(LOC)
            case 'topleft'
                DY=1-DY;
                hAlign='left';
                vAlign='top';
            case 'topright'
                DX=1-DX;
                DY=1-DY;
                hAlign='right';
                vAlign='top';
            case 'bottomleft'
                hAlign='left';
                vAlign='bottom';
            case 'bottomright'
                DX=1-DX;
                hAlign='right';
                vAlign='bottom';
            case 'free'
                hAlign='center';
                vAlign='middle';
            case 'central'
                DX=0.5;
                DY=0.5;
                hAlign='center';
                vAlign='middle';
            otherwise
                error(['[' mfilename '] Unknown location option: ' LOC ]);
        end
        if strcmpi(get(AX(ai),{'XDir'}),'reverse')
            if strcmpi(hAlign,'left')
                hAlign='right';
            else
                hAlign='left';
            end
        end
        if strcmpi(get(AX(ai),{'YDir'}),'reverse')
            if strcmpi(vAlign,'top')
                vAlign='bottom';
            else
                vAlign='top';
            end
        end
        
        % Print the text
        h=text(DX,DY,STR...
            ,'VerticalAlignment',vAlign,'HorizontalAlignment',hAlign ...
            ,varargin{:},'Units','Normalized');
    end
end
