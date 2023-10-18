classdef pixcell
    % PIXCELL is a supporting class for the ebsd package that is designed
    % to store the raw EBSD data (information of pixels and make some
    % initial process to obtain key information. 
    % The main function is the static method: importHKL
    properties
        index       % the index of the pixcel
        x           % x coordinate of the pixel
        y           % y coordinate
        phi1        % First Euler angle in degree in Bunge notation
        PHI         % Second Euler anlge 
        phi2        % Third Euler angle
        phase       % Phase of the pixcel
        mad         % mad data
        bandcontr   % band contrast
        bs          % 
        grainID     % Grain ID
        isongb      % Boolean, is it on a grain boundary?
        isatedge    % Boolean, is it on the edge of a scan?
        isIndexed   % Boolean, is it indexed?
        stepsize    % stepsize should be given separately in micron
%         btx         % x coordinate of the bottom right corner of the polygon 
%         bry         % y coordinate of the bottom right corner of the polygon 
%         blx         % x coordinate of the bottom left corner of the polygon 
%         bly         % y coordinate of the bottom left corner of the polygon 
%         toprx       % x coordinate of the top right corner of the polygon 
%         topry       % y coordinate of the top right corner of the polygon 
        % x and y is the top left corner of the polygon
    end
    
    methods
        function ed = pixcell(varargin)                
        end
        
        function ed = crop(ed,inds)
            ed.index = ed.index(inds);
            ed.x = ed.x(inds);
            ed.y = ed.y(inds);
            ed.phi1 = ed.phi1(inds);
            ed.PHI = ed.PHI(inds);
            ed.phi2 = ed.phi2(inds);
            ed.phase = ed.phase(inds);
            ed.mad = ed.mad(inds);
            ed.bandcontr= ed.bandcontr(inds);
            ed.bs = ed.bs(inds);
            ed.grainID = ed.grainID(inds);
        end
        
        function [X,Y] = buildcells(ed, ebsdpara, inds)
            nxcell = ebsdpara.numXCells;
            nycell = ebsdpara.numYCells;
            xstep = ebsdpara.xStepSize;
            ystep = ebsdpara.yStepSize;
            
            sz = [nxcell, nycell];
%             innersz = (nxcell-1)*(nycell-1);
            
            xdata = zeros(length(inds),4);
            ydata = zeros(length(inds),4);
            [i,j] = ind2sub([nxcell,nycell],inds);
            
            innerinds = find(i>=1 & i<nxcell & j>=1 & j<nycell);
            if ~isempty(innerinds)
                xdata(innerinds,1) = ed.x(sub2ind(sz,i(innerinds),j(innerinds))); 
                xdata(innerinds,2) = ed.x(sub2ind(sz,i(innerinds)+1,j(innerinds)));
                xdata(innerinds,3) = ed.x(sub2ind(sz,i(innerinds)+1, j(innerinds)+1)); 
                xdata(innerinds,4) = ed.x(sub2ind(sz,i(innerinds), j(innerinds)+1));
                ydata(innerinds,1) = ed.y(sub2ind(sz,i(innerinds),j(innerinds))); 
                ydata(innerinds,2) = ed.y(sub2ind(sz,i(innerinds)+1,j(innerinds)));
                ydata(innerinds,3) = ed.y(sub2ind(sz,i(innerinds)+1, j(innerinds)+1)); 
                ydata(innerinds,4) = ed.y(sub2ind(sz,i(innerinds), j(innerinds)+1));
            end
            
            
            lastycellsinds = find(i>=1 & i<nxcell & j==nycell);
            if ~isempty(lastycellsinds)
                xdata(lastycellsinds,1) = ed.x(sub2ind(sz,i(lastycellsinds),j(lastycellsinds)));
                xdata(lastycellsinds,2) = ed.x(sub2ind(sz,i(lastycellsinds)+1,j(lastycellsinds)));
                xdata(lastycellsinds,3) = ed.x(sub2ind(sz,i(lastycellsinds)+1,j(lastycellsinds)));
                xdata(lastycellsinds,4) = ed.x(sub2ind(sz,i(lastycellsinds),j(lastycellsinds)));
                ydata(lastycellsinds,1) = ed.y(sub2ind(sz, i(lastycellsinds),j(lastycellsinds)));
                ydata(lastycellsinds,2) = ed.y(sub2ind(sz, i(lastycellsinds)+1,j(lastycellsinds)));
                ydata(lastycellsinds,3) = ed.y(sub2ind(sz, i(lastycellsinds)+1,j(lastycellsinds)))-ystep;
                ydata(lastycellsinds,4) = ed.y(sub2ind(sz, i(lastycellsinds),j(lastycellsinds)))-ystep;
            end
            
            
            lastxcellsinds = find(i==nxcell & j>=1 & j<nycell);
            
%             lastxcellsinds = ismember(inds,nycell:nxcell:(nxcell*(nycell-1)));
            if ~isempty(lastxcellsinds)
                xdata(lastxcellsinds,1) = ed.x(sub2ind(sz, i(lastxcellsinds), j(lastxcellsinds)));
                xdata(lastxcellsinds,2) = ed.x(sub2ind(sz, i(lastxcellsinds), j(lastxcellsinds)))+xstep;
                xdata(lastxcellsinds,3) = ed.x(sub2ind(sz, i(lastxcellsinds), j(lastxcellsinds)+1))+xstep;
                xdata(lastxcellsinds,4) = ed.x(sub2ind(sz, i(lastxcellsinds), j(lastxcellsinds)+1));
                ydata(lastxcellsinds,1) = ed.y(sub2ind(sz, i(lastxcellsinds), j(lastxcellsinds)));
                ydata(lastxcellsinds,2) = ed.y(sub2ind(sz, i(lastxcellsinds), j(lastxcellsinds)));
                ydata(lastxcellsinds,3) = ed.y(sub2ind(sz, i(lastxcellsinds), j(lastxcellsinds)+1));
                ydata(lastxcellsinds,4) = ed.y(sub2ind(sz, i(lastxcellsinds), j(lastxcellsinds)+1));
            end
            
            lastcell = find(inds==nxcell*nycell);
            if ~isempty(lastcell)
                xdata(lastcell,1) = ed.x(end);
                xdata(lastcell,2) = ed.x(end)+xstep;
                xdata(lastcell,3) = ed.x(end)+xstep;
                xdata(lastcell,4) = ed.x(end);
                ydata(lastcell,1) = ed.y(end);
                ydata(lastcell,2) = ed.y(end);
                ydata(lastcell,3) = ed.y(end)-ystep;
                ydata(lastcell,4) = ed.y(end)-ystep;
            end
            
            X = num2cell(xdata,2);
            Y = num2cell(ydata,2);
        end
    end
    
    methods(Static)
        function pxc = importHKL(datafile,stepsize)
            % Import the EBSD data file exported from Tango of HKL Channel
            % software package. See ebsd.map for how to export the text
            % data file
            % INPUT arguements
            %   * datafile --- the data file of the exported pixcel
            %   * stepsize --- step size of the EBSD scanning (in micron)
            % OUTPUT argument
            %   * the output arguement is an ebsd.pixcell object
            if nargin < 1
                [filename,filepath] = uigetfile('*.txt','Select the pixel data file:');
                datafile = [filepath, filename];
                stepsize = input('Step size is [micron]: ');
            end
            fileID = fopen(datafile,'r');
            delimiter = '\t';
            startRow = 2;
            endRow = inf;
            formatSpec = '%f%s%f%f%f%f%f%f%f%f%f%f%[^\n\r]';
            dataArray = textscan(fileID, formatSpec, endRow-startRow+1, 'Delimiter', delimiter, 'TextType', 'string', 'EmptyValue', NaN, 'HeaderLines', startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
            pxc = ebsd.pixcell;
            pxc.index = dataArray{:,1};
            pxc.phase = dataArray{:,2};
            pxc.x = dataArray{:,3};
            pxc.y = dataArray{:,4};
            pxc.phi1 = dataArray{:,5};
            pxc.PHI = dataArray{:,6};
            pxc.phi2 = dataArray{:,7};
            pxc.mad = dataArray{:,8};
            pxc.bandcontr = dataArray{:,10};
            pxc.bs = dataArray{:,11};
            pxc.grainID = dataArray{:,12};
%             if nargin < 2  % if step size is not given, determine it from the imported data
%                 ux = unique(ed.x);
%                 uy = unique(ed.y);
%                 uxdif = diff(ux);
%                 uydif = diff(uy);
%                 [xsteps, inxsteps, induxdif] = unique(uxdif);
%                 [ysteps, inysteps, induydif]  = unique(uydif);
%                 
%                 xstep = min(unique(uxdif));
%                 ystep = min(unique(uydif));
%                 if xstep == ystep && xstep ~= 0
%                     stepsize = xstep;
%                 else
%                     % If the step size cannot be determined from the data,
%                     % The user is asked to input it (in micron)
%                     % If no input is returned, step size is set to 10.
%                     xsteps
%                     ysteps
%                     step = input('I cannot determine what the step size is, please tell me... [micron]: ');
%                     if ~isempty(step)
%                        stepsize = step;
%                     else
%                        error('Step size is not given!');
%                     end                   
%                 end
%             end
            pxc.stepsize = stepsize;
            pxc.y = max(pxc.y)+stepsize-pxc.y;
            fclose(fileID); 
        end

        function pxc = importAZTec(datafile,stepsize)
            % Import the EBSD data file exported from Tango of HKL Channel
            % software package. See ebsd.map for how to export the text
            % data file
            % INPUT arguements
            %   * datafile --- the data file of the exported pixcel
            %   * stepsize --- step size of the EBSD scanning (in micron)
            % OUTPUT argument
            %   * the output arguement is an ebsd.pixcell object
            if nargin < 1
                [filename,filepath] = uigetfile('*.txt','Select the pixel data file:');
                datafile = [filepath, filename];
                stepsize = input('Step size is [micron]: ');
            end
%             fileID = fopen(datafile,'r');
            startRow = 3;
            endRow = inf;
%             formatSpec = '%f%f%f%f%f%f%[^\n\r]';
            opts = delimitedTextImportOptions("NumVariables", 6, "Encoding", "UTF-8");
            % Specify range and delimiter
            opts.DataLines = [startRow, endRow];
            opts.Delimiter = ["\t",","];

            % Specify column names and types
            opts.VariableNames = ["Index", "X", "Y", "GrainID", "IsBoundary", "PhaseID"];
            opts.VariableTypes = ["double", "double", "double", "double", "double", "double"];
            
            % Specify file level properties
            opts.ExtraColumnsRule = "ignore";
            opts.EmptyLineRule = "skip";
            
            % Import the data
            dataArray = readtable(datafile, opts);
%             dataArray = textscan(fileID, formatSpec, endRow-startRow+1, 'Delimiter', delimiter, 'TextType', 'string', 'EmptyValue', NaN, 'HeaderLines', startRow-2, 'ReturnOnError', false, 'EndOfLine', '\r\n');
            pxc = ebsd.pixcell;
            pxc.index = dataArray.Index;
            pxc.x = dataArray.X;
            pxc.y = dataArray.Y;
            pxc.grainID = dataArray.GrainID;
%             if nargin < 2  % if step size is not given, determine it from the imported data
%                 ux = unique(ed.x);
%                 uy = unique(ed.y);
%                 uxdif = diff(ux);
%                 uydif = diff(uy);
%                 [xsteps, inxsteps, induxdif] = unique(uxdif);
%                 [ysteps, inysteps, induydif]  = unique(uydif);
%                 
%                 xstep = min(unique(uxdif));
%                 ystep = min(unique(uydif));
%                 if xstep == ystep && xstep ~= 0
%                     stepsize = xstep;
%                 else
%                     % If the step size cannot be determined from the data,
%                     % The user is asked to input it (in micron)
%                     % If no input is returned, step size is set to 10.
%                     xsteps
%                     ysteps
%                     step = input('I cannot determine what the step size is, please tell me... [micron]: ');
%                     if ~isempty(step)
%                        stepsize = step;
%                     else
%                        error('Step size is not given!');
%                     end                   
%                 end
%             end
            pxc.stepsize = stepsize;
            pxc.y = max(pxc.y)+stepsize-pxc.y;
%             fclose(fileID); 
        end

        function pxc = importCustomized(pixeldatafile,stepsize)
            % Import customised EBSD data
            % The required data include
                % All pixels at least containing
                    % index of the pixel
                    % x coordinate
                    % y coordinate
                    % Eulder angle phi1
                    % Euler angle PHi
                    % Euler angle phi2
                    % GrainID to which the pixel belongs
                % stepsize
            % The optional data include the rest of the properties
                    % mad         % mad data
                    % bandcontr   % band contrast
                    % bs          % 
                    % grainID     % Grain ID
                    % isongb      % Boolean, is it on a grain boundary?
                    % isatedge    % Boolean, is it on the edge of a scan?
                    % isIndexed   % Boolean, is it indexed?

            if nargin < 1
                [filename,filepath] = uigetfile('*.txt','Select the customised pixel data file:');
                pixeldatafile = [filepath, filename];
                options.Interpreter = 'tex';
                stepsizeanswer = inputdlg('Enter step size \mum:','Step size',[1,30], {''}, options);
                stepsize = str2double(stepsizeanswer);
            end
                    %% Set up the Import Options and import the data
            opts = delimitedTextImportOptions("NumVariables", 4);
            
            % Specify range and delimiter
            opts.DataLines = [2,inf];
            opts.Delimiter = ",";
            
            % Specify column names and types
            opts.VariableNames = ["Index", "X", "Y", "GrainID"];
            opts.VariableTypes = ["double", "double", "double", "double"];
            
            % Specify file level properties
            opts.ExtraColumnsRule = "ignore";
            opts.EmptyLineRule = "read";
            
            % Import the data
            pixeltable = readtable(pixeldatafile, opts);
            pxc = ebsd.pixcell;
            pxc.index = pixeltable.Index;
            pxc.x = pixeltable.X;
            pxc.y = pixeltable.Y;
            pxc.grainID = pixeltable.GrainID;
            pxc.stepsize = stepsize;
        end
    end
end
