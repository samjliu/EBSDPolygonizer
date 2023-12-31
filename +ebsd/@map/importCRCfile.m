function data = importCRCfile(filename)
%IMPORTFILE Import data from a text file
%  IFNDCS35SYMMETRY9 = IMPORTFILE(FILENAME) reads data from text file
%  FILENAME for the default selection.  Returns the data as a table.
%
%  IFNDCS35SYMMETRY9 = IMPORTFILE(FILE, DATALINES) reads data for the
%  specified row interval(s) of text file FILENAME. Specify DATALINES as
%  a positive scalar integer or a N-by-2 array of positive scalar
%  integers for dis-contiguous row intervals.
%
%  Example:
%  IFndcs35symmetry9 = importfile("C:\Users\Jun\ownCloud\Work\OMA Project\IF Steels\TATA-Recrystallisation-trial\EBSD Analysis\Session 3\IFndcs35_symmetry 9.cpr", [2, Inf]);
%
%  See also READTABLE.
%
% Auto-generated by MATLAB on 01-Oct-2020 23:01:32

%% Input handling
if nargin <1 
    [cprfilename,cprfilepath] = uigetfile('Select CPR project file');
    filename = fullfile(cprfilepath,cprfilename);
end

% If dataLines is not specified, define defaults
dataLines = [2, Inf];

%% Set up the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 2);

% Specify range and delimiter
opts.DataLines = dataLines;
opts.Delimiter = "=";

% Specify column names and types
opts.VariableNames = ["Parameters", "Values"];
opts.VariableTypes = ["string", "string"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, "Parameters", "WhitespaceRule", "preserve");
opts = setvaropts(opts, "Parameters", "EmptyFieldRule", "auto");

% Import the data
datatable = readtable(filename, opts);
data.numXCells = str2double(datatable(datatable.Parameters=="xCells",2).Values);
data.numYCells = str2double(datatable(datatable.Parameters=="yCells",2).Values);
data.xStepSize = str2double(datatable(datatable.Parameters=="GridDistX",2).Values);
data.yStepSize = str2double(datatable(datatable.Parameters=="GridDistY",2).Values);
data.stepsize = str2double(datatable(datatable.Parameters=="GridDist",2).Values);
if isempty(data.stepsize) & ~isempty(data.xStepSize)
    data.stepsize = data.xStepSize;
else
    warning('Step size was not found.')
end
euler1 = str2double(datatable(datatable.Parameters=="Euler1",2).Values);
euler2 = str2double(datatable(datatable.Parameters=="Euler2",2).Values);
euler3 = str2double(datatable(datatable.Parameters=="Euler3",2).Values);
data.CS1toCS0 = [euler1, euler2, euler3];
data.allEBSDinfo = datatable;

end