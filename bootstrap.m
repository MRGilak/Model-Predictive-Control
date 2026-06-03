root = fileparts(mfilename('fullpath'));

% Add src root to path 
addpath(root);

% Manage demos folder paths
dmc_demos = fullfile(root, 'utils', 'dmc');
epfc_demos = fullfile(root, 'utils', 'epfc');

% Remove old lib paths if they exist
old_dmc_lib = fullfile(root, 'lib', 'dmc');
old_epfc_lib = fullfile(root, 'lib', 'epfc');

if ismember(old_dmc_lib, strsplit(path, pathsep))
	rmpath(old_dmc_lib);
end
if ismember(old_epfc_lib, strsplit(path, pathsep))
	rmpath(old_epfc_lib);
end

% Auto-detect caller and add appropriate demos path
stack = dbstack('-completenames');
caller_file = '';
if numel(stack) >= 2
	caller_file = stack(2).file;
end

if contains(caller_file, [filesep 'scripts' filesep 'dmc' filesep])
	addpath(dmc_demos);
elseif contains(caller_file, [filesep 'scripts' filesep 'epfc' filesep])
	addpath(epfc_demos);
else
	% Default: add both if called from non-script context
	addpath(dmc_demos);
	addpath(epfc_demos);
end
