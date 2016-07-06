function figs=cpsTileFigs(figs)
    %cpsTileFigs Tile all open figure windows on the screen
    %   cpsTileFigs places all open figure windows around on the screen with no
    %   overlap.
    %
    %   This function is based on 'tilefigs' by Peter J. Acklam (2003).
    %
    %   Part of <a href="matlab:help cpsPlotTools">cpsPlotTools</a>.
    %    
    %   Copyright 2003 Peter J. Acklam, 2016 Jacob Duijnhouwer

    if nargin==0
        figs = findobj('Type', 'Figure');	% ...find all figures.
        figs = sort(figs);
    end
    if isempty(figs)
        disp('No open figures or no figures specified.');
        return
    end

    horSpc = 0.00; % Horizontal space.
    topSpc = 0.00; % Space above top figure.
    verSpc = 0.00; % Space between figures.
    botSpc = 0.05; % Space below bottom figure.
    
    units  = 'normalized';
    
    % Set miscellaneous parameter
    nFigs = numel(figs);
    nHor = ceil(sqrt(nFigs));
    nVer = ceil(nFigs/nHor);
    
    % Get the screen size.
    oldRootUnits = get(0,'Units');
    set(0,'Units',units);
    scrdim = get(0,'ScreenSize');
    set(0,'Units',oldRootUnits);
    scrWid = scrdim(3);
    scrHei = scrdim(4);
    
    figWid = (scrWid-(nHor+1)*horSpc)/nHor;
    figHei = (scrHei-(topSpc+botSpc)-(nVer-1)*verSpc)/nVer;
    
    % Put the figures where they belong.
    for row = 1:nVer
        for col = 1:nHor
            idx = (row-1)*nHor+col;
            if idx<=nFigs
                figLft = col*horSpc+(col-1)*figWid;
                figBot = scrHei-topSpc-row*figHei-(row-1)*verSpc;
                figPos = [figLft figBot figWid figHei];
                oldFigUnits = get(figs(idx),'Units');
                set(figs(idx),'Units',units);
                set(figs(idx),'OuterPosition',figPos);
                set(figs(idx),'Units',oldFigUnits);
                figure(figs(idx)); % Raise figure.
            end
        end
    end
end
