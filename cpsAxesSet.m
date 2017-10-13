function cpsAxesSet(varargin)
    
    %cpsAxesSet    
    
    % Check that there are open figures
    if isempty(findobj(get(0,'children')))
        warning('No figure to label.');
        return;
    end
    
    
    % Get the panels (axes-objects) to add labels to.
    if isempty(varargin{1})
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
    
    if numel(varargin)==0
        error('No property-value pair list provided.');
    elseif mod(numel(varargin),2)==1
        error('Invalid property-value pair list, odd number.');
    end
    
    
    for i=1:2:numel(varargin)
        for a=1:numel(ax)
            if isprop(ax(1),varargin{i})
                set(ax(a),varargin{i},varargin{i+1});
            else
                error(['Invalid property: ' varargin{i}]);
            end
        end
    end
end
