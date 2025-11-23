function spikes = find_spikes(V, T, threshold)
    % Compute the spike times of a voltage trace or logical trace. 
    %
    % Description
    % -----------
    %   spikes = find_spikes(V, T)
    %       * If V is numeric, then compute the spiking times with the base threshold of 0.
    %       * If V is logical, then compute the spiking times based on the rising and falling edges.
    %
    %   spikes = find_spikes(V, T, threshold)
    %       * If V is numeric, then compute the spiking times with the given threshold.
    %       * If V is logical, then ignore given treshold and compute the spiking times based on the rising and falling edges.
    % Inputs
    % ------
    %   V: vector
    %       Value of the voltage.
    %   T: vector
    %       Sampling times of the voltage.
    %
    % Optional Input
    % --------------
    %   threshold: numeric
    %       Value of the treshold.
    %
    % Output
    % ------
    %   spikes: matrix
    %       Returns a Nx3 matrix where N is the number of spikes and, for each row, the
    %       the first value is the start of the spike, the
    %       second the spike of the  and the last the time of the peak. If the peak is not
    %       computable the last value is NaN.

    if nargin == 2
        threshold = 0;
    end

    if islogical(V)
        [up_crossings, down_crossings] = find_switching_times(V,T);
        if nargin == 3
            warning("Treshold ignored when input is a logical vector")
        end
    else
        [up_crossings, down_crossings] = find_crossing_times(V-threshold,T);
    end
    

    if down_crossings(1) < up_crossings(1)
        down_crossings = down_crossings(2:end);
    end
    if length(up_crossings) > length(down_crossings)
        up_crossings = up_crossings(1:end-1);
    end

    assert(length(up_crossings) == length(down_crossings), "Error in find_spikes, crossing vector are not of the same size");
    
    spikes = zeros(length(up_crossings), 3);
    spikes(:,1) = up_crossings;
    spikes(:,2) = down_crossings;
    
    if islogical(V)
        spikes(:,3) = NaN;
        return;
    end

    index = 1;
    i = 1;
    while i <= length(T)
        while T(i) < up_crossings(index)
            i = i+1;
        end
        save_i = i;
        while T(i) < down_crossings(index)
            i = i+1;
        end
        try 
            [~, loc] = findpeaks(V(i:save_i), T(i:save_i));
            if isempty(loc)
                warning("Interval with no peaks")
                spikes(index,3)  = NaN;
            else
                spikes(index,3)  = loc(1);
            end
        catch
            spikes(index,3)  = NaN;
        end
    end
end

function  [up_crossings, down_crossings] = find_crossing_times(V,T)
    prev = V(1);
    up_crossings = zeros(length(T), 1);
    down_crossings = zeros(length(T), 1);
    ind_upcross = 0;
    ind_downcross = 0;
    
    for i = 2:length(T)
        curr = V(i);
        if prev < 0 && curr > 0
            ind_upcross = ind_upcross + 1;
            % Linear interpolation
            t_prev = T(i-1);
            t_curr = T(i);
            t_inter = (t_prev*curr - t_curr*prev) / (curr - prev);
            up_crossings(ind_upcross) = t_inter;
        elseif prev > 0 && curr < 0
            ind_downcross = ind_downcross + 1;
            % Linear interpolation
            t_prev = T(i-1);
            t_curr = T(i);
            t_inter = (t_prev*curr - t_curr*prev) / (curr - prev);
            down_crossings(ind_downcross) = t_inter;
        end
        prev = curr;
    end
    up_crossings = up_crossings(1:ind_upcross);
    down_crossings = down_crossings(1:ind_downcross);
end

function  [up_crossings, down_crossings] = find_switching_times(V,T)
    prev = V(1);
    up_crossings = zeros(length(T), 1);
    down_crossings = zeros(length(T), 1);
    ind_upcross = 0;
    ind_downcross = 0;
    
    for i = 2:length(T)
        curr = V(i);
        if ~prev && curr
            ind_upcross = ind_upcross + 1;
            up_crossings(ind_upcross) = T(i);
        elseif prev && ~curr
            ind_downcross = ind_downcross + 1;
            down_crossings(ind_downcross) = T(i);
        end
        prev = curr;
    end
    up_crossings = up_crossings(1:ind_upcross);
    down_crossings = down_crossings(1:ind_downcross);
end