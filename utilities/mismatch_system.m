function simins = mismatch_system(model, mismatch_width, mismatch_std, varargin)
    %MISMATCH_SYSTEM Add mismatch to all neuromorphic blocks of a simulink model
    %   Detailed explanation goes here
    
    % block_type_list, block_whitelist, block_blacklist, mismatch_list, params, sims_or_nb_sims
    if nargin < 3
        error("mismatch_system requires at least 3 arguments (model, mismatch width, mismatch_std)")
    end

    [simins, block_includelist, block_excludelist, blocktype_includelist, mismatch_list, mismatch_func_map, params] = parse_input(model, varargin, mismatch_width, mismatch_std);

    param_fields = fieldnames(params);
    if ~isempty(param_fields)
        model_work = get_param(model,'ModelWorkspace');
        old_model_work.DataSource = model_work.DataSource;
        try
            old_model_work.FileName = model_work.FileName;
        catch
        end
        try
            old_model_work.EnableValueSource = model_work.EnableValueSource;
        catch
        end
        try
            old_model_work.ValueSourceFile = model_work.ValueSourceFile;
        catch
        end
        try
            old_model_work.MATLABCode = model_work.MATLABCode;
        catch
        end
        model_work.DataSource = 'MAT-File';
        tempfile = [tempname, '.mat'];
        model_work.FileName = tempfile;
        saveToSource(model_work)
    
        for i = 1:length(param_fields)
            name = param_fields{i};
            for j = 1:length(simins)
                simins(j) = simins(j).setVariable(name, params.(name), "Workspace", model);
            end
            model_work.assignin(name,params.(name));
        end
    end

    all_blocks = find_system(model, 'LookUnderMasks', 'off', 'FollowLinks', 'on');

    simins = apply_mismatch_to_simins(simins, all_blocks, model_work, block_includelist, block_excludelist, blocktype_includelist, mismatch_list, mismatch_func_map);

    if ~isempty(param_fields)
        reload(model_work);
        model_work.DataSource = old_model_work.DataSource;
        try
            model_work.FileName = old_model_work.FileName;
        catch 
        end
        try
            model_work.EnableValueSource = old_model_work.EnableValueSource;
        catch 
        end
        try
            model_work.ValueSourceFile = old_model_work.ValueSourceFile;
        catch
        end
        try
            model_work.MATLABCode = old_model_work.MATLABCode;
        catch
        end
        
        delete(tempfile)
    end
end


function [simins, block_includelist, block_excludelist, blocktype_includelist, mismatch_list, mismatch_func_map, params] = parse_input(model, varg, mismatch_width, mismatch_std)
    mismatch_func_map = get_type_mismatch_func_map(mismatch_width, mismatch_std);
    full_mismatch_list = {'gain', 'mod_gain', 'bias', 'slope', 'timescale'};
    

    sims_or_nb_sims = [];
    block_includelist = {};
    block_excludelist = {};
    mismatch_list = {};
    blocktype_includelist = {};
    params = struct();
    

    if mod(length(varg),2) ~= 0
        if ~ismember(class(varg{1}), {'Simulink.SimulationInput'}) && (~isnumeric(varg{1}) || length(varg{1}) ~= 1 || varg{1} < 1 || rem(varg{1},1) ~= 0)
            error("Arguments must be pairs or the first can be the simulation input data (positive integer or Simulink.SimulationInput)")
        else
            sims_or_nb_sims = varg{1};
            varg = varg(2:end);
        end
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
                if ~isempty(block_includelist)
                    warning("Duplicate blockIncludeList parameters call.")
                end
                block_includelist = [block_includelist, reshape(value, 1, [])];

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
                if ~isempty(block_excludelist)
                    warning("Duplicate blockExcludeList parameters call.")
                end
                block_excludelist = [block_excludelist, reshape(value, 1, [])];

            case 'mismatchList'
                if isstring(value)
                    value = convertStringsToChars(value);
                end
                if ischar(value)
                    switch value 
                        case 'all'
                            mismatch_list = 'all';
                        otherwise
                            value = {value};
                    end
                end
                if ischar(mismatch_list)
                    warning("Duplicate mismatchList parameters call after an 'all' call.")
                else
                    if ~iscellstr(value)
                        error("Block list must be a string, string array, char array or cell array of char arrays.")
                    end
                    if ~isempty(mismatch_list)
                        warning("Duplicate mismatchList parameters call.")
                    end
                    mismatch_list = [mismatch_list, reshape(value, 1, [])];
                end

            case 'blockTypeIncludeList'
                if isstring(value)
                    value = convertStringsToChars(value);
                end
                if ischar(value)
                    switch value 
                        case 'all'
                            blocktype_includelist = 'all';
                        otherwise
                            value = {value};
                    end
                end
                if ischar(blocktype_includelist)
                    warning("Duplicate blockTypeIncludeList parameters call after an 'all' call.")
                else
                    if ~iscellstr(value)
                        error("Block list must be a string, string array, char array or cell array of char arrays.")
                    end
                    if ~isempty(blocktype_includelist)
                        warning("Duplicate blockTypeIncludeList parameters call.")
                    end
                    blocktype_includelist = [blocktype_includelist, reshape(value, 1, [])];
                end

            case 'paramList'
                if ~isstruct(value) || length(value) ~= 1
                    error("Param list must be a signle struct.")
                end

                if isempty(fieldnames(params))
                    params = value;
                else
                    warning("Duplicate paramList parameters call.")
                    fields = fieldnames(value);
                    for j = 1:length(fields)
                        if isfield(params, fields{j})
                            warning(['Erasing value "' fields{j} '" due to duplicate paramList parameters call.'])
                        end
                        params.(fields{j}) = value.(fields{j});
                    end
                end

            case 'nbSimin'
                if ~isinteger(value) || length(value) ~= 1 || value < 1 || rem(value,1) ~= 0
                    error("Number of simin must be a positive integer.")
                end
                
                if ~isempty(sims_or_nb_sims)
                    warning("Overwriting previous simulation input parameter for an Integer.")
                end
                sims_or_nb_sims = value;

            case 'siminArray'
                if ~isa(value, 'Simulink.SimulationInput')
                    error("Array of simin must be a Simulink.SimulationInput array.")
                end
                
                if ~isempty(sims_or_nb_sims)
                    warning("Overwriting previous simulation input parameter  for a Simulink.SimulationInput.")
                end
                sims_or_nb_sims = value;

            case 'additionalMismatchFunctions'
                if ~isa(value, 'containers.Map')
                    error("Mismatch functions must contained in a containers.Map.")
                end
                
                newKeys = keys(value);
                for j = 1:length(newKeys)
                    if mismatch_func_map.isKey(newKeys{j})
                        warning(['Overwriting mismatch function for "' newKeys{j} '" block.'])
                    end
                    if ~isa(value(newKeys{j}), 'function_handle')
                        error("Mismatch functions containers.Map must have function_handle values.")
                    end
                    mismatch_func_map(newKeys{j}) = value(newKeys{j});
                end

            otherwise
                warning(['Key "' key '" not supported.'])
        end
    end

    full_type_list = keys(mismatch_func_map);
    full_type_dict = containers.Map(lower(full_type_list), full_type_list);

    block_includelist = unique(block_includelist);
    block_includelist = block_includelist(~cellfun(@isempty, block_includelist));

    block_excludelist = unique(block_excludelist);
    block_excludelist = block_excludelist(~cellfun(@isempty, block_excludelist));

    if isempty(mismatch_list)
        mismatch_list = full_mismatch_list;
    else
        if ischar(blocktype_includelist)
            mismatch_list = full_mismatch_list;
        else
            mismatch_list = lower(mismatch_list);
            mismatch_list = unique(mismatch_list);
            mismatch_list = mismatch_list(~cellfun(@isempty, mismatch_list));
        end
    end

    if isempty(blocktype_includelist)
        blocktype_includelist = full_type_list;
    else
        if ischar(blocktype_includelist)
            blocktype_includelist = keys(mismatch_func_map);
        else
            blocktype_includelist = lower(blocktype_includelist);
            blocktype_includelist = unique(blocktype_includelist);
            blocktype_includelist = blocktype_includelist(~cellfun(@isempty, blocktype_includelist));
            for i = 1:length(blocktype_includelist)
                if full_type_dict.isKey(blocktype_includelist{i})
                     blocktype_includelist{i} = full_type_dict(blocktype_includelist{i});
                end
            end
        end
    end

    if isempty(sims_or_nb_sims)
        sims_or_nb_sims = 1;
    end
    if isa(sims_or_nb_sims, 'Simulink.SimulationInput')
        simins = sims_or_nb_sims;
    else
        simins(1:sims_or_nb_sims) = Simulink.SimulationInput(model);
    end
end

function simins = apply_mismatch_to_simins(simins, all_blocks, model_work, block_includelist, block_excludelist, blocktype_includelist, mismatch_list, mismatch_func_map)
    for i = 1:length(all_blocks)
        blPath = all_blocks{i};
        try
            type = get_param(blPath, 'MaskType');
        catch 
            type = '';
        end 
        try
            name = get_param(blPath, 'Name');
        catch 
            name = '';
        end 
        
        if ~ismember(name, block_excludelist) && (ismember(name, block_includelist) || ismember(type, blocktype_includelist))
            if mismatch_func_map.isKey(type)
                func = mismatch_func_map(type);
                simins = func(blPath, simins, model_work, mismatch_list);
            else
                warning(['Block "' blPath '" has type "' type '" which is not a supported type.'])
            end
        end
    end
end



function type_to_mismatch_func = get_type_mismatch_func_map(mismatch_width, mismatch_std)
    type_to_mismatch_func = containers.Map( ...
        {'Tunable Sigmoid', 'First Order Lag', 'Neuron', 'Synapse with Facilitation', 'Synapse with Depression', 'Modulatory Synapse', 'Event Demux', 'Event Mux', 'Continuous to Event', 'Event to Continuous'},...
        { ...
            @(blPath, simins, model_work, mismatch_list) mismatch_tunable_sigmoid(blPath, simins, model_work, mismatch_list, mismatch_width, mismatch_std), ...
            @(blPath, simins, model_work, mismatch_list) mismatch_first_order_lag(blPath, simins, model_work, mismatch_list, mismatch_width, mismatch_std), ...
            @(blPath, simins, model_work, mismatch_list) mismatch_neuron(blPath, simins, model_work, mismatch_list, mismatch_width, mismatch_std), ...
            @(blPath, simins, model_work, mismatch_list) mismatch_synapse_with_facilitation(blPath, simins, model_work, mismatch_list, mismatch_width, mismatch_std), ...
            @(blPath, simins, model_work, mismatch_list) mismatch_synapse_with_depression(blPath, simins, model_work, mismatch_list, mismatch_width, mismatch_std), ...
            @(blPath, simins, model_work, mismatch_list) mismatch_modulatory_synapse(blPath, simins, model_work, mismatch_list, mismatch_width, mismatch_std), ...
            @(blPath, simins, model_work, mismatch_list) mismatch_event_demux(blPath, simins, model_work, mismatch_list, mismatch_width, mismatch_std), ...
            @(blPath, simins, model_work, mismatch_list) mismatch_event_mux(blPath, simins, model_work, mismatch_list, mismatch_width, mismatch_std), ...
            @(blPath, simins, model_work, mismatch_list) mismatch_continuous_to_event(blPath, simins, model_work, mismatch_list, mismatch_width, mismatch_std), ...
            @(blPath, simins, model_work, mismatch_list) mismatch_event_to_continuous(blPath, simins, model_work, mismatch_list, mismatch_width, mismatch_std) ...
        }...
     );
end


function simins = mismatch_tunable_sigmoid(blPath, simins, model_work, mismatch_list, mismatch_width, mismatch_std)
    if ismember('gain', mismatch_list)
        gain_list = {'gain'};
        simins = mismatch_params_from_list(model_work, blPath, simins, gain_list, @(value) monteLogCutNormal(value,mismatch_std,mismatch_width));
    end
    if ismember('bias', mismatch_list)
        bias_list = {'bias'};
        simins = mismatch_params_from_list(model_work, blPath, simins, bias_list, @(value) monteCutNormal(value,mismatch_std,mismatch_width));
    end
    if ismember('slope', mismatch_list)
        slope_list = {'slope'};
        simins = mismatch_params_from_list(model_work, blPath, simins, slope_list, @(value) monteLogCutNormal(value,mismatch_std,mismatch_width));
    end
end

function simins = mismatch_first_order_lag(blPath, simins, model_work, mismatch_list, mismatch_width, mismatch_std)
    if ismember('gain', mismatch_list)
        gain_list = {'gain'};
        simins = mismatch_params_from_list(model_work, blPath, simins, gain_list, @(value) monteLogCutNormal(value,mismatch_std,mismatch_width));
    end
    if ismember('timescale', mismatch_list)
        timescale_list = {'rel_timescale'};
        simins = mismatch_params_from_list(model_work, blPath, simins, timescale_list, @(value) monteLogCutNormal(value,mismatch_std,mismatch_width));
    end
end

function simins = mismatch_neuron(blPath, simins, model_work, mismatch_list, mismatch_width, mismatch_std)
    if ismember('gain', mismatch_list)
        gain_list = {'gfm', 'gsp', 'gsm', 'gup', 'gum'};
        simins = mismatch_params_from_list(model_work, blPath, simins, gain_list, @(value) monteLogCutNormal(value,mismatch_std,mismatch_width));
    end
    if ismember('bias', mismatch_list)
        bias_list = {'dfm', 'dsp', 'dsm', 'dup', 'dum', 'Iapp_base', 'tresh'};
        simins = mismatch_params_from_list(model_work, blPath, simins, bias_list, @(value) monteCutNormal(value,mismatch_std,mismatch_width));
    end
    if ismember('slope', mismatch_list)
        slope_list = {'mfm', 'msp', 'msm', 'mup', 'mum'};
        simins = mismatch_params_from_list(model_work, blPath, simins, slope_list, @(value) monteLogCutNormal(value,mismatch_std,mismatch_width));
    end
    if ismember('timescale', mismatch_list)
        timescale_list = {'rel_membrane', 'rel_fast', 'rel_slow', 'rel_ultraslow'};
        simins = mismatch_params_from_list(model_work, blPath, simins, timescale_list, @(value) monteLogCutNormal(value,mismatch_std,mismatch_width));
    end
end

function simins = mismatch_synapse_with_facilitation(blPath, simins, model_work, mismatch_list, mismatch_width, mismatch_std)
    if ismember('gain', mismatch_list)
        gain_list = {'gsyn', 'gsyn_in'};
        simins = mismatch_params_from_list(model_work, blPath, simins, gain_list, @(value) monteLogCutNormal(value,mismatch_std,mismatch_width));
    end
    if ismember('bias', mismatch_list)
        bias_list = {'dsyn', 'dsyn_in'};
        simins = mismatch_params_from_list(model_work, blPath, simins, bias_list, @(value) monteCutNormal(value,mismatch_std,mismatch_width));
    end
    if ismember('slope', mismatch_list)
        slope_list = {'msyn', 'msyn_in'};
        simins = mismatch_params_from_list(model_work, blPath, simins, slope_list, @(value) monteLogCutNormal(value,mismatch_std,mismatch_width));
    end
    if ismember('timescale', mismatch_list)
        timescale_list = {'rel_timescale'};
        simins = mismatch_params_from_list(model_work, blPath, simins, timescale_list, @(value) monteLogCutNormal(value,mismatch_std,mismatch_width));
    end
end

function simins = mismatch_synapse_with_depression(blPath, simins, model_work, mismatch_list, mismatch_width, mismatch_std)
    if ismember('gain', mismatch_list)
        gain_list = {'gsyn', 'gsyn_in'};
        simins = mismatch_params_from_list(model_work, blPath, simins, gain_list, @(value) monteLogCutNormal(value,mismatch_std,mismatch_width));
    end
    if ismember('bias', mismatch_list)
        bias_list = {'dsyn', 'dsyn_in', 'dsyn_dep'};
        simins = mismatch_params_from_list(model_work, blPath, simins, bias_list, @(value) monteCutNormal(value,mismatch_std,mismatch_width));
    end
    if ismember('slope', mismatch_list)
        slope_list = {'msyn', 'msyn_in', 'msyn_dep'};
        simins = mismatch_params_from_list(model_work, blPath, simins, slope_list, @(value) monteLogCutNormal(value,mismatch_std,mismatch_width));
    end
    if ismember('timescale', mismatch_list)
        timescale_list = {'rel_timescale'};
        simins = mismatch_params_from_list(model_work, blPath, simins, timescale_list, @(value) monteLogCutNormal(value,mismatch_std,mismatch_width));
    end
end

function simins = mismatch_modulatory_synapse(blPath, simins, model_work, mismatch_list, mismatch_width, mismatch_std)
    if ismember('gain', mismatch_list)
        gain_list = {'gsyn_pos','gsyn_neg'};
        simins = mismatch_params_from_list(model_work, blPath, simins, gain_list, @(value) monteLogCutNormal(value,mismatch_std,mismatch_width));
    end
    if ismember('mod_gain', mismatch_list)
        gain_list = {'base_val'};
        simins = mismatch_params_from_list(model_work, blPath, simins, gain_list, @(value) monteLogCutNormal(value,mismatch_std,mismatch_width));
    end
    if ismember('bias', mismatch_list)
        bias_list = {'dsyn_pos', 'dsyn_neg'};
        simins = mismatch_params_from_list(model_work, blPath, simins, bias_list, @(value) monteCutNormal(value,mismatch_std,mismatch_width));
    end
    if ismember('slope', mismatch_list)
        slope_list = {'msyn_pos', 'msyn_neg'};
        simins = mismatch_params_from_list(model_work, blPath, simins, slope_list, @(value) monteLogCutNormal(value,mismatch_std,mismatch_width));
    end
    if ismember('timescale', mismatch_list)
        timescale_list = {'rel_timescale'};
        simins = mismatch_params_from_list(model_work, blPath, simins, timescale_list, @(value) monteLogCutNormal(value,mismatch_std,mismatch_width));
    end
end

function simins = mismatch_event_demux(blPath, simins, model_work, mismatch_list, mismatch_width, mismatch_std)
    if ismember('gain', mismatch_list)
        gain_list = {'gsyn_pos', 'gsyn_neg'};
        simins = mismatch_params_from_list(model_work, blPath, simins, gain_list, @(value) monteLogCutNormal(value,mismatch_std,mismatch_width));
    end
    if ismember('bias', mismatch_list)
        bias_list = {'dsyn_signal_pos', 'dsyn_signal_neg', 'dsyn_event_pos', 'dsyn_event_neg'};
        simins = mismatch_params_from_list(model_work, blPath, simins, bias_list, @(value) monteCutNormal(value,mismatch_std,mismatch_width));
    end
    if ismember('slope', mismatch_list)
        slope_list = {'gain_signal_pos', 'gain_signal_neg', 'gain_event_pos', 'gain_event_neg'};
        simins = mismatch_params_from_list(model_work, blPath, simins, slope_list, @(value) monteLogCutNormal(value,mismatch_std,mismatch_width));
    end
end

function simins = mismatch_event_mux(blPath, simins, model_work, mismatch_list, mismatch_width, mismatch_std)
    if ismember('gain', mismatch_list)
        gain_list = {'gsyn_pos', 'gsyn_neg'};
        simins = mismatch_params_from_list(model_work, blPath, simins, gain_list, @(value) monteLogCutNormal(value,mismatch_std,mismatch_width));
    end
    if ismember('bias', mismatch_list)
        bias_list = {'dsyn_signal_pos', 'dsyn_signal_neg', 'dsyn_event_pos', 'dsyn_event_neg'};
        simins = mismatch_params_from_list(model_work, blPath, simins, bias_list, @(value) monteCutNormal(value,mismatch_std,mismatch_width));
    end
    if ismember('slope', mismatch_list)
        slope_list = {'gain_signal_pos', 'gain_signal_neg', 'gain_event_pos', 'gain_event_neg'};
        simins = mismatch_params_from_list(model_work, blPath, simins, slope_list, @(value) monteLogCutNormal(value,mismatch_std,mismatch_width));
    end
end

function simins = mismatch_continuous_to_event(blPath, simins, model_work, mismatch_list, mismatch_width, mismatch_std)
    if ismember('bias', mismatch_list)
        bias_list = {'tresh'};
        simins = mismatch_params_from_list(model_work, blPath, simins, bias_list, @(value) monteCutNormal(value,mismatch_std,mismatch_width));
    end
end

function simins = mismatch_event_to_continuous(blPath, simins, model_work, mismatch_list, mismatch_width, mismatch_std)
    if ismember('gain', mismatch_list)
        gain_list = {'gain'};
        simins = mismatch_params_from_list(model_work, blPath, simins, gain_list, @(value) monteLogCutNormal(value,mismatch_std,mismatch_width));
    end
end


function simins = mismatch_params_from_list(model_work,blPath,simins,list,rand_func)
    for p = list
        try
            value = model_work.evalin(get_param(blPath, p{1}));
        catch E
            error(['Param value "' p{1} '" from block "' blPath '" cannot be evaluated.']);
        end
        for j = 1:length(simins)
            new_value = rand_func(value);
            simins(j) = simins(j).setBlockParameter(blPath, p{1}, num2str(new_value, '%.5e'));
        end
    end
end

function value = monteLogCutNormal(center, log_stddev, log_span)
    if 0 > log_stddev
        error("monteLogCUtNormal expected log_stddev >= 0");
    end
    if 0 > log_span
        error("monteLogCUtNormal expected log_span >= 0");
    end
    value = center * 10^distrib(log_stddev,log_span/2);
end

function value = monteCutNormal(center, stddev, span)
    if 0 > stddev
        error("monteCUtNormal expected stddev >= 0");
    end
    if 0 > span
        error("monteCUtNormal expected span >= 0");
    end
    value = center + distrib(stddev,span/2);
end

function r = distrib(stddev, cutoff)
	r = stddev*randn(); % Normally distributed ~ N(0,std^2)
    if r < -cutoff || r > cutoff
        r = (rand() - 0.5)*2*cutoff; % Uniformly distributed ~ U(-cutoff, cutoff)
    end
end