<<<<<<< HEAD
function [emap,grains] = importebsdmap
=======
function [emap,grains] = importebsdmap(dotsfile, grainfile, crcfile)
>>>>>>> 5eec6960b06bb6b3768e8d9e84668357651cc221
    % IMPORTEBSDMAP import EBSD data from two input files. 
    % dotsfile --- HKL EBSD data for each pixels and their corresponding grain ID
    % grainfile --- HKL data for each grains
    % These two files must be exported from Tango in the HKL-Channel 5 software
    % package by the following procedures:
    %   * Detect grains
    %   * In the Grain Detectiong window, right click the table and in the
    %   dropdown menu> 
    %       ** Export Grain List > To file. --- dotsfile
    %       ** Export All Cell > To file. --- grain file
    % 
    % This function compile a standard workflow to generate a
    % ebsd.map. 
<<<<<<< HEAD
    typesSupported = {"AztecCrystal", "HKL Channel 5", "Customized"};

    [whichtype,tf] = listdlg("PromptString","Select EBSD data type", 'ListString', typesSupported, 'SelectionMode', 'single', 'ListSize', [150,100]);
    whattype = typesSupported{whichtype};

    [dotfilename,dotfilepath] = uigetfile('*.txt','Select the exported pixel data file');
    dotsfile = [dotfilepath, dotfilename];
    [grfilename,grfilepath] = uigetfile('*.txt','Select the exported grain data file');
    grainfile = [grfilepath, grfilename];
    switch whattype
        case 'AztecCrystal'
            dots = ebsd.pixcell.importAZTec(dotsfile);
            disp('PIXCELL data created');
            grains = ebsd.grain.importAztexGrains(grainfile);
        case 'HKL Channle 5'
            dots = ebsd.pixcell.importHKL(dotsfile);
            disp('PIXCELL data created');
            grains = ebsd.grain.importHKLgrains(grainfile);
        case 'Customized'
            dots = ebsd.pixcell.importCustomized(dotsfile);
            disp('PIXCELL data created');
            grains = ebsd.grain.importCustomisedGrains(grainfile);
    end

    answer = questdlg('Import EBSD parameters from HKL project *.cpr file?', 'EBSD parameters','Yes','No, extract', 'No, input', 'Yes');
    switch answer
        case 'Yes'
            [crcfilename,crcfilepath] = uigetfile('*.cpr', 'Select HKL project file');
            crcfile = [crcfilepath, crcfilename];
            ebsdpara = ebsd.map.importCRCfile(crcfile);
        case 'No, extract'
            ebsdpara = dots.extractParameters;
        case 'No, input'
            opts.Interpreter = 'tex';
            paraanswer = inputdlg({'Step size (\mum):', 'Number of x steps:', 'Number of y steps:'}, 'EBSD Parameters',[1,30;1,30;1,30], {'0','0','0'}, opts);
            paras = str2double(paraanswer);
            if isempty(paraanswer) | all(str2double(paraanswer))
                % if answer not given or default answer given, issue a
                % warning
                error('Invalid parameters or parameters not input...')
            else
                ebsdpara.stepsize = paras(1);
                ebsdpara.xStepSize = ebsdpara.stepsize;
                ebsdpara.yStepSize = ebsdpara.stepsize;
                ebsdpara.numXCells = paras(2);
                ebsdpara.numYCells = paras(3);
                ebsdpara.allEBSDinfo = [];
                ebsdpara.CS1toCS0 = [];
            end
    end
    stepsize = ebsdpara.xStepSize;
    
    % Now step size is available, flip the map
    dots = dots.flip(stepsize);
    switch whattype
        case 'AztecCrystal'
            grains = ebsd.grain.importAztexGrains(grainfile);
        case 'HKL Channle 5'
            grains = ebsd.grain.importHKLgrains(grainfile,stepsize);
        case 'Customized'
            grains = ebsd.grain.importCustomisedGrains(grainfile);
    end
    disp('Please waiting when the EBSDMAP is being created, if you have already EBSDGRAIN data, use ebsdmap(grainobj) to create the map');
    disp('grain data has been imported, assigning Pixcell data to each grains...');
    grains.claimownership(dots);
    disp('PIXCELL data have been assigned to each grains. I am polygonizing grains, which may take a while...');
    grains.polygonize(dots,ebsdpara);
    disp('Grains have been polygonized and I am creating ebsd.map...')
=======
    
    if nargin == 0
        [crcfilename,crcfilepath] = uigetfile('*.cpr', 'Select HKL project file');
        crcfile = [crcfilepath, crcfilename];
        [dotfilename,dotfilepath] = uigetfile('*.txt','Select the exported pixel data file');
        dotsfile = [dotfilepath, dotfilename];
        [grfilename,grfilepath] = uigetfile('*.txt','Select the exported grain data file');
        grainfile = [grfilepath, grfilename];
        whattype = input('Is it an AZtec or HKL file? Type 0 or 1: \n [0] -- AZtec, \n [1] -- HKL \n ');
        if isempty(whattype)
            isAztec = true;
        elseif whattype == 0
            isAztec = ~whattype;
        else
            isAztec = false;
        end
    end
    disp('Please waiting when the EBSDMAP is being created, if you have already EBSDGRAIN data, use ebsdmap(grainobj) to create the map');
%     h = waitbar(0, msgstart);
%     disp(['Start creating ebsd.map. ', msgstart]);
%     if nargin == 3
%         dots = ebsd.pixcell.importHKL(dotsfile, stepsize);
%     else
%         dots = ebsd.pixcell.importHKL(dotsfile);
%     end
    ebsdpara = ebsd.map.importCRCfile(crcfile);
    stepsize = ebsdpara.xStepSize;
    if isAztec
        dots = ebsd.pixcell.importAZTec(dotsfile, stepsize);
    else
        dots = ebsd.pixcell.importHKL(dotsfile, stepsize);
    end
    disp('EBSDDOT data created');
    if isAztec
        grains = ebsd.grain.importAztexGrains(grainfile);
    else
        grains = ebsd.grain.importHKLgrains(grainfile);
    end
    disp('grain data has been imported, assigning EBSDDOT data to each grains...');
    grains.claimownership(dots);
    disp('EBSDDOT data have been assigned to each grains. I am polygonizing grains, which may take a while...');
    grains.polygonize(dots,ebsdpara);
    disp('Grains have been polygonized and I am creating EBSDMAP...')
>>>>>>> 5eec6960b06bb6b3768e8d9e84668357651cc221
    emap = ebsd.map(grains);
    emap.pixels = dots;
    emap.stepsize = stepsize;
    emap.numXCells = ebsdpara.numXCells;
    emap.numYCells = ebsdpara.numYCells;
<<<<<<< HEAD
    if isfield(ebsdpara, 'allEBSDinfo')
        emap.ebsdInfoTable = ebsdpara.allEBSDinfo;
    end
    if isfield(ebsdpara,'CS1toCS0')
        emap.CS1toCS0 = ebsdpara.CS1toCS0;
    end
=======
    emap.ebsdInfoTable = ebsdpara.allEBSDinfo;
    emap.CS1toCS0 = ebsdpara.CS1toCS0;
>>>>>>> 5eec6960b06bb6b3768e8d9e84668357651cc221
    disp('EBSD map created. I am checking the neighbours of each grains...');
%     d = input('What is the buffersize for checking neighbours [default=0.1*stepsize]: ');
%     if isempty(d)
%         d = stepsize*0.1;
%     end
    emap.grains.findneighbours(0.2*stepsize); 
    disp('I am searching and creating gb grain boundaries...')
    emap.findgbs;
    disp('I am about to finish and doing some finishing touches...')
    
    % Add the missing vertices that are not captured in merging processes
    emap.addMissingVertices(stepsize*0.2);
    emap.findEdgeVertices;
    disp('EBSDMAP has been created using the imported data and ready for further processing including smoothing and downsize the number of vertices!')
end