function plotWithGrainLabels(emap,varargin)
    polys = vertcat(emap.grains.polygon);
    h = plot(polys,varargin{:});
    IDs = vertcat(emap.grains.ID);
    [x,y] = polys.centroid;
    text(x,y, num2str(IDs));
    xlabel('\mum')
    ylabel('\mum')
    box off
    xlim([emap.leftedge, emap.rightedge]);
    ylim([emap.bottomedge, emap.topedge]);
    hold on
    daspect([1 1 1]);
    pbaspect([1 1 1]);
    hold off
end