%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% copyright (c) 2016 Pei Sabrina Xu
%
% this program is free software: you can redistribute it and/or modify it
% under the terms of the gnu general public license as published by the
% free software foundation, either version 3 of the license, or at your
% option) any later version.
%
% this program is distributed in the hope that it will be useful, but
% without any warranty; without even the implied warranty of
% merchantability or fitness for a particular purpose.  see the gnu general
% public license for more details.
%
% you should have received a copy of the gnu general public license along
% with this program.  if not, see <http://www.gnu.org/licenses/>.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
    'Orientation', 0, 90, 90;...
    'Timing (delay,duration,wait) (s)', 0, 0, 0;...
    'Blank', 0, [], [];
    'Randomize', 0, [], [];...
    'Interleave', 0, [], [];...
    'Repeats', 0, [], [];...
    'Initialization Screen (s)', 0, [],[]};
stimType = 'Full-field Grating';

trial = trialStruct(stimType, table);
n_trial = length(trial);
for i = 1:n_trial
    trial(i).mask = true;
%     trial(i+n_trial) = trial(i);
%     trial(i+n_trial).mask = true;
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

% save vs pool information
