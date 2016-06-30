function cpsDemo
    
    % Create some dummy data to plot ...
    someData = mvnrnd([0;0], [1 .9;.9 1], 100);
    x = someData(:,1);
    y = someData(:,2);
    % Open a figure window with the function name and clear it if necessary
    for t = {'before','after'}
        cpsFindFig(['cpsDemo - ' t{1}]);
        % Create 42 subplots with some dummy data in m
        subplot(2,2,1);
        plot(x,y,'o');
        subplot(2,2,2);
        plot(x*2,y,'o');
        h=subplot(2,2,3);
        plot(x,y*2,'o');
        xlabel('X (a.u.)','FontSize',12);
        ylabel('Y (a.u.)','FontSize',12);
        subplot(2,2,4);
        plot(x*2,y*2,'o');
    end

    % Unify the axis, between and within panels
    cpsUnifyAxes
    % Add reference axes
  	cpsRefLine(gcf,'+','/','k--');
    % Add label
    cpsLabelPanels;
    % Tile the before and after figures
    cpsTileFigs
end
    