function vsPool = genVSPool(screenInfo)
% This function generates a pool of visual stimulation. Currently it
% supports drifting gratings.
% INPUTS:
%   screenInfo: the information about the current screen

w = screenInfo.w;
whiteLum = screenInfo.whiteLum;
grayLum = screenInfo.grayLum;
degPerPix = screenInfo.degPerPix;
dstRect = screenInfo.dstRect;
screenRect = screenInfo.screenRect;
whitePix = screenInfo.whitePix;
blackPix = screenInfo.blackPix;
waitframes = screenInfo.waitframes;
ifi = screenInfo.ifi;

% Currently the default stimulus are defined by the following table

table = {'Spatial Frequency (cpd)', 0.04, .04, 0.04;...
    'Temporal Frequency (cps)', 3, 1, 3;...
    'Contrast (start,end,numsteps)', 1, 1, 1;...
    'Orientation', 0, 45, 315;...
    'Timing (delay,duration,wait) (s)', 1, 2, 0;...
    'Blank', 0, [], [];
    'Randomize', 0, [], [];...
    'Interleave', 0, [], [];...
    'Repeats', 0, [], [];...
    'Initialization Screen (s)', 0, [],[]};
stimType = 'Full-field Grating';

trial = trialStruct(stimType, table);
n_trial = length(trial);
for i = 1:n_trial
    trial(i).mask = false;
    trial(i+n_trial) = trial(i);
    trial(i+n_trial).mask = true;
end

n_trial = length(trial);

% % create a simple vsPool with only two different stimulus
vsPool = struct;
for i = 1:n_trial
    spaceFreq = trial(i).Spatial_Frequency;
    contrast = trial(i).Contrast;
    sizeInDegree = 20;
    orientation = trial(i).Orientation;
    tempFreq = trial(i).Temporal_Frequency;
    pxPerCycle = ceil(1/(spaceFreq*degPerPix));

    grating = genGrating(spaceFreq, contrast, sizeInDegree); 
    gratingtex = Screen('MakeTexture', w, grating);
    
    %%%%%%%%%%%%%%%%%% create a circular mask if necessary %%%%%%%%%%%%%%%%
    if trial(i).mask
        mask = genMask(sizeInDegree);
        masktex=Screen('MakeTexture', w, mask);
    else
        masktex = [];
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % make the grating texture and save to gratingtex. Note that it will be
    % staying the memory untill you explicitely delete it.  
    vsPool(i).texture = gratingtex;
    vsPool(i).masktex = masktex;
    vsPool(i).orientation = orientation;
    vsPool(i).shiftperframe = tempFreq * pxPerCycle * waitframes*ifi;
    vsPool(i).sizeInPix = ceil(sizeInDegree/degPerPix);
    vsPool(i).pxPerCycle = pxPerCycle;
end

