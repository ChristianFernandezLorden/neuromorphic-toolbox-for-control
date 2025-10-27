function simins = apply_to_system(model, mismatchParams, varargin)
    % Add mismatch to all neuromorphic blocks of a simulink model.
    %
    % Description
    % -----------
    %   simIn = apply_to_system(model, mismatchParams)
    %       Use the base mismatchOption defined by :func:`base_options` and generate
    %       a single Simulink.SimulationInput with mismatch applied.
    %
    %   simIn = apply_to_system(model, mismatchParams, nbSim)
    %       Use the base mismatchOption defined by :func:`base_options` and generate
    %       a nbSim Simulink.SimulationInput with mismatch applied.
    %
    %   simIn = apply_to_system(model, mismatchParams, simIn)
    %       Use the base mismatchOption defined by :func:`base_options` and returns
    %       the input Simulink.SimulationInput with mismatch applied.
    %
    %   simIn = apply_to_system(__, mismatchOption)
    %       Give a custom mismatchOption that replaces the base mismatchOption.
    %
    %   simIn = apply_to_system(__, name, value, ...)
    %       Create a custom mismatchOption that replaces the base mismatchOption using
    %       the syntax of :func:`set_options`.
    %
    %   simIn = apply_to_system(__, mismatchOption, name, value)
    %       Give a custom mismatchOption that replaces the base mismatchOption and 
    %       apply the name-value options using the syntax of :func:`set_options`.
    % Inputs
    % ------
    %   model: char or string
    %       Name of the model to mismatch.
    %   mismatchParams: struct
    %       Parameter dictionary that is passed to the internal mismatch functions.
    %       Pass and empty dictionary with ``struct()`` if unecessary.
    %   nbSim: int
    %       Number of Simulink.SimulationInput to generate.
    %   simIn: Simulink.SimulationInput
    %       Simulink.SimulationInput configuration to apply the mismatch to.
    %
    % Optional Input
    % --------------
    %   Name: char or string
    %       Name of the option to set.
    %   Value: misc
    %       Value of the option to set.
    %   MismatchOptionStruct: struct
    %       Preexisting MismatchOptionStruct.
    %
    % Output
    % ------
    %   simIn: Simulink.SimulationInput
    %       Resulting SimulationInput configuration.
    %
    % :Name-Value Inputs:
    %   see :func:`set_options`
    
    if nargin < 2
        error("apply_to_system requires at least 2 arguments (model, mismatchParams)")
    end

    load_system(model);

    [simins, options] = parse_input(model, varargin);
    
    param_fields = fieldnames(options.params);
    model_work = get_param(model,'ModelWorkspace');
    if ~isempty(param_fields)
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
                simins(j) = simins(j).setVariable(name, options.params.(name), "Workspace", model);
            end
            model_work.assignin(name,params.(name));
        end
    end

    all_blocks = find_system(model, 'LookUnderMasks', 'off', 'FollowLinks', 'on');

    simins = apply_mismatch_to_simins(simins, all_blocks, model_work, options, mismatchParams);

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

    save_system(model);
end


function [simins, options] = parse_input(model, varg)
    import NeuromorphicControlToolbox.mismatch.*
    
    sims_or_nb_sims = [];
    if ismember(class(varg{1}), {'Simulink.SimulationInput'}) || (isnumeric(varg{1}) && length(varg{1}) == 1 && varg{1} >= 1 && rem(varg{1},1) == 0)
        sims_or_nb_sims = varg{1};
        varg = varg(2:end);
    end

    options = set_options(varg{:});
    
    if ismember('all', options.mismatch_excludelist)
        options.mismatch_list = {};
    else
        if ismember('all', options.mismatch_includelist)
            list = {};
            for values_cell = values(options.mismatch_func_map)
                list = union(list, keys(values_cell{1}));
            end
            options.mismatch_list = setdiff(list, options.mismatch_excludelist);
        else
            options.mismatch_list = setdiff(options.mismatch_includelist, options.mismatch_excludelist);
        end
    end

    if ismember('all', options.blocktype_excludelist)
        options.blocktype_list = {};
    else
        if ismember('all', options.blocktype_includelist)
            list = keys(options.mismatch_func_map);
            options.blocktype_list = setdiff(list, options.blocktype_excludelist);
        else
            options.blocktype_list = setdiff(options.blocktype_includelist, options.blocktype_excludelist);
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

function simins = apply_mismatch_to_simins(simins, all_blocks, model_work, options, mismatchParams)
    for i = 1:length(all_blocks)
        blPath = all_blocks{i};
        try
            type = get_param(blPath, 'MaskType');
        catch 
            type = '';
        end 

        if isempty(type)
            try
                type = get_param(blPath, 'BlockType');
            catch 
                type = '';
            end 
        end
        
        try
            name = get_param(blPath, 'Name');
        catch 
            name = '';
        end 
        
        if ~ismember(name, options.block_excludelist) && (ismember(name, options.block_includelist) || ismember(type, options.blocktype_list))
            if options.mismatch_func_map.isKey(type)
                func_map = options.mismatch_func_map(type);
                for type_cell = intersect(keys(func_map), options.mismatch_list)
                    func = func_map(type_cell{1});
                    simins = func(blPath, simins, model_work, mismatchParams);
                end
            else
                warning(['Block "' blPath '" has type "' type '" which is not a supported type.'])
            end
        end
    end
end