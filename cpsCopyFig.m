function h = cpsCopyFig(f1,f2)
    
    narginchk(1,2);

    % Get/check the handle to the source figure window
    if ischar(f1)
        h1 = cpsFindFig(f1,'create',false);
        if isempty(h1)
            error(['No source figure named ''' f1 ''' found.']);
        end
    elseif isa(f1,'matlab.ui.Figure')
        h1 = f1;
    else
        error('First argument should be the name of a Figure or a figure handle (matlab.ui.Figure).');
    end
    % Get/check/create the handle to the target figure window
    if ~exist('f2','var')
        f2 = [h1.Name ' - Copy'];
    end
    if ischar(f2)
        h2 = cpsFindFig(f2,'create',true);
        clf;
        if isempty(h2)
            error(['Could not create target Figure ''' f2 '''.']);
        end
    elseif isa(f2,'matlab.ui.Figure')
        h2 = f2;
        clf(h2);
    end
    % Copy the contents of the source to the target
    copyobj(get(h1,'children'),h2);
        
end