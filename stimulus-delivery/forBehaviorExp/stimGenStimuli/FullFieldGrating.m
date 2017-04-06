%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%copyright (c) 2012  Matthew Caudill
%
%this program is free software: you can redistribute it and/or modify
%it under the terms of the gnu general public license as published by
%the free software foundation, either version 3 of the license, or
%at your option) any later version.

%this program is distributed in the hope that it will be useful,
%but without any warranty; without even the implied warranty of
%merchantability or fitness for a particular purpose.  see the
%gnu general public license for more details.

%you should have received a copy of the gnu general public license
%along with this program.  if not, see <http://www.gnu.org/licenses/>.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
function KbCheckFlag = FullFieldGrating(trial, screenInfo)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%This function generates and draws various visual stimuli with parameters
%defined by the array of trials structures (see trialStruct.m). Trials
%structures are automatically generated from the table values in the gui
%by trialsStruct.m so your stimulus should take only one input namely
%trials. You can access parameters of a structure in the trials structure
%array using dynamic field referencing (e.g. trials(1).Orientation ...
%returns the orientaiton of trial 1). As you write your stimulus you can
%test it by creating a Default trials structure as done below so you can
%see if it is behaving as expected before adding it to the stimGen gui.
%
% INPUTS:  TRIALSSTRUCT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Written by MSC 4-23-12 (Modified from DriftDemo2 in PTB)
% Modified by: MSC/2012-4-27, PSX/2015-8-19
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%% DEFAULTS FOR TESTING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%UNCOMMENT THIS SECTION FOR RUNNING STIMULUS AS STAND ALONE; COMMENT ABOVE
%CONFLICTING FUNCTION FULLFIELDGRATING(TRIALS)
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% function [trials] = FullFieldGrating(stimType,table)
% if nargin<1
%     table = {'Spatial Frequency (cpd)', 0.04, .04, 0.04;...
%               'Temporal Frequency (cps)', 3, 1, 6;...
%               'Contrast (start,end,numsteps)', 1, .2, 1;...
%               'Orientation', 0, 30, 330;...
%               'Timing (delay,duration,wait) (s)', 1, 2, 1;...
%               'Blank', 0, [], [];
%               'Randomize', 0, [], [];...
%               'Interleave', 0, [], [];...
%               'Repeats', 0, [], [];...
%               'Initialization Screen (s)', 0, [],[]};
%    stimType = 'Full-field Grating';
% 
% end
% trials = trialStruct(stimType, table);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%% GET SPECIFIC MONITOR INFORMATION %%%%%%%%%%%%%%%%%%%
%screenInfo = initializeScreen; %++++++++++++++++++++++++++++++++++++++++++
w = screenInfo.w;
whiteLum = screenInfo.whiteLum;
grayLum = screenInfo.grayLum;
degPerPix = screenInfo.degPerPix;
visibleSize = screenInfo.visibleSize;
ifiDuration = screenInfo.ifiDuration;
dstRect = screenInfo.dstRect;
screenRect = screenInfo.screenRect;
whitePix = screenInfo.whitePix;
blackPix = screenInfo.blackPix;
waitframes = screenInfo.waitframes;
ifi = screenInfo.ifi;

KbCheckOn = 0;

if isfield(trial, 'flipCheck')
    flipCheckOrNot = 1;
    switch trial.flipCheck
        case 'frame'
            frameON = whitePix;
            frameOFF = blackPix;
        case 'trial'
            frameON = blackPix;
            frameOFF = blackPix;
        otherwise
            error('FlipCheck each frame or trial? Unrecognizable mode')
    end
else
    flipCheckOrNot = 0;
end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%% CONSTRUCT STIMULUS TEXTURES %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% To make a static grating texture of a drifting grating we need the
% contrast and the spatial frequency. For each trial in our structure we
% will get these two variables and convert them to appropraite units and
% then make our texture.

% Get the contrast and spatial frequency of the trial
contrast = trial.Contrast;
spaceFreq = trial.Spatial_Frequency;

% convert to pixel units
pxPerCycle = ceil(1/(spaceFreq*degPerPix));
freqPerPix = (spaceFreq*degPerPix)*2*pi;

% construct a 2-D grid of points to calculate our grating over
% (note we extend by one period to account for shift of
% grating later)
x = meshgrid(-(visibleSize)/2:(visibleSize)/2 + pxPerCycle, 1);

% compute the grating in Luminance units
grating = grayLum + (whiteLum-grayLum)*contrast*cos(freqPerPix*x);

% convert grating to pixel units
grating = GammaCorrect(grating);

% make the grating texture and save to gratingtex cell array
% note it is not strictly necessary to save this to a cell
% array since we will delete at the end of the loop but I want
% to be explicit with the texture so that I am sure to delete
% it when it is no longer needed in memory
gratingtex=Screen('MakeTexture', w, grating);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DRAW TEXTURES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% In DRAW TEXTURES, we will obtain specific parameters such as the
% orientation etc for each trial in the trials struct. We will then draw an
% initial gray screen persisting for a time called delay. Then we will draw
% our grating using the parameters we pulled from the trials structure.
% Lastly we will draw another gray screen persisting for a time called
% wait. We repeat until the end of trials.

% Get the parameters for drawing the grating
tempFreq = trial.Temporal_Frequency;
orientation = trial.Orientation;

% calculate amount to shift the grating with each screen update
shiftperframe = tempFreq * pxPerCycle * ifiDuration;

%%%%%%%%%%%%%%%%%%%%%%% PARALLEL PORT TRIGGER %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% After constructing the stimulus texture we are now ready to trigger the
% parallel port and begin our draw to the screen. This function
% is located in the stimGen helper functions directory.
% ParPortTrigger;

%%%%%%%%%%%%%%%%%%%% DRAW DELAY GRAY SCREEN %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DEVELOPER NOTE: Prior versions of stimuli used the func WaitSecs to
% draw gray screens. This is a bad practice because the function sleeps
% the matlab thread making the computer unresponsive to KbCheck clicks.
% In addition PTB only guarantees the accuracy of WaitSecs to the
% millisecond scale whereas VBL timestamps described below uses
% GetSecs() a highly accurate submillisecond estimate of the system
% time. All times should be referenced to this estimate for better
% accuracy.

% We start by performing an initial screen flip using Screen, we return
% back a time called vbl. This value is a high precision time estimate
% of when the graphics card performed a buffer swap. This time is what
% all of our times will be referenced to. More details at
% http://psychtoolbox.org/FaqFlipTimestamps
%         vbl=Screen('Flip', w);

% The first time element of the stimulus is the delay from trigger
% onset to stimulus onset
%         delayTime = vbl + delay;

% Display a gray screen while the vbl is less than delay time. NOTE
% we are going to add 0.5*ifi to the vbl to give us some headroom
% to take possible timing jitter or roundoff-errors into account.
%         while (vbl < delayTime)
%             % Draw a gray screen
%             Screen('FillRect', w,grayPix);
%
%             % update the vbl timestamp and provide headroom for jitters
%             vbl = Screen('Flip', w, vbl + (waitframes - 0.5) * ifi);
%
%             % exit the while loop and flag to one if user presses any key
%             if KbCheck
%                 exitLoop=1;
%                 break;
%             end
%         end

%%%%%%%%%%%%%%%%%%%%%%%%%% DRAW GRATING TEXTURE %%%%%%%%%%%%%%%%%%%%%%%%%%%
% set src and dstrect and calculate grating shifts etc

vbl=Screen('Flip', w);

% Set the runtime of each trial by adding duration to vbl time
duration = trial.Timing(2);
runtime = vbl + duration;
n = 0;
KbCheckFlag = 0;
while (vbl < runtime)
    % calculate the offset of the grating and use the mod func
    % to ensure the grating snaps back once the border is
    % reached
    xoffset = mod(n*shiftperframe,pxPerCycle);
    n = n+1;
    
    % Set the source rect to excise the grating from
    srcRect = [xoffset 0 xoffset + visibleSize visibleSize];
    
    % Draw the grating texture for this trial to the dst
    % rectangle
    Screen('DrawTextures', w, gratingtex, srcRect,...
        dstRect, orientation);
    
    % Draw a box at the bottom right of the screen to record
    % all screen flips using a photodiode. Please see the file
    % FlipCheck.m in the stimulus directory for further
    % explanation
    if flipCheckOrNot
        FlipCheck(w, screenRect, [frameON, frameOFF], n)
    end
    
    % update the vbl timestamp and provide headroom for jitters
    vbl = Screen('Flip', w, vbl + (waitframes - 0.5) * ifi);
    
    % exit the while loop and flag to one if user presses any
    % key
    if KbCheckOn
        if KbCheck
            KbCheckFlag=1;
            break;
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IMPORTANT YOU MUST CLOSE EACH TEXTURE IN THE LOOP OTHERWISE THESE
% OBJECTS WILL REMAIN IN MEMORY FOR SOME TIME AND ULTIMATELY LEAD TO
% JAVA OUT OF MEMORY ERRORS!!!
 Screen('Close', gratingtex)

