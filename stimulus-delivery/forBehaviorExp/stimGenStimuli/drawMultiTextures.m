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

function drawMultiTextures(screenInfo, duration, stim, flipCheckON)
% This function draw the texture on the screen. if there are only the first
% two inputs, the function will draw a gray screen with specified duration.
% INPUTS:
%   screenInfo
%   duration
%   stim: is a structure of multiple stimulus to draw, with following
%   fields:
%       'texture'
%       'masktex': can be empty if no mask needed
%       'dstRect': a 1-by-4 vector if the texture stays the same location
%       on the screen; or a 2-by-4 matrix if the texture starts from a
%       starting location and smoothly shifts to an ending location.
%       'oritentaion'
%       'shiftperframe'
%       'pxPerCycle'

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Written by PSX/Oct 2016
% Modified by: PSX/
%

%%%%%%%%%%%%%%%%%%%%%%%%%% PREPARE SCREEN INFO %%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin == 3
    flipCheckON = true;
end

w = screenInfo.w;
waitframes = screenInfo.waitframes;
ifi = screenInfo.ifi;
screenRect = screenInfo.screenRect;

if isfield(screenInfo, 'FrameON') && isfield(screenInfo, 'FrameOFF')
    frameON = screenInfo.FrameON;
    frameOFF = screenInfo.FrameOFF;
else
    frameON = screenInfo.grayLum;
    frameOFF = screenInfo.grayLum;
end

%%%%%%%%%%%%%%%%%%%%% PREPARE for SHIFTING TEXTURE %%%%%%%%%%%%%%%%%%%%%%%%
if nargin > 2 % when it's not a gray screen
    
    % estimate how many times of screen refresh will be
    n_esti = ceil(duration/(waitframes*ifi));
    n_stim = length(stim);
    % loop for all stimulus
    for i = 1:n_stim
        tmp = stim(i).dstRect;
        if size(tmp,1) == 1
            tmp(2,:) = tmp(1,:);
        end
        % when the input dstRect is a 2-raw matrix, the 1st row is starting
        % position, and the 2 row is the stopping position.
        stim(i).pix2MovePerFrame = diff(tmp(:,[1 2]))/n_esti;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DRAW TEXTURE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

vbl=Screen('Flip', w);
% Set the runtime of each trial by adding duration to vbl time
runtime = vbl + duration;
n = 0;
while (vbl < runtime)
    % calculate the offset of the grating and use the mod func
    % to ensure the grating snaps back once the border is
    % reached
    
    if nargin > 2 % draw a texture
        for i = 1:n_stim
            sizeInPix = max(stim(i).dstRect(1,[3 4])-stim(i).dstRect(1,[1 2]));
            xoffset = mod(n*stim(i).shiftperframe,stim(i).pxPerCycle);
            
            % Set the source rect to excise the grating from
            srcRect = [xoffset 0 xoffset+sizeInPix+1 sizeInPix+1];
            mSrcRect = [0 0 sizeInPix+1 sizeInPix+1]; % for mask if necessary
            
            % update dstRect if it contains a start and stop position
            dstRect([1 2]) = stim(i).dstRect(1,[1 2]) + n*stim(i).pix2MovePerFrame;
            dstRect([3 4]) = stim(i).dstRect(1,[3 4]) + n*stim(i).pix2MovePerFrame;
            
            % Draw the grating texture for this trial to the dst rectangle
            Screen('DrawTextures', w, stim(i).texture, srcRect,...
                dstRect, stim(i).orientation);
            
            % Draw the mask if provided
            if ~isempty(stim(i).masktex)
                % Make sure ENABLE ALPHA BLENDING OF GRATING WITH THE MASK
                Screen('DrawTextures', w, stim(i).masktex, mSrcRect,...
                    dstRect); %orientation
            end     
        end
            
        % Draw a box at the bottom right of the screen to record all screen
        % flips using a photodiode. Please see the file FlipCheck.m in the
        if flipCheckON
        % stimulus directory for further explanation
        FlipCheck(w, screenRect, [frameON, frameOFF], n)
        end
    else % draw a gray screen
        Screen('FillRect', w, screenInfo.grayPix);
    end
    n = n+1;
    % update the vbl timestamp and provide headroom for jitters
    vbl = Screen('Flip', w, vbl + (waitframes - 0.5) * ifi);
end
