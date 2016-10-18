function drawTexture(screenInfo, duration, texture, dstRect, orientation,...
    shiftperframe, pxPerCycle, masktex)
% This function draw the texture on the screen. if there are only the first
% two inputs, the function will draw a gray screen with specified duration.
% INPUTS:
%

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

if nargin < 8
    masktex = [];
end

w = screenInfo.w;
waitframes = screenInfo.waitframes;
ifi = screenInfo.ifi;
screenRect = screenInfo.screenRect;

if isfield(screenInfo, 'frameON') && isfield(screenInfo, 'frameOFF')
    frameON = screenInfo.frameON;
    frameOFF = screenInfo.frameOFF;
else
    frameON = screenInfo.grayPix;
    frameOFF = screenInfo.grayPix;
end

vbl=Screen('Flip', w);
% Set the runtime of each trial by adding duration to vbl time
runtime = vbl + duration;
n = 0;

if nargin > 2 % when it's not a gray screen
    %%%%%%%%%%%%%%%%%%%%% PREPARE for SHIFTING TEXTURE %%%%%%%%%%%%%%%%%%%%%%%%
    % when the input dstRect is a 2-raw matrix, the 1st row is starting
    % position, and the 2 row is the stopping position.
    if size(dstRect,1) == 1
        dstRect(2,:) = dstRect(1,:);
    end
    % estimate how many times of screen refresh will be
    n_esti = ceil(duration/(waitframes*ifi));
    pix2MovePerFrame = diff(dstRect(:,[1 2]))/n_esti;
    thisDstRect = dstRect(1,:); % initalize to the start dstRect
end
   
while (vbl < runtime)
    % calculate the offset of the grating and use the mod func
    % to ensure the grating snaps back once the border is
    % reached

    if nargin > 2 % draw a texture
        
        xoffset = mod(n*shiftperframe,pxPerCycle);
 
        % Set the source rect to excise the grating from
        sizeInPix = max(dstRect(1,[3 4])-dstRect(1,[1 2]));
        srcRect = [xoffset 0 xoffset+sizeInPix+1 sizeInPix+1];
        mSrcRect = [0 0 sizeInPix+1 sizeInPix+1];
       
        % update dstRect if it contains a start and stop position
        thisDstRect([1 2]) = dstRect(1,[1 2]) + n*pix2MovePerFrame;
        thisDstRect([3 4]) = dstRect(1,[3 4]) + n*pix2MovePerFrame;
        
        % Draw the grating texture for this trial to the dst rectangle
        Screen('DrawTextures', w, texture, srcRect,...
            thisDstRect, orientation);
        
        % Draw the mask if provided
        if ~isempty(masktex)
                % ENABLE ALPHA BLENDING OF GRATING WITH THE MASK
                Screen('DrawTextures', w, masktex, mSrcRect,...
                    thisDstRect, orientation);
        end
        
    else % draw a gray screen
        Screen('FillRect', w, screenInfo.grayPix);
    end
    
    % Draw a box at the bottom right of the screen to record
        % all screen flips using a photodiode. Please see the file
        % FlipCheck.m in the stimulus directory for further
        % explanation        
    FlipCheck(w, screenRect, [frameON, frameOFF], n)
    
    % update the vbl timestamp and provide headroom for jitters
    vbl = Screen('Flip', w, vbl + (waitframes - 0.5) * ifi);
    n = n+1;
end
