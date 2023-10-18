function findEdgeVertices(emap,tol)
    if isempty(emap.rightedge)
        emap.rightedge = emap.leftedge + emap.width;
    end

    if isempty(emap.topedge)
        emap.topedge = emap.bottomedge + emap.height;
    end
    
    if nargin<2
        
        tol = 0.1*emap.stepsize;
    end

    if ~isempty(emap.verticesbank)
        vccor = vertcat(emap.verticesbank.vertice);
        x = vccor(:,1);
        y = vccor(:,2);
        set(emap.verticesbank(abs(x - emap.leftedge)<=tol | abs(y - emap.bottomedge)<=tol | abs(x - emap.rightedge)<=tol | abs(y - emap.topedge)<=tol),'isedge',true);
    end
end