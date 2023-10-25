function overlayGrainLabels(emap,ax)
    % Add grain labels on top of the plot
    holdornot=ax.NextPlot; % Original state
    hold(ax,"on");
    polys = vertcat(emap.grains.polygon);
    IDs = vertcat(emap.grains.ID);
    [x,y] = polys.centroid;
    text(ax, x,y, num2str(IDs));
    ax.NextPlot = holdornot;
end