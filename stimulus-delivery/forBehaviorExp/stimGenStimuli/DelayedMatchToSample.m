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
function KbCheckFlag = DelayedMatchToSample(trialKey, screenInfo, stim, ...
    duration, delay, option)
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
%              output of Screen('MakeTexture', w, grating) when it's a
%              grating based stimulus.
%   'shiftperframe'
%   'orientation'
%   'sizeInPix'
%   'pixPerCycle'
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Written by PSX/10-07-2016
% Modified by: PSX/01-18-2016: handle -/+ delay case
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% DEFAULTS FOR TESTING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % UNCOMMENT THIS SECTION FOR RUNNING STIMULUS AS STAND ALONE

% trialKey = '1';
% screenInfo = initializeScreen;
% screenInfo = setflipCheckforScreen(screenInfo, 'trial');
%
% % % create a simple vsPool with only two different stimulus
% vsPool = genVSPool(screenInfo);
% stim = vsPool(1);
% duration = 1;
% delay = 0.5;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin == 5
    option = struct;
    option.move = false;
end
% default sample is not moving to the target position

Screen('Preference', 'Verbosity',1);
Screen('Preference', 'VisualDebuglevel', 3);
%%%%%%%%%%%%%%%%%%%%%% GET SPECIFIC MONITOR INFORMATION %%%%%%%%%%%%%%%%%%%
screenSizePixX = screenInfo.screenSizePixX;
screenSizePixY = screenInfo.screenSizePixY;

%%%%%%%%%%%%%%%%%%%%% DEFINE DESTINATION POSITIONS %%%%%%%%%%%%%%%%%%%%%%
colIdxv = [1 3];

% start from the center
colIdx = mean(colIdxv);
xLoc_start = screenSizePixX/(3*2) * (2*colIdx-1);
yLoc_start = screenSizePixY/(1*2) * (2*1-1);

% stop at the side dictated by trialKey
colIdx = colIdxv(str2num(trialKey));
xLoc_stop = screenSizePixX/(3*2) * (2*colIdx-1);
yLoc_stop = screenSizePixY/(1*2) * (2*1-1);

colIdx = setdiff(colIdxv, colIdx);
xLoc_stop_nonmatch = screenSizePixX/(3*2) * (2*colIdx-1);
yLoc_stop_nonmatch = screenSizePixY/(1*2) * (2*1-1);

% center dstRect about user selected x,y coordinate
% for matched stimulus
sizeInPix = stim(1).sizeInPix;
dstRect = [0 0 sizeInPix+1 sizeInPix+1];
dstRect_start = CenterRectOnPoint(dstRect,xLoc_start,yLoc_start);
dstRect_stop = CenterRectOnPoint(dstRect,xLoc_stop,yLoc_stop);
% for non-matched stimulus
if length(stim) == 2
    sizeInPix = stim(2).sizeInPix;
    dstRect = [0 0 sizeInPix+1 sizeInPix+1];
    dstRect_nonmatch = CenterRectOnPoint(dstRect,xLoc_stop_nonmatch,yLoc_stop_nonmatch);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DRAW TEXTURES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%% PARALLEL PORT TRIGGER %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% After constructing the stimulus texture we are now ready to trigger the
% parallel port and begin our draw to the screen. This function
% is located in the stimGen helper functions directory.
% ParPortTrigger;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DRAW CENTER STIMULUS %%%%%%%%%%%%%%%%%%%%%%%%
stim(1).dstRect = dstRect_start;
drawMultiTextures(screenInfo, duration, stim(1))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DRAW INTERIM STIMULUS %%%%%%%%%%%%%%%%%%%%%%%
if option.move
    % moving stimulus from center to the target side
    stim(1).dstRect = [dstRect_start; dstRect_stop];
    drawMultiTextures(screenInfo, abs(delay), stim(1))
else
    if delay < 0
        stim(1).dstRect = [dstRect_stop; dstRect_stop];
        stim(2).dstRect = [dstRect_nonmatch; dstRect_nonmatch];
        stim(3) = stim(1);
        stim(3).dstRect = [dstRect_start; dstRect_start];
        drawMultiTextures(screenInfo, abs(delay), stim)
        stim(3) = [];
    end
    if delay > 0
        % draw gray screen
        drawMultiTextures(screenInfo, delay)
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DRAW SIDE STIMULUS %%%%%%%%%%%%%%%%%%%%%%%%%
stim(1).dstRect = dstRect_stop;
if length(stim) == 2
    stim(2).dstRect = dstRect_nonmatch;
end

drawMultiTextures(screenInfo, duration, stim(1:2))

%%%%%%%%%%%%%%%%%%%%% REFRESH SCREEN BACK TO BACKGRAOUD %%%%%%%%%%%%%%%%%%%
drawMultiTextures(screenInfo, 0.02)

Screen('Preference', 'Verbosity',3);
Priority(0);
