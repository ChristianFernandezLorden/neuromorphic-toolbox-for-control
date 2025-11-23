%% Simulating
load_system("STGexample")

out = sim("STGexample");

%% Using signal logging
logdata = get(out.logsout, "AB/PD");

Spikes = NeuroCont.signalAnalysis.find_spikes(logdata.Values.Data, logdata.Values.Time);

%% Using To Workspace block
Spikes = NeuroCont.signalAnalysis.find_spikes(out.simout.Data, out.simout.Time);

%% Analyse spikes
Spike_Intervals = Spikes(2:end,1) - Spikes(1:end-1,1);
[std_spikes, mean_spikes] = std(Spike_Intervals);

histogram(Spike_Intervals,15)

%% Mismatch 
load_system("STGexample")

mismatchParam = struct();
mismatchParam.std = 0.05;
mismatchParam.width = 4*mismatchParam.std;
simins = NeuroCont.mismatch.apply_to_system("STGexample", mismatchParam, 10, "baseOptions", "on", "mismatchIncludeList", "all", "blockTypeIncludeList", "all");

out = sim(simins);

%% Analyze

intervals_mean = zeros(length(out), 1);
for i = 1:length(out)
    Spikes = NeuroCont.signalAnalysis.find_spikes(out(i).simout.Data, out(i).simout.Time);
    try
        Spike_Intervals = Spikes(2:end,1) - Spikes(1:end-1,1);
        mean_spikes = mean(Spike_Intervals);
        intervals_mean(i) = mean_spikes;
    catch
        intervals_mean(i) = NaN;
    end
end

histogram(intervals_mean,10)