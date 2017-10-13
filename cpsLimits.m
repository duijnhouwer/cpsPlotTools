function lims=cpsLimits(varargin)

    %cpsLimits  Selectively set axis limits
    %   cpsLimits(L) set the limits of the current Axes to the values in L,
    %   similar to using builtin axis(L) but with the added functionality
    %   to selectively maintain current limits by passing NaN values in L.
    %
    %   L can not have more elements than there are limits (2x the number
    %   of dimensions of Axes). When L has fewer elements, it's righthand
    %   padded with NaNs.
    %
    %   cpsLimits(H,L) sets the limits of Axis-object H.
    %
    %   Example:
    %       hist(randn(1000,1));
    %       cpsLimits([-5 5]);
    %
    %   Part of <a href="matlab:help cpsPlotTools">cpsPlotTools</a>.
    %
    %   See also: axis
    
    narginchk(0,2);
    lims = axis;
    if nargin>0
        if isa(varargin{1},'matlab.graphics.axis.Axes')
            h = varargin{1};
            varargin(1)=[];
        else
            h = gca;
        end
        newLims = varargin{1};
        if ~isnumeric(newLims)
            error('Axes limits should be a numeric vector');
        end
        if numel(newLims)>numel(lims)
            error(['Too many limits (' num2str(numel(newLims)) ') for current ' num2str(numel(lims)/2) 'D-Axes.']);
        end
        idx = find(~isnan(newLims));
        lims(idx) = newLims(idx); % copy the non-nan values into lims
        axis(lims); % set the limits 
    end
end
