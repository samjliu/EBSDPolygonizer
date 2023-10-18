function h = plotgb(emap,varargin)
    hold on
    for i = 1:length(emap.grains)
        gr = emap.grains(i);
        v = gr.activeVertices;
        h=plot(v(:,1), v(:,2),varargin{:});
    end
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