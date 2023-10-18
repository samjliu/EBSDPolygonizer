function cropmap(emap,xmin, xmax, ymin, ymax)
    %
    p1 = [xmin, ymin];
    p2 = [xmax, ymin];
    p3 = [xmax, ymax]; 
    p4 = [xmin, ymax];
    aoi = polyshape(vertcat(p1,p2,p3,p4,p1));
    emap.width = abs(xmax - xmin);
    emap.height = abs(ymax - ymin);
    emap.leftedge = xmin;
    emap.rightedge = xmax;
    emap.topedge = ymax;
    emap.bottomedge = ymin;
    allpoly = vertcat(emap.grains.polygon);
    newpolys = allpoly;
    h = waitbar(0, 'Cropping the map...');
    for i = 1:length(allpoly)
        [newpolys(i), shapeID, vcID] = intersect(allpoly(i), aoi);
        if ~isequal(newpolys(i), allpoly(i))
            if newpolys(i).NumRegions > 0
                emap.grains(i).iscropped = true;
                emap.grains(i).isedge = true;
                emap.grains(i).vertices = newpolys(i).Vertices;
                vcs = emap.grains(i).verticemembers;
                emap.grains(i).verticemembers = repmat(ebsd.gbvc(0,0),size(emap.grains(i).vertices,1),1);
                for j = 1:size(emap.grains(i).vertices,1)
                    if shapeID(j) == 1
                        emap.grains(i).verticemembers(j) = vcs(vcID(j));
                    else
                        v = ebsd.gbvc(emap.grains(i).vertices(j,1), emap.grains(i).vertices(j,2));
                        v.isedge = true;
                        emap.grains(i).verticemembers(j) = v;
                        emap.verticesbank = vertcat(emap.verticesbank, v);
                    end
                end
            else
                emap.grains(i).isactive = false;
            end
        end
        waitbar(i/length(allpoly), h, 'Cropping the map...')
    end
    waitbar(1,h, 'Cropped!');
%             emap.grains(vertcat(newpolys.NumRegions) == 0) = [];
    allvcs = vertcat(emap.verticesbank.vertice);
    vc2remove = allvcs(:,1) < emap.leftedge | allvcs(:,1) > emap.rightedge | allvcs(:,2) < emap.bottomedge | allvcs(:,2) > emap.topedge; 
    set(emap.verticesbank(vc2remove),'active', false);
    delete(h)

    active = vertcat(emap.grains.isactive);
    activeInds = find(active);
    inactiveID = vertcat(emap.grains(~active).ID);
    h2 = waitbar(0, 'Updating the neighbours of remaining grains...');
    for i = 1:activeInds
        nbsID = emap.grains(activeInds(i)).neighbours;
        nbsID(ismember(nbsID, inactiveID)) = [];
        emap.grains(activeInds(i)).neighbours = nbsID; 
        waitbar(i/length(activeInds), h2, 'Updating the neighbours of remaining grains...')
    end
    waitbar(1, h2, 'All done!')
    delete(h2)
    emap.iscropped = true;

end