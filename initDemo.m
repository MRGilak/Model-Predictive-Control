function initDemo()
    % initDemo - Single-line initialization for demo scripts
    %   The function automatically:
    %   - Adds src to MATLAB path
    %   - Adds the controllers package
    %   - Adds the appropriate demos folder (auto-detected)
    
    % Get src root
    src_root = fileparts(mfilename('fullpath'));
    
    % Add src to path first
    addpath(src_root, '-begin');
    
    % Auto-detect controller type from calling script location
    stack = dbstack('-completenames');
    controller_type = '';
    
    if numel(stack) > 1
        caller_file = stack(2).file;
        if contains(caller_file, [filesep 'dmc' filesep])
            controller_type = 'dmc';
        elseif contains(caller_file, [filesep 'epfc' filesep])
            controller_type = 'epfc';
        end
    end
    
    % Run bootstrap to handle additional setup
    run(fullfile(src_root, 'bootstrap.m'));
    
    % Add the appropriate demos folder
    if ~isempty(controller_type)
        demos_path = fullfile(src_root, 'utils', controller_type);
        if exist(demos_path, 'dir')
            addpath(demos_path, '-begin');
        end
    end
end
