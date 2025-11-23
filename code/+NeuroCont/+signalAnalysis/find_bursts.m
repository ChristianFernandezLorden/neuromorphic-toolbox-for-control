function bursts = find_bursts(spikes, burst_length_factor)
    % Compute from the spiking times if the trace contains burst and to
    % which burst each spike belongs based on the interspike times.
    %
    % Description
    % -----------
    %   bursts = find_bursts(spikes)
    %       Computes the bursts with a default grouping factor
    %       of 4 between the lower and higher group interspike times.
    %
    %   bursts = find_bursts(spikes, burst_length_factor)
    %       Computes the bursts with a default a custom grouping factor between the lower and higher group interspike times.
    % Inputs
    % ------
    %   spikes: matrix
    %       Matrix Nx3 as returned from :func:`find_spikes` containing the
    %       spikes.
    %
    % Optional Input
    % --------------
    %   burst_length_factor: numeric
    %       Value of the grouping factor.
    %
    % Output
    % ------
    %   bursts: cell array
    %       Cell array containing matrix Nx3 as returned from
    %       :func:`find_spikes`. Each cell represent the bursts and the
    %       matrix represents each spikes in the burst.
    %       An empty cell array is returned if the signal is not deemed
    %       bursting according to the grouping factor.

    if nargin == 1
        burst_length_factor = 4;
    end

    spike_down_periods = spikes(2:end,1) - spikes(1:end-1,2);
    [min_spike_down_periods, ~, max_spike_down_periods, max_idx] = group_vector(spike_down_periods);

    if burst_length_factor*mean(min_spike_down_periods) < mean(max_spike_down_periods)
        sort_ids = sort(max_idx);
        bursts = cell(length(max_spike_down_periods)-1,1);
        for i = 1:length(max_spike_down_periods)-1
            bursts{i} = spikes(sort_ids(i)+1:sort_ids(i+1), :);
        end
    else
        bursts = {};
    end
end

function [min_values, min_idx, max_values, max_idx] = group_vector(periods)
    [sort_periods, idx_periods] = sort(periods);
    min_group_sum = sort_periods(1); 
    max_group_sum = sort_periods(end);
    min_group_size = 1;
    max_group_size = 1;
    while min_group_size+max_group_size < length(sort_periods)
        min_diff = sort_periods(min_group_size+1) - (min_group_sum/min_group_size);
        max_diff = (max_group_sum/max_group_size) - sort_periods(end-max_group_size);
        if min_diff <= max_diff
            min_group_sum = min_group_sum + sort_periods(min_group_size+1);
            min_group_size = min_group_size+1; 
        else
            max_group_sum = max_group_sum + sort_periods(min_group_size+1);
            max_group_size = max_group_size+1; 
        end
    end

    min_values = sort_periods(1:min_group_size);
    min_idx = idx_periods(1:min_group_size);
    max_values = sort_periods(end-max_group_size+1:end);
    max_idx = idx_periods(end-max_group_size+1:end);
end

