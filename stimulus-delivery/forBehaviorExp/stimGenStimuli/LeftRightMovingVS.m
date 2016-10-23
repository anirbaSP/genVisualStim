%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% copyright (c) 2016 Pei Sabrina Xu
%
% this program is free software: you can redistribute it and/or modify
% it under the terms of the gnu general public license as published by
% the free software foundation, either version 3 of the license, or
% at your option) any later version.
%
% this program is distributed in the hope that it will be useful,
% but without any warranty; without even the implied warranty of
% merchantability or fitness for a particular purpose.  see the
% gnu general public license for more details.
%
% you should have received a copy of the gnu general public license
% along with this program.  if not, see <http://www.gnu.org/licenses/>.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function KbCheckFlag = LeftRightMovingVS(trialKey, screenInfo, stim)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function draws a given visual stimuli stim, and display the
% visual stimuli from the center to either left or right on the screen.
% INPUTS:
%   trialKey: a string with 2 possible value '1' and '2'. This input is
%       normally coming from a command sent by the host machine in a
%       behavior experiment. '1' means the to-be-drawed visual stimulus
%       should move to the left screen, and '2' means move to the right
%       screen.
%   screenInfo: a structure contain all information about current screen.
%       See output from _initializeScreen_.
%   stim: a structure contain the information for the visual stimulus, with
%       following fields. See _genVSPool_.
%   'texture': a pointer to the texture of visual stimulus, e.g. the
%              output of Screen('MakeTexture', w, grating) when it's a grating
%              based stimulus.
%   'shiftperframe'
%   'orientation'
%   'sizeInPix'
%   'pixPerCycle'
%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Written by PSX/10-07-2016
% Modified by: PSX/
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% DEFAULTS FOR TESTING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % UNCOMMENT THIS SECTION FOR RUNNING STIMULUS AS STAND ALONE

% trialKey = '1';
% screenInfo = initializeScreen;
% screenInfo = setflipCheckforScreen(screenInfo, 'trial');
% 
% % % create a simple vsPool with only two different stimulus
% vsPool = genVSPool(screenInfo);
% stim = vsPool(1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%% GET SPECIFIC MONITOR INFORMATION %%%%%%%%%%%%%%%%%%%

screenSizePixX = screenInfo.screenSizePixX;
screenSizePixY = screenInfo.screenSizePixY;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DRAW TEXTURES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% In DRAW TEXTURES, we will obtain specific parameters such as the
% orientation etc for each trial in the trials struct. We will then draw an
% initial gray screen persisting for a time called delay. Then we will draw
% our grating using the parameters we pulled from the trials structure.
% Lastly we will draw another gray screen persisting for a time called
% wait. We repeat until the end of trials.

%%%%%%%%%%%%%%%%%%%%% CHOOSE TO-BE-DRAWED STIMULUS %%%%%%%%%%%%%%%%%%%%%%%%
% randomly choose a stimulus from the VSPool

thisStimIdx = 1; 
gratingtex = stim(thisStimIdx).texture;
masktex = stim(thisStimIdx).masktex;
shiftperframe = stim(thisStimIdx).shiftperframe;
orientation = stim(thisStimIdx).orientation;
sizeInPix = stim(thisStimIdx).sizeInPix;
dstRect = [0 0 sizeInPix+1 sizeInPix+1];
pxPerCycle = stim(thisStimIdx).pxPerCycle;

%%%%%%%%%%%%%%%%%%%%% DEFINE START and STOP POSITION %%%%%%%%%%%%%%%%%%%%%%
colIdxv = [1 3];

% start from the center
colIdx = mean(colIdxv); 
xLoc_start = screenSizePixX/(3*2) * (2*colIdx-1);
yLoc_start = screenSizePixY/(1*2) * (2*1-1);

% stop at the side dictated by trialKey
colIdx = colIdxv(str2num(trialKey)); 
xLoc_stop = screenSizePixX/(3*2) * (2*colIdx-1);
yLoc_stop = screenSizePixY/(1*2) * (2*1-1);

% center dstRect about user selected x,y coordinate
dstRect_start=CenterRectOnPoint(dstRect,xLoc_start,yLoc_start);
dstRect_stop=CenterRectOnPoint(dstRect,xLoc_stop,yLoc_stop);

%%%%%%%%%%%%%%%%%%%%%%% PARALLEL PORT TRIGGER %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% After constructing the stimulus texture we are now ready to trigger the
% parallel port and begin our draw to the screen. This function
% is located in the stimGen helper functions directory.
% ParPortTrigger;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DRAW CENTER STIMULUS %%%%%%%%%%%%%%%%%%%%%%%%
duration = 1;
drawTexture(screenInfo, duration, gratingtex, dstRect_start, orientation, ...
    shiftperframe, pxPerCycle, masktex)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DRAW INTERIM STIMULUS %%%%%%%%%%%%%%%%%%%%%%%
% delay = 0.5;
% drawTexture(screenInfo, delay)

% moving stimulus from center to the target side
duration = 0.5;
dstRect = [dstRect_start; dstRect_stop];
drawTexture(screenInfo, duration, gratingtex, dstRect, orientation, ...
    shiftperframe, pxPerCycle, masktex)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DRAW SIDE STIMULUS %%%%%%%%%%%%%%%%%%%%%%%%%
duration = 1;
drawTexture(screenInfo, duration, gratingtex, dstRect_stop, orientation, ...
    shiftperframe, pxPerCycle, masktex)


%%%%%%%%%%%%%%%%%%%%% REFRESH SCREEN BACK TO BACKGRAOUD %%%%%%%%%%%%%%%%%%%
duration = 0.1;
drawTexture(screenInfo, duration)

