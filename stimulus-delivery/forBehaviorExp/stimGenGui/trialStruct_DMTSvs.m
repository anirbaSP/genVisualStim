function trials = trialStruct_DMTSvs(trialKey)
%TRIALSTRUCT_DMTSGRATING generates trial structure for playing
%delyed-matching-to-sample visual stimuli. Currently The visual stimuli are 
%different gratings. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% To be done %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Adding more visual stimuli types including the natural image library
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Where INPUTS
%   TrialKey: a vector of elements composed of 1 or 2. "1" specifies the 
% matching image is on the left, and "2" specifies the matching image is on
% the right.
%OUTPUTS
%   trials: a structure with filed


%%%%%%%%%%%%%%%%%%%%%%%%%% GENERATE TRIAL POOLS %%%%%%%%%%%%%%%%%%%%%%%%%%%

table = {'Spatial Frequency (cpd)', 0.04, .04, 0.04;...
    'Temporal Frequency (cps)', 3, 1, 3;...
    'Contrast (start,end,numsteps)', 1, 1, 1;...
    'Orientation', 0, 180, 180;...
    'Timing (delay,duration,wait) (s)', 0, 2, 0.4;...
    'Blank', 0, [], [];
    'Randomize', 0, [], [];...
    'Interleave', 0, [], [];...
    'Repeats', 0, [], [];...
    'Initialization Screen (s)', 5, [],[]};
stimType = 'Full-field Grating';

trial0 = trialStruct(stimType, table);

% add extra fields for behavior experiemnt
for i = 1:length(trial0);
    trial0(i).flipCheck = 'trial';
    trial0(i).trigger = 1;
    trial0(i).tone = 0; % to do: supply parameters to generate tone
    trial0(i).reportTrlDone = 1;
end

%%%%%%%%%%%%%%%% CREATE TRIAL SEQUENCE ACCRODING TO TRAILKEY %%%%%%%%%%%%%%
n_trial = length(trialKey);
trials = struct(trial0(1));
for i = 1:n_trial
    trials(i) = trial0(trialKey(i));
end

% add extra delay for trail(1), this is particually necessary for
% behavior experiemnt in which NI-daq card always output a slowly decaying
% analog signal for each channel. In order to wait the photodiode
% channel output reach a stable baseline for black screen, we pariticualy
% wait for 

%trials(1).Timing(1) = 3;













