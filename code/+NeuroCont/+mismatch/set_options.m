function mismatchOption = set_options(varargin)
    % Generates a mismatchOption based on the input
    % Name-Value pairs.
    % 
    % Note: Exclusion (of blocks, mismatch or type) always take precedence over inclusion. 
    % Thus using an *'all'* key in an exclusion option result in all types/mismatch to be eliminated.
    %
    % Description
    % -----------
    %   mismatchOption = set_options(name, value, ...)
    %       Generate a new mismatchOption from the name-value options.
    %
    %   mismatchOption = set_options(mismatchOption, name, value, ...)
    %       Apply the name-value options to a given mismatchOption.
    % Inputs
    % ------
    %   name: char or string
    %       Name of the option to set.
    %   value: misc
    %       Value of the option to set.
    %
    % Optional Input
    % --------------
    %   mismatchOption: struct
    %       Preexisting mismatchOption.
    %
    % Output
    % ------
    %   mismatchOption: struct
    %       Resulting structuring containing the preset options.
    %
    % :Name-Value Inputs:
    %   ``'baseOptions'``: (char, string) -- 'on' to specify adding the option defined by :func:`base_options`.
    %
    %   ``'blockIncludeList'``: (char, cell(char), string) -- path(s) to specific block(s) to include in mismatch.
    %   
    %   ``'blockExcludeList'``: (char, cell(char), string) -- path(s) to specific block(s) to exclude of mismatch.
    %   
    %   ``'mismatchIncludeList'``: (char, cell(char), string) -- specific mismatch(es) categories to include generation (special key *'all'* available).
    %   
    %   ``'mismatchExcludeList'``: (char, cell(char), string) -- specific mismatch(es) categories to exclude generation (special key *'all'* available).
    %   
    %   ``'blockTypeIncludeList'``: (char, cell(char), string) -- specific block type(s) to include in mismatch (special key *'all'* available).
    %   
    %   ``'blockTypeExcludeList'``: (char, cell(char), string) -- specific block type(s) to exclude of mismatch (special key *'all'* available).
    %   
    %   ``'simParamList'``: (struct) -- parameter value to apply to model before generating mismatch.
    %   
    %   ``'mismatchFunctions'``: (containers.Map(char,containers.Map(char,function_handle))) -- function(s) that apply mismatch to a specific block type.

    import NeuroCont.mismatch.*

    varg = varargin;
    if mod(length(varargin),2) ~= 0
        if isstruct(varg{1}) && length(varg{1}) == 1 && isfield(varg{1},'mismatchOptionStruct')
            mismatchOption = varg{1};
            varg = varg(2:end);
        else
            error("Arguments must be pairs or the first can be an existing mismatchOption")
        end
    else
        mismatchOption = struct('mismatchOptionStruct', 1);
        mismatchOption.mismatch_func_map = containers.Map();
        mismatchOption.block_includelist = {};
        mismatchOption.block_excludelist = {};
        mismatchOption.mismatch_includelist = {};
        mismatchOption.mismatch_excludelist = {};
        mismatchOption.blocktype_includelist = {};
        mismatchOption.blocktype_excludelist = {};
        mismatchOption.params = struct();
    end

    
    for i = 1:2:length(varg)
        key = varg{i};
        value = varg{i+1};
        if isstring(key) && length(key) == 1
            key = convertStringsToChars(key);
        end

        if ~ischar(key)
            error("Key of a key-value pair must be a char array or a string.")
        end

        switch key
            case 'baseOptions'
                if isstring(value)
                    value = convertStringsToChars(value);
                end
                if ischar(value)
                    if ismember(lower(value), {'on', 'yes'})
                        mismatchOption = base_options(mismatchOption);
                    end
                else
                    error("baseOptions must be a string or char array.")
                end

            case 'blockIncludeList'
                if isstring(value)
                    value = convertStringsToChars(value);
                end
                if ischar(value)
                    value = {value};
                end
                if ~iscellstr(value)
                    error("Block list must be a string, string array, char array or cell array of char arrays.")
                end
                if ~isempty(mismatchOption.block_includelist)
                    warning("Duplicate blockIncludeList parameters call.")
                end
                mismatchOption.block_includelist = [mismatchOption.block_includelist, reshape(value, 1, [])];

            case 'blockExcludeList'
                if isstring(value)
                    value = convertStringsToChars(value);
                end
                if ischar(value)
                    value = {value};
                end
                if ~iscellstr(value)
                    error("Block list must be a string, string array, char array or cell array of char arrays.")
                end
                if ~isempty(mismatchOption.block_excludelist)
                    warning("Duplicate blockExcludeList parameters call.")
                end
                mismatchOption.block_excludelist = [mismatchOption.block_excludelist, reshape(value, 1, [])];

            case 'mismatchIncludeList'
                if isstring(value)
                    value = convertStringsToChars(value);
                end
                if ischar(value)
                    switch value 
                        case 'all'
                            mismatchOption.mismatch_includelist = {'all'};
                            continue;
                        otherwise
                            value = {value};
                    end
                end
                if ismember('all', mismatchOption.mismatch_includelist)
                    warning("Duplicate mismatchIncludeList parameters call after an 'all' call.")
                else
                    if ~iscellstr(value)
                        error("Block list must be a string, string array, char array or cell array of char arrays.")
                    end
                    if ~isempty(mismatchOption.mismatch_includelist)
                        warning("Duplicate mismatchIncludeList parameters call.")
                    end
                    mismatchOption.mismatch_includelist = [mismatchOption.mismatch_includelist, reshape(value, 1, [])];
                end

            case 'mismatchExcludeList'
                if isstring(value)
                    value = convertStringsToChars(value);
                end
                if ischar(value)
                    switch value 
                        case 'all'
                            mismatchOption.mismatch_excludelist = {'all'};
                            warning("mismatchExcludeList parameter received an 'all' call, no mismatch will be applied.")
                            continue;
                        otherwise
                            value = {value};
                    end
                end
                if ismember('all', mismatchOption.mismatch_excludelist)
                    warning("Duplicate mismatchExcludeList parameters call after an 'all' call.")
                else
                    if ~iscellstr(value)
                        error("Block list must be a string, string array, char array or cell array of char arrays.")
                    end
                    if ~isempty(mismatchOption.mismatch_excludelist)
                        warning("Duplicate mismatchExcludeList parameters call.")
                    end
                    mismatchOption.mismatch_excludelist = [mismatchOption.mismatch_excludelist, reshape(value, 1, [])];
                end

            case 'blockTypeIncludeList'
                if isstring(value)
                    value = convertStringsToChars(value);
                end
                if ischar(value)
                    switch value 
                        case 'all'
                            mismatchOption.blocktype_includelist = {'all'};
                            continue;
                        otherwise
                            value = {value};
                    end
                end
                if ismember('all', mismatchOption.blocktype_includelist)
                    warning("Duplicate blockTypeIncludeList parameters call after an 'all' call.")
                else
                    if ~iscellstr(value)
                        error("Block list must be a string, string array, char array or cell array of char arrays.")
                    end
                    if ~isempty(mismatchOption.blocktype_includelist)
                        warning("Duplicate blockTypeIncludeList parameters call.")
                    end
                    mismatchOption.blocktype_includelist = [mismatchOption.blocktype_includelist, reshape(value, 1, [])];
                end

            case 'blockTypeExcludeList'
                if isstring(value)
                    value = convertStringsToChars(value);
                end
                if ischar(value)
                    switch value 
                        case 'all'
                            mismatchOption.blocktype_excludelist = {'all'};
                            warning("blockTypeExcludeList parameter received an 'all' call, only blocks in blockIncludeList will be mismatched.")
                            continue;
                        otherwise
                            value = {value};
                    end
                end
                if ismember('all', mismatchOption.blocktype_excludelist)
                    warning("Duplicate blockTypeExcludeList parameters call after an 'all' call.")
                else
                    if ~iscellstr(value)
                        error("Block list must be a string, string array, char array or cell array of char arrays.")
                    end
                    if ~isempty(mismatchOption.blocktype_excludelist)
                        warning("Duplicate blockTypeExcludeList parameters call.")
                    end
                    mismatchOption.blocktype_excludelist = [mismatchOption.blocktype_excludelist, reshape(value, 1, [])];
                end

            case 'simParamList'
                if ~isstruct(value) || length(value) ~= 1
                    error("Param list must be a single struct.")
                end

                if isempty(fieldnames(mismatchOption.params))
                    mismatchOption.params = value;
                else
                    warning("Duplicate simParamList parameters call.")
                    fields = fieldnames(value);
                    for j = 1:length(fields)
                        if isfield(mismatchOption.params, fields{j})
                            warning(['Erasing value "' fields{j} '" due to duplicate simParamList parameters call.'])
                        end
                        mismatchOption.params.(fields{j}) = value.(fields{j});
                    end
                end

            case 'mismatchFunctions'
                if ~isa(value, 'containers.Map')
                    error("mismatchFunctions must be a containers.Map.")
                end
                
                newKeys = keys(value);
                for j = 1:length(newKeys)
                    if mismatchOption.mismatch_func_map.isKey(newKeys{j})
                        warning(['Overwriting mismatch function for "' newKeys{j} '" block.'])
                    end
                    if ~isa(value(newKeys{j}), 'containers.Map')
                        error("mismatchFunctions containers.Map must have containers.Map values.")
                    end
                    mismatchOption.mismatch_func_map(newKeys{j}) = value(newKeys{j});
                end

            otherwise
                warning(['Key "' key '" not supported.'])
        end
    end

    mismatchOption.block_includelist = unique(mismatchOption.block_includelist);
    mismatchOption.block_includelist = mismatchOption.block_includelist(~cellfun(@isempty, mismatchOption.block_includelist));

    mismatchOption.block_excludelist = unique(mismatchOption.block_excludelist);
    mismatchOption.block_excludelist = mismatchOption.block_excludelist(~cellfun(@isempty, mismatchOption.block_excludelist));

    mismatchOption.blocktype_includelist = unique(mismatchOption.blocktype_includelist);
    mismatchOption.blocktype_includelist = mismatchOption.blocktype_includelist(~cellfun(@isempty, mismatchOption.blocktype_includelist));

    mismatchOption.blocktype_excludelist = unique(mismatchOption.blocktype_excludelist);
    mismatchOption.blocktype_excludelist = mismatchOption.blocktype_excludelist(~cellfun(@isempty, mismatchOption.blocktype_excludelist));

    mismatchOption.mismatch_includelist = unique(mismatchOption.mismatch_includelist);
    mismatchOption.mismatch_includelist = mismatchOption.mismatch_includelist(~cellfun(@isempty, mismatchOption.mismatch_includelist));

    mismatchOption.mismatch_excludelist = unique(mismatchOption.mismatch_excludelist);
    mismatchOption.mismatch_excludelist = mismatchOption.mismatch_excludelist(~cellfun(@isempty, mismatchOption.mismatch_excludelist));
end

