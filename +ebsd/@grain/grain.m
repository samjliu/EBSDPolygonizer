classdef grain<handle
    % EBSDGRAIN contains the EBSD data information for each grains
    % including the grain size and shape, the EBSD data points (ebsddot),
    % grain orientation in three euler angles, position of the centroid of
    % the grains. More importantly, it construct the grain to be a polygon
    % that can be trianglised and used for FEM analysis. 
    properties
        ID          % Grain ID, not 100% sure whether this is the same ID as in the ebsddot data
        phase       % Phase 
        pixelInds   % 
        ebsddots  = ebsd.pixcell.empty  % all the ebsddot the grain contains including the grain boundaries
        diam        % grain diameter in micron (um) 
        area        % grain area in micron^2 
        aspectratio % Aspect ratio of the grain
        meanphi1    % mean phi1 of the euler angle
        meanPHI     % mean PHI of the euler angle
        meanphi2    % mean phi2 of the euler angle
        oriBunge    % orientation by Euler angle in degree by Bunge notation
        xcg         % x coordinate of the centroid of the grain
        ycg         % y coordinate of the centroid of the grain
        isedge      % Boolean, is the grain on the border of the ebsd map
        iscorner    % Boolean, is the grain at the corder of the ebsd map
        polygon     % A matlab polyshape object
        isStrange
        width_px
        heigh_px 
        isSmoothed = false          % if the grain boundaries have been smoothed and re-connected or 'weaved'
        isalone = true
        hasNeighbours = false       % False, if the grain boundaries have been checked and identified within an ebsdmap object
        gbs                         % Store all the identified grain boundaries
        labeltoggle = false;
        verticemembers
        liveVertices                % live vertices from the verticemembers
        vertices                    % Static vertices that are generated by initializing the 
        neighbours
        activeVertices
        numActiveVertices
        unprotectedVertices
        iscropped = false
        isactive = true
        isIsolated
    end
    
    methods
        function eg = grain(varargin)
        end
        
        function value = get.numActiveVertices(eg)
            if ~isempty(eg.activeVertices)
                value = numel(eg.activeVertices);
            end
        end
        
        
        function value = get.isStrange(gr)
            if isempty(gr.polygon)
                value = false;
            else
                if gr.polygon.NumRegions > 1
                    value = true;
                else
                    value = false;
                end
            end
        end
        
        function value = get.isIsolated(gr)
            vca = gr.verticemembers(gr.verticemembers.active);
            if any([vca.isnode] | [vca.isedge])
                value = false;
            else
                value = true;
            end
        end
        
        
        function value = get.oriBunge(eg)
            if ~isempty(eg.meanphi1)
                value = [eg.meanphi1, eg.meanPHI, eg.meanphi2];
            end
        end
        
        function claimownership(eg,pixels)
            % Search ebsddots belonging to this grain from the EBSD data in
            % the form of ebsddot object
            h = waitbar(0, 'Claiming ownerships of the ebsddots');
            for i = 1:length(eg)
                eg(i).pixelInds = find(pixels.grainID == eg(i).ID);
                if isempty(eg(i).pixelInds)
                    disp(['Grain ', num2str(i), ' does not have any pixels and will be deleted'])
                    eg(i).isactive = false;
                end
                waitbar(i/length(eg), h, ['Claiming ownerships for grain ', num2str(i)]);
            end
            delete(h)
        end
        
        function insertvertices(grain,loc,vcs)
            v = grain.verticemembers;
            if loc == length(v)
                grain.verticemembers = vertcat(grain.verticemembers, vcs);
            else
                v1 = v(1:loc);
                v2 = v(loc+1:end);
                grain.verticemembers =  vertcat(v1, vcs, v2);
            end
        end
        
        function insertAtMultiple(grain,locs,vcs)
            [sortlocs, inds] = sort(locs,'descend');
            sortvcs = vcs(inds);
            for i = 1:length(sortlocs)
                grain.insertvertices(sortlocs(i),sortvcs(i));
            end
        end
                
        function findneighbours(grains, d)
            if nargin < 2
                d = 1;
            end
            num = length(grains);
            if num < 2
                warning('at least two grains are needed to find neighbours')
            elseif num >= 2
                h = waitbar(0, 'checking neighbouring grains...');
                for i = 1:length(grains)
                    gbuffer = grains(i).polygon.polybuffer(d, 'JointType', 'miter');
                    otherpoly = vertcat(grains.polygon);
                    otherpoly(i) = polyshape;
                    grains(i).neighbours = vertcat(grains(overlaps(gbuffer, otherpoly)).ID);
                    waitbar(i/length(grains), h, ['checking grain ', num2str(i), ' and ', num2str(length(grains(i).neighbours)), ' neighbours found']);
                end
                delete(h)
            end 
        end
        
        function poly = get.polygon(eg)
            % Get method for polygon so that it is up to date if the
            % verticemembers is not empty; otherwise,
            
            if ~isempty(eg.verticemembers)
                vcs = eg.activeVertices;
            else
                vcs = eg.vertices;
            end
            poly = polyshape(vcs,'Simplify', false, 'KeepCollinearPoints',true);
        end
        
        function vc = get.verticemembers(eg)
            if ~isempty(eg.verticemembers)
                vc = eg.verticemembers;
                vc(~isvalid(vc)) = [];
            else
                vc = [];
            end
        end
        
        function vc = get.liveVertices(eg)
            % Get method for static vertices, which are the coordinates of
            % the vertices rather than the reference to the gb
            % objects
            vc = vertcat(eg.verticemembers.vertice);
        end
        
        function vc = get.activeVertices(eg)
            vcmembers = eg.verticemembers;
            vcactive = vcmembers(vertcat(vcmembers.active));
            vc = vertcat(vcactive.vertice);
        end
        
        function vc = get.unprotectedVertices(eg)
            vcms = eg.verticemembers;
            vcunprotected = vcms(vertcat(vcms.active) & ~vertcat(vcms.protected));
            vc = vertcat(vcunprotected.vertice);
        end
        
        function refresh(eg)
            for i = 1:length(eg)
                eg(i).vertices = eg(i).liveVertices;
            end
        end
        
        function smoothgb(eg,para)
            %
            if nargin<2
                para = {5};
            end
            h1 = waitbar(0,'Smoothing grain boundaries...');
            for i = 1:numel(eg)
                x = eg(i).liveVertices(:,1);
                if length(x)>4 % will not smooth single pixel grain
                    y = eg(i).liveVertices(:,2);
                    visedge = vertcat(eg(i).verticemembers.isedge);
                    vedgeinds = find(visedge);
                    if length(vedgeinds) <= 1
                        x2smooth = x(~visedge);
                        y2smooth = y(~visedge);
                        sx = smooth(x2smooth, para{:});
                        sy = smooth(y2smooth, para{:});
                        set(eg(i).verticemembers(~visedge), 'x', sx);
                        set(eg(i).verticemembers(~visedge), 'y', sy);
                    elseif length(vedgeinds) > 1
                        bp = vedgeinds;
                        pickpoints = vertcat(0, bp, length(eg(i).verticemembers));
    %                         segments = cell(length(pickpoints)-1,1);
                        for j = 1:length(pickpoints)-1
                            seg = eg(i).verticemembers(pickpoints(j)+1:pickpoints(j+1));
    %                             seg = segments{j};
                            if length(seg)>= 3
                                segx = smooth(vertcat(seg.x), para{:});
                                segy = smooth(vertcat(seg.y), para{:});
                                set(seg, 'x', segx);
                                set(seg, 'y', segy);
                            end
                        end
                    end
                end
                waitbar(i/length(eg),h1, ['Smoothing grain boundaries for grain ', num2str(eg(i).ID)])
            end
            delete(h1)
        end   
        
        function set(eg,prop,value)
            for i = 1:length(eg)
                eg(i).(prop) = value;
            end
        end
        
        function [h, t]  = plot(egs)
            %
            polys= vertcat(egs.polygon);
            h = plot(polys);
            IDs = vertcat(egs.ID);
            [x,y] = polys.centroid;
            t = text(x,y, num2str(IDs));
            xlabel('\mum')
            ylabel('\mum')

            axis tight
            box off
            hold on
            daspect([1 1 1]);
            pbaspect([1 1 1]);
            hold off
        end
        
        
        function findEgde(eg)
            % 
            for i = 1:length(eg)
                x = eg(i).polygon.Vertices(:,1);
                y = eg(i).polygon.Vertices(:,2);
                xrightedge = eg(i).ebsddots.stepsize * eg(i).width_px;
                ytopedge = eg(i).ebsddots.stepsize * eg(i).height_px;
                xmax = max(x);
                xmin = min(x);
                ymax = max(y);
                ymin = min(y);
                if any(xmin == 0,  xmax == xrightedge, ymin == 0, ymax == ytopedge)
                    eg(i).isedge = true;
                end
                indleft = find(x == 0);
                indright = find(x == xrightedge);
                indbottom = find(y == 0);
                indtop = find(y == ytopedge);
                if eg(i).isedge      
                end
            end
        end
        
        
    end
    
    methods(Static)
        function [eg] = importHKLgrains(grainfile)
            % construct ebsd.grain from the grain list data files exported
            % from HKL channle 5
            if nargin < 1
                [filename,filepath] = uigetfile('*.txt','Select the EBSD grain list file in the format of text file exported by HKL Channel 5');
                grainfile = [filepath, filename];
            end
            grfileID = fopen(grainfile,'r');
            delimiter = '\t';
            startRow = 2;
            endRow = inf;
            formatSpec = '%f%s%f%f%f%f%f%f%f%f%f%f%f%f%f%s%s%[^\n\r]';
            dataArray = textscan(grfileID, formatSpec, endRow-startRow+1, 'Delimiter', delimiter, 'TextType', 'string', 'HeaderLines', startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
            fclose(grfileID);
            
            eg(size(dataArray{1},1),1) = ebsd.grain;
            h = waitbar(0,'Importing grain data....');
            for i = 1:length(eg)
                eg(i) = ebsd.grain;
                eg(i).ID = dataArray{1}(i);
                eg(i).phase = dataArray{2}(i);
                eg(i).diam = dataArray{4}(i);
                eg(i).area = dataArray{3}(i);
                eg(i).aspectratio = dataArray{9}(i);
                eg(i).xcg = dataArray{6}(i);
                eg(i).ycg = dataArray{7}(i);
                eg(i).meanphi1 = dataArray{13}(i);
                eg(i).meanPHI = dataArray{14}(i);
                eg(i).meanphi2 = dataArray{15}(i);
                border = dataArray{17}(i);
                switch border
                    case "no"
                        eg(i).isedge = false;
                        eg(i).iscorner = false;
                    case "edge"
                        eg(i).isedge = true;
                        eg(i).iscorner = false;
                    case "corner"
                        eg(i).isedge = true;
                        eg(i).iscorner = true;
                end
                waitbar(i/length(eg), h, [num2str(i),' grains imported....'])
            end
            delete(h)
        end

        function [eg,h] = importAztexGrains(grainfile)
            % construct ebsd.grain from the grain list data files exported
            if nargin < 1
                [filename,filepath] = uigetfile('*.txt','Select the EBSD grain list file in the format of text file exported by HKL Channel 5');
                grainfile = [filepath, filename];
            end
            % Specify range and delimiter
            startRow = 3;
            opts = delimitedTextImportOptions("NumVariables", 27, "Encoding", "UTF-8");
            opts.DataLines = [startRow, Inf];
            opts.Delimiter = ["\t",","];
            
            % Specify column names and types
            opts.VariableNames = ["Id", "Phase", "PixelCount", "Area", "Perimeter", "EquivalentCircleDiameter", "MaxFeretDiameter", "CenterOfGravityX", "CenterOfGravityY", "Convexity", "Roundness", "Rectangularity", "FittedEllipseMajorDiameter", "FittedEllipseMinorDiameter", "FittedEllipseAngle", "FittedEllipseAspectRatio", "MaxFeretAngle", "MeanOrientationSpread", "MaximumOrientationSpread", "MeanBandContrast", "MeanBandSlope", "MeanMAD", "NeighborGrainCount", "CrystalliteCount", "MeanOrientationEuler1", "MeanOrientationEuler2", "MeanOrientationEuler3"];
            opts.VariableTypes = ["double", "categorical", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];
            
            % Specify file level properties
            opts.ExtraColumnsRule = "ignore";
            opts.EmptyLineRule = "skip";
            
            % Specify variable properties
            opts = setvaropts(opts, "Phase", "EmptyFieldRule", "auto");
            dataArray = readtable(grainfile, opts);

            
            eg(size(dataArray,1),1) = ebsd.grain;
            h = waitbar(0,'Importing grain data....');
            for i = 1:length(eg)
                eg(i) = ebsd.grain;
                eg(i).ID = dataArray.Id(i);
                eg(i).phase = dataArray.Phase(i);
                eg(i).diam = dataArray.EquivalentCircleDiameter(i);
                eg(i).area = dataArray.Area(i);
                eg(i).aspectratio = dataArray.FittedEllipseAspectRatio(i);
                eg(i).xcg = dataArray.CenterOfGravityX(i);
                eg(i).ycg = dataArray.CenterOfGravityY(i);
                eg(i).meanphi1 = dataArray.MeanOrientationEuler1(i);
                eg(i).meanPHI = dataArray.MeanOrientationEuler2(i);
                eg(i).meanphi2 = dataArray.MeanOrientationEuler3(i);
%                 border = dataArray{17}(i);
%                 switch border
%                     case "no"
%                         eg(i).isedge = false;
%                         eg(i).iscorner = false;
%                     case "edge"
%                         eg(i).isedge = true;
%                         eg(i).iscorner = false;
%                     case "corner"
%                         eg(i).isedge = true;
%                         eg(i).iscorner = true;
%                 end
                waitbar(i/length(eg), h, [num2str(i),' grains imported....'])
            end
            delete(h)
        end

        function eg = importCustomisedGrains(grainfile)
            % construct ebsd.grain from the grain list data files exported
            if nargin < 1
                [filename,filepath] = uigetfile('*.txt','Select the customised grain list file');
                grainfile = [filepath, filename];
            end

            opts = delimitedTextImportOptions("NumVariables", 4, "Encoding", "UTF-8");

            % Specify range and delimiter
            opts.DataLines = [2,inf];
            opts.Delimiter = ",";
            
            % Specify column names and types
            opts.VariableNames = ["Id", "MeanOrientationPhi1", "MeanOrientationPHI", "MeanOrientationPhi2"];
            opts.VariableTypes = ["double", "double", "double", "double"];
            
            % Specify file level properties
            opts.ExtraColumnsRule = "ignore";
            opts.EmptyLineRule = "read";
            
            % Import the data
            dataArray = readtable(grainfile, opts);
            eg(size(dataArray,1),1) = ebsd.grain;
            h = waitbar(0,'Importing grain data....');
            for i = 1:length(eg)
                eg(i) = ebsd.grain;
                eg(i).ID = dataArray.Id(i);
                eg(i).meanphi1 = dataArray.MeanOrientationPhi1(i);
                eg(i).meanPHI = dataArray.MeanOrientationPHI(i);
                eg(i).meanphi2 = dataArray.MeanOrientationPhi2(i);
                waitbar(i/length(eg), h, [num2str(i),' grains imported....'])
            end
            delete(h)
        end

       

    end
end