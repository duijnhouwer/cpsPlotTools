function [LEGH,OBJH,OUTH,OUTM] = cpsStructLegend(ax,S,spaceCode)
    
    % EXAMPLE 1:
    %   h.House=plot(rand(10,1));
    %   hold on;
    %   h.Face=plot(rand(10,1));
    %   lh=cpsStructLegend(gca,h)
    %   lh.FontSize=12;
    %
    % EXAMPLE 2:
    %   h.my_house=plot(rand(10,1));
    %   hold on;
    %   h.my_face=plot(rand(10,1));
    %   lh=cpsStructLegend(h,'_')
    %   lh.FontSize=12;
    
    % handle the optionality of the first argument
    if nargin==1
        S=ax;
        ax=gca;
        spaceCode='';
    elseif nargin==2
        if ~isa(ax,'matlab.graphics.axis.Axes')
            spaceCode=S;
            S=ax;
            ax=gca;
        else
            spaceCode='';
        end
    elseif nargin==3
        if isempty(spaceCode)
            spaceCode=''; % make sure it's empty of the char kind
        end
    end
    
    % check the inputs
    if ~isa(ax,'matlab.graphics.axis.Axes')
        error('ax should be a matlab.graphics.axis.Axes');
    end
    if ~isstruct(S)
        error('S should be struct');
    end
    if ~ischar(spaceCode)
        error('spaceCode should be char');
    end
    
    labels=fieldnames(S);
    handles=nan(size(labels));
    for i=1:numel(labels)
        if ~isempty(S.(labels{i}))
            handles(i)=S.(labels{i});
        end
        % replace space code with whitespace. if spaceCode=='' nothing happens
        labels(i)=strrep(labels(i),spaceCode,' ');
    end
    notthere=isnan(handles);
    handles(notthere)=[];
    labels(notthere)=[];
    [LEGH,OBJH,OUTH,OUTM] = legend(ax,handles,labels);
    
end
        
