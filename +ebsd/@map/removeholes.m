function removeholes(emap, doublecheck)
    % REMOVEHOLES get ride of the dead pixels that are not indexed
    % in the original ebsd map. 
    %
    if nargin < 2
        doublecheck = false;
    end
    if ~emap.noholes || doublecheck
        h1 = waitbar(0, 'Please wait...searching holes');
        u = union(emap.polygons);
        holes = u.holes;
        waitbar(0.01, h1, [num2str(length(holes)), ' holes found'])
        bufferholes = polybuffer(holes,1,'JointType', 'Miter');
        allpoly = vertcat(emap.grains.polygon);
        waitbar(0.02, h1, 'Processing holes...');
        for i = 1:length(bufferholes)
            inds_nbgrains = overlaps(bufferholes(i), allpoly);
            inds_grains = find(inds_nbgrains);
            nbgrains = emap.grains(inds_nbgrains);
            if ~isempty(nbgrains)
                nbpolygons = vertcat(nbgrains.polygon);
                nbpolyconv = nbpolygons.convhull;
                area_original = vertcat(nbpolyconv.area);       
                trialpoly = repmat(polyshape,size(nbgrains));
                for j = 1:length(nbgrains)
                    trialpoly(j) = union(holes(i), nbpolygons(j));
                end
                trialpolyconv = trialpoly.convhull;
                area_trial = vertcat(trialpolyconv.area);
                strangeness = area_trial - area_original;
                [~, minstrange] = min(strangeness);
                ind_eatergrain = inds_grains(minstrange);
                emap.grains(ind_eatergrain).vertices = trialpoly(minstrange).Vertices;
                waitbar(i/length(bufferholes), h1, ['Processing the hole ', num2str(i), '...'])
            end
        end
        delete(h1)
        emap.noholes = true;
    else
        disp('The map is free of holes. Do not worry')
    end
end
        