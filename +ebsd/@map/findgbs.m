function findgbs(emap)
    % find grain boundaries between all grains of the map
    grs = emap.grains;
    grsID = vertcat(grs.ID);
    emap.gbs = ebsd.gb.empty;
    msgst = 'Start searching grain boundaries...';
    h = waitbar(0, msgst);
    disp(msgst)
    for i = 1:length(grs)
        gri = grs(i);
        if ~isempty(gri.neighbours)
            grigbs(length(gri.neighbours),1)= ebsd.gb;
            checknbs = ismember(grsID, gri.neighbours);
            checknbs(1:i) = false;   
            nbs = grs(checknbs);
            nbsind = grsID(checknbs); % find the neighbour grain inds
            I = find(ismember(gri.neighbours, nbsind));
            if ~isempty(nbs)
                for j = 1:length(nbs)
                    grj = nbs(j);
                    gb = ebsd.gb(gri, grj);
                    grigbs(I(j)) = gb;
                    emap.gbs = vertcat(emap.gbs, gb);
                end
            end
            progress = i/length(grs);
            report = ['Checking grain ', num2str(i)];
            waitbar(progress, h, report);
        end
    end
    delete(h)
end