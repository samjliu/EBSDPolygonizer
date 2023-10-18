function vargout = plotneighbours(emap,grain)
        vargout{1}= plot(grain);
    hold on
    nb = emap.grains(ismember(vertcat(emap.grains.ID), grain.neighbours));
    vargout{2}= plot(nb);
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