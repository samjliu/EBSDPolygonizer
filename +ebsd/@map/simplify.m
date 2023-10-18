function simplify(emap,smoothspan, tol,numpasses,tolincr)
    if nargin == 2
        numpasses = 5;
        tolincr = 10;
    elseif nargin == 3
        tolincr = 10;
    end
    n0 = emap.Nvertices;
    disp(['Number of vertices: ', num2str(n0)]);
    for i = 1:numpasses
        ns = emap.Nvertices;
        emap.smoothgb({smoothspan});
        emap.downsize(tol);
        nf = emap.Nvertices;
        frac = 100*(nf-ns)/n0;
        disp(['Number of vertices: ', num2str(nf), '; reduced by ', num2str(frac), '%']); 
        tol = tol+tolincr;
    end
end