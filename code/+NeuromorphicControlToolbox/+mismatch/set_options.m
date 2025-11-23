function MismatchOptionStruct = set_options(varargin)
    varg = varargin;
    if mod(length(varargin),2) ~= 0
        if isstruct(varg{1}) && length(varg{1}) == 1 && isfield(varg{1},'MismatchOptionStruct')
            MismatchOptionStruct = varg{1};
            varg = varg(2:end);
        else
            error("Arguments must be pairs or the first can be an existing MismatchOptionStruct")
        end
    else
        MismatchOptionStruct = struct('MismatchOptionStruct', 1);
        MismatchOptionStruct.mismatch_func_map = containers.Map();
        MismatchOptionStruct.block_includelist = {};
        MismatchOptionStruct.block_excludelist = {};
        MismatchOptionStruct.mismatch_includelist = {};
        MismatchOptionStruct.mismatch_excludelist = {};
        MismatchOptionStruct.blocktype_includelist = {};
        MismatchOptionStruct.blocktype_excludelist = {};
        MismatchOptionStruct.params = struct();
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
                if ~isempty(MismatchOptionStruct.block_includelist)
                    warning("Duplicate blockIncludeList parameters call.")
                end
                MismatchOptionStruct.block_includelist = [MismatchOptionStruct.block_includelist, reshape(value, 1, [])];

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
                if ~isempty(MismatchOptionStruct.block_excludelist)
                    warning("Duplicate blockExcludeList parameters call.")
                end
                MismatchOptionStruct.block_excludelist = [MismatchOptionStruct.block_excludelist, reshape(value, 1, [])];

            case 'mismatchIncludeList'
                if isstring(value)
                    value = convertStringsToChars(value);
                end
                if ischar(value)
                    switch value 
                        case 'all'
                            MismatchOptionStruct.mismatch_includelist = {'all'};
                            continue;
                        otherwise
                            value = {value};
                    end
                end
                if ismember('all', MismatchOptionStruct.mismatch_includelist)
                    warning("Duplicate mismatchIncludeList parameters call after an 'all' call.")
                else
                    if ~iscellstr(value)
                        error("Block list must be a string, string array, char array or cell array of char arrays.")
                    end
                    if ~isempty(MismatchOptionStruct.mismatch_includelist)
                        warning("Duplicate mismatchIncludeList parameters call.")
                    end
                    MismatchOptionStruct.mismatch_includelist = [MismatchOptionStruct.mismatch_includelist, reshape(value, 1, [])];
                end

            case 'mismatchExcludeList'
                if isstring(value)
                    value = convertStringsToChars(value);
                end
                if ischar(value)
                    switch value 
                        case 'all'
                            MismatchOptionStruct.mismatch_excludelist = {'all'};
                            warning("mismatchExcludeList parameter received an 'all' call, no mismatch will be applied.")
                            continue;
                        otherwise
                            value = {value};
                    end
                end
                if ismember('all', MismatchOptionStruct.mismatch_excludelist)
                    warning("Duplicate mismatchExcludeList parameters call after an 'all' call.")
                else
                    if ~iscellstr(value)
                        error("Block list must be a string, string array, char array or cell array of char arrays.")
                    end
                    if ~isempty(MismatchOptionStruct.mismatch_excludelist)
                        warning("Duplicate mismatchExcludeList parameters call.")
                    end
                    MismatchOptionStruct.mismatch_excludelist = [MismatchOptionStruct.mismatch_excludelist, reshape(value, 1, [])];
                end

            case 'blockTypeIncludeList'
                if isstring(value)
                    value = convertStringsToChars(value);
                end
                if ischar(value)
                    switch value 
                        case 'all'
                            MismatchOptionStruct.blocktype_includelist = {'all'};
                            continue;
                        otherwise
                            value = {value};
                    end
                end
                if ismember('all', MismatchOptionStruct.blocktype_includelist)
                    warning("Duplicate blockTypeIncludeList parameters call after an 'all' call.")
                else
                    if ~iscellstr(value)
                        error("Block list must be a string, string array, char array or cell array of char arrays.")
                    end
                    if ~isempty(MismatchOptionStruct.blocktype_includelist)
                        warning("Duplicate blockTypeIncludeList parameters call.")
                    end
                    MismatchOptionStruct.blocktype_includelist = [MismatchOptionStruct.blocktype_includelist, reshape(value, 1, [])];
                end

            case 'blockTypeExcludeList'
                if isstring(value)
                    value = convertStringsToChars(value);
                end
                if ischar(value)
                    switch value 
                        case 'all'
                            MismatchOptionStruct.blocktype_excludelist = {'all'};
                            warning("blockTypeExcludeList parameter received an 'all' call, only blocks in blockIncludeList will be mismatched.")
                            continue;
                        otherwise
                            value = {value};
                    end
                end
                if ismember('all', MismatchOptionStruct.blocktype_excludelist)
                    warning("Duplicate blockTypeExcludeList parameters call after an 'all' call.")
                else
                    if ~iscellstr(value)
                        error("Block list must be a string, string array, char array or cell array of char arrays.")
                    end
                    if ~isempty(MismatchOptionStruct.blocktype_excludelist)
                        warning("Duplicate blockTypeExcludeList parameters call.")
                    end
                    MismatchOptionStruct.blocktype_excludelist = [MismatchOptionStruct.blocktype_excludelist, reshape(value, 1, [])];
                end

            case 'simParamList'
                if ~isstruct(value) || length(value) ~= 1
                    error("Param list must be a single struct.")
                end

                if isempty(fieldnames(MismatchOptionStruct.params))
                    MismatchOptionStruct.params = value;
                else
                    warning("Duplicate simParamList parameters call.")
                    fields = fieldnames(value);
                    for j = 1:length(fields)
                        if isfield(MismatchOptionStruct.params, fields{j})
                            warning(['Erasing value "' fields{j} '" due to duplicate simParamList parameters call.'])
                        end
                        MismatchOptionStruct.params.(fields{j}) = value.(fields{j});
                    end
                end

            case 'mismatchFunctions'
                if ~isa(value, 'containers.Map')
                    error("mismatchFunctions must be a containers.Map.")
                end
                
                newKeys = keys(value);
                for j = 1:length(newKeys)
                    if MismatchOptionStruct.mismatch_func_map.isKey(newKeys{j})
                        warning(['Overwriting mismatch function for "' newKeys{j} '" block.'])
                    end
                    if ~isa(value(newKeys{j}), 'containers.Map')
                        error("mismatchFunctions containers.Map must have containers.Map values.")
                    end
                    MismatchOptionStruct.mismatch_func_map(newKeys{j}) = value(newKeys{j});
                end

            otherwise
                warning(['Key "' key '" not supported.'])
        end
    end

    MismatchOptionStruct.block_includelist = unique(MismatchOptionStruct.block_includelist);
    MismatchOptionStruct.block_includelist = MismatchOptionStruct.block_includelist(~cellfun(@isempty, MismatchOptionStruct.block_includelist));

    MismatchOptionStruct.block_excludelist = unique(MismatchOptionStruct.block_excludelist);
    MismatchOptionStruct.block_excludelist = MismatchOptionStruct.block_excludelist(~cellfun(@isempty, MismatchOptionStruct.block_excludelist));

    MismatchOptionStruct.blocktype_includelist = unique(MismatchOptionStruct.blocktype_includelist);
    MismatchOptionStruct.blocktype_includelist = MismatchOptionStruct.blocktype_includelist(~cellfun(@isempty, MismatchOptionStruct.blocktype_includelist));

    MismatchOptionStruct.blocktype_excludelist = unique(MismatchOptionStruct.blocktype_excludelist);
    MismatchOptionStruct.blocktype_excludelist = MismatchOptionStruct.blocktype_excludelist(~cellfun(@isempty, MismatchOptionStruct.blocktype_excludelist));

    MismatchOptionStruct.mismatch_includelist = unique(MismatchOptionStruct.mismatch_includelist);
    MismatchOptionStruct.mismatch_includelist = MismatchOptionStruct.mismatch_includelist(~cellfun(@isempty, MismatchOptionStruct.mismatch_includelist));

    MismatchOptionStruct.mismatch_excludelist = unique(MismatchOptionStruct.mismatch_excludelist);
    MismatchOptionStruct.mismatch_excludelist = MismatchOptionStruct.mismatch_excludelist(~cellfun(@isempty, MismatchOptionStruct.mismatch_excludelist));
end

