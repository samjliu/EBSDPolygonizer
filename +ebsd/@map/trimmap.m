function trimmap(emap,left, bottom, right, top)
    if isempty(emap.rightedge)
        emap.rightedge = emap.leftedge + emap.width;
    end
    if isempty(emap.topedge)
        emap.topedge = emap.bottomedge + emap.height;
    end
    emap.cropmap(emap.leftedge+left, emap.rightedge-right, emap.bottomedge + bottom, emap.topedge - top);
end