classdef map<handle
    % Top-level class of the EBSD package
    % Main functions include:
    %   ** importebsdmap --- import the EBSD data from EBSD data files
    %   ** smoothgb --- smooth grain boundaries
    %   ** simplify --- repeatedly smooth grain boundaries and reduce the
    %   number of vertices on boundaries while trying to minimise the
    %   changes to the original grain shape
    %   *** PLOTTING function
    %   ** plotmap --- plot the polygons
    %   ** plotneighbours --- plot a selected grains and all its neighbours
    %   with grain number lables
    %   ** plotvertices --- plot all the vertices only 
    %   ** plotgb --- plot all the grain boundaries only
    
    properties
        grains = ebsd.grain.empty      % a vector of grain objects
        width       % width of the map in um
        height      % height of the map in um
        mapsize     % size including width and height
        area        % total area of the map
        numgrains   % number of the grains
        diammean    % mean grain diameter
        diamstd     % standard deviation of the grain diameters
        diamste     % standard error of the grain diameters
        aream       % mean area of the grains
        areastd     % standard deviation of the grain area
        areaste     % standard deviation of the grain area
        polygons    % an ebsd map including all the grain polygons
        verticesbank    % A bank of all the current gbvc vertices
        noholes = false;
        leftedge = 0
        rightedge
        topedge 
        bottomedge = 0
        iscropped = false
        gbs
        stepsize
        Nvertices
        
        pixels
        numXCells  % number of rows of the pixels
        numYCells  % number of columns of the pixels
        ebsdInfoTable  % the table containing EBSD parameters imported from CRC file
        warningDownSize = false;
        
        tolvc = 1e-6   % tolerance for vertice coincidence check
        tolOnBoundary   
        tolInBetween
        tolMissVertice
        tolDownSize
        
        CS1toCS0    % Transform requsition coordinate system (x-y-z) to the specimen requsition system (RD-TD-ND). 
                    % Euler angle in degree. These angles are exported from
                    % the Channel 5 project file
    end
    
    methods
        function emap = map(ebsdgrains)
            % Construction method
            if nargin > 0 
                emap.grains = ebsdgrains;
                emap.numgrains = numel(emap.grains);
                if ~emap.noholes
                    emap.removeholes;
                end
                emap.gbs = ebsd.gb.empty;
                allvcs = uniquetol(vertcat(emap.grains.vertices), emap.tolvc, 'ByRows', true, 'DataScale',1);
                vcIDs = 1:length(allvcs);
                emap.verticesbank = ebsd.gbvc.batchCreate(allvcs(:,1),allvcs(:,2),vcIDs);
                h1 = waitbar(0, 'Assign verticemembers to grains...');
                for i = 1:length(emap.grains)
                    [~, inds_in_bank]  = ismembertol(emap.grains(i).vertices, allvcs, emap.tolvc, 'ByRows', true, 'DataScale',1);
                    inds_in_bank = inds_in_bank(inds_in_bank>0);
                    emap.grains(i).verticemembers = emap.verticesbank(inds_in_bank);
                    set(emap.grains(i).verticemembers, 'ofgrains',  emap.grains(i).ID);
                    waitbar(i/length(emap.grains), h1, ['Assigning vertice members...',num2str(i), ' grains out of ', num2str(length(emap.grains))]);
                end
                disp(['Assigned vertices to ', num2str(emap.numgrains), 'grains.'])
                delete(h1);
                allpoly = vertcat(emap.grains.polygon);
                emap.polygons = allpoly;
                
                diam = vertcat(emap.grains.diam);
                area = vertcat(emap.grains.area);
                emap.numgrains = length(emap.grains);
                emap.diammean = mean(diam);
                emap.diamstd = std(diam);
                emap.diamste = std(diam,1)./sqrt(emap.numgrains);
                emap.aream = mean(area);
                emap.areastd = std(area);
                emap.areaste = std(area,1)./sqrt(emap.numgrains);
                emap.area = sum(area);
                disp('Checking the map bounding box...')
                combined = union(allpoly);
                [xlim, ylim] = combined.boundingbox;
                if ~isempty(xlim) && ~isempty(ylim)
                    emap.width = abs(xlim(2)-xlim(1));
                    emap.height = abs(ylim(2) - ylim(1));
                end
                disp('Map created from ebsd.grains!')
            end
        end
        
        function c = duplicate(emap)
            c = copy(emap);
            c.grains = copy(emap.grains);
            c.gbs = copy(emap.gbs);
            c.verticesbank = copy(emap.verticesbank);
        end
        
        function v = get.Nvertices(emap)
            % Get the number of active vertices
            vcs = emap.verticesbank;       
            if ~isempty(vcs)
                vcs = vcs(vertcat(vcs.active));
                v = numel(vcs);
            else
                v = 0;
            end
        end
        
        function grains = get.grains(emap)
            % Get the number of active grains
            if ~isempty(emap.grains)
                if emap.iscropped
                    grains = emap.grains(vertcat(emap.grains.isactive));
                else
                    grains = emap.grains;
                end
            end
        end
 
        function value = get.numgrains(emap)
            if ~isempty(emap.grains)
                value = numel(emap.grains);
            end
        end
   
        function f = get.mapsize(emap)
            f = [emap.width, emap.height];
        end
        
        function f = get.polygons(emap)
            f = vertcat(emap.grains.polygon);
        end
    end
    
    methods(Static)
        [onInVq,locInVcs,members] = isonboundary(vcs,vq,tolerance)
        tf = isInBetween(pa, pb, pq, tolerance)
        [gone, verticesremained] = removeCollinear(vcs,tol)
        f = euler2matrix(phi1,phi,phi2,unit)
        [emap,grains] = importebsdmap(dotsfile, grainfile, stepsize)
        data = importCRCfile(filename)
    end 
end