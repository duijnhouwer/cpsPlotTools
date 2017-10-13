function [h,r,p]=cpsPlotCorr(x,y,varargin)
    
    if ~isempty(varargin)
        plotopts=varargin{:};
    else
        plotopts='.';
    end 
    h.markers=plot(x,y,plotopts);
    h.line=refline;
    set(h.line,'Color','k');
    [r,p]=corrcoef(x,y);
    r=r(2);
    p=p(2);
    h.text=cpsText(['r = ' num2str(r,'%.3f') '(p = ' num2str(p,'%.3f')]);
end
    