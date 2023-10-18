function plotmap(emap,varargin)
    plot(vertcat(emap.grains.polygon),varargin{:});
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

