function h = plotvertices(emap,varargin)
    vcs = vertcat(emap.grains.activeVertices);
    h = scatter(vcs(:,1), vcs(:,2), 3);
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