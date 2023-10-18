function downsize(emap,tol)
    % Remove collinear vertices within the tolerance of TOL
%             set(emap.verticesbank, 'protected', false);
    grs = emap.grains;
    allpoly = vertcat(grs.polygon);
    areas = vertcat(allpoly.area);
    [sortgrs, I] = sort(areas, 'descend');
    h = waitbar(0, 'Downsizing the vertices...');
    for i = 1:length(sortgrs)
        gr = grs(I(i));
        gr.verticemembers(~isvalid(gr.verticemembers)) =[];
        vcs = gr.activeVertices;
        [gone, ~] = ebsd.map.removeCollinear(vcs,tol);
        vcmembers = gr.verticemembers;
        activemembers = vcmembers(vertcat(vcmembers.active));
        numactive = numel(activemembers);
        ind2go = find(gone & (~vertcat(activemembers.isnode) & ~vertcat(activemembers.isedge)));
        if numactive - numel(ind2go)>=4
            set(activemembers(ind2go), 'active', false);
        else
            if emap.warningDownSize
                warning(['Abort for grains ', num2str(gr.ID), ' as it would have less than 3 vertices if continue.'])
            end
        end
%                 grs(i).verticemembers(gone) = [];
        waitbar(i/emap.numgrains, h, ['Downsizing vertices of grain ', num2str(i)])
    end

    delete(h)
end