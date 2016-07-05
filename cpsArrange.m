function cpsArrange(h,opt)
    
    %cpsArrange Rearrange the occlusion in the current Axes
    %   cpsArrange(H,'back') rearranges graphics object H so that it's
    %   behind all the other graphics objects in the current Axes.
    %
    %   cpsArrange(H,'front') sends it to the front.
    %
    %   When H is an array of graphics objects, the first element will be
    %   the frontmost (backmost) object followed by the rest if the option
    %   is 'front' ('back').
    %
    %   Example:
    %      patch([0 1 1 0],[1 0 1 2],'b');
    %      hold on;
    %      h = plot([0 1],[0 2],'r','LineWidth',10);
    %      for i = 1:5
    %         cpsArrange(h,'back');
    %         pause(1);
    %         cpsArrange(h,'front');
    %         pause(1);
    %      end
    %
    %   Part of <a href="matlab:cpsPlotTools">cpsPlotTools</a>.
    
    narginchk(2,2)
    if ~isgraphics(h)
        error('h must be a graphics handle');
    end
    if ~any(strcmpi(opt,{'front','back'}))
        error('Arrange option should be ''front'' or ''back''.');
    end 
    kids = get(gca,'Children');
    
    for hi = numel(h):-1:1
        % reverse iterate so the first element is the 'opt'-most
        thisH = h(hi); 
        if ~any(kids==thisH)
            error('Provided Graphics handle is not in the current axis');
        end
        if strcmpi(opt,'front')
            set(gca,'Children',[kids(kids==thisH); kids(kids~=thisH)]);
        elseif strcmpi(opt,'back')
            set(gca,'Children',[kids(kids~=thisH); kids(kids==thisH)]);
        else
            error(['unknown option: ' opt]);
        end
    end
    
end