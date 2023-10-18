function polygonize(eg,pixels,ebsdpara)
    h = waitbar(0,'Polygonizing the pixel data');
%     hg = waitbar(0, 'Creating cell for grains...');
    for i = 1:length(eg)
        [grpixelsx, grpixelsy] = pixels.buildcells(ebsdpara,eg(i).pixelInds);
        poly = polyshape(grpixelsx, grpixelsy, 'Simplify',false);
        poly = poly.simplify;
        nholes = poly.NumHoles;
        if nholes
            poly = poly.rmholes;
            disp([num2str(nholes), ' holes removed from grain ', num2str(eg(i).ID)]);
        end
        
        eg(i).vertices = poly.Vertices;
        waitbar(i/length(eg), h, [num2str(length(eg)-i-1), ' grains to be polygonized']);
    end
%     delete(hg);
    disp([num2str(length(eg)), ' grains were polygonized']);
    delete(h)
end