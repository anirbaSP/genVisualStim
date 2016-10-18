function KbCheckFlag = BlankVisualStimulus(trial, screenInfo)
% if the trial is a blank, simply fill screen with a gray box

%%%%%%%%%%%%%%%%%%%%%% GET SPECIFIC MONITOR INFORMATION %%%%%%%%%%%%%%%%%%%
w = screenInfo.w;
waitframes = screenInfo.waitframes;
ifi = screenInfo.ifi;
whitePix = screenInfo.whitePix;
blackPix = screenInfo.blackPix;
grayPix = screenInfo.grayPix;
screenRect = screenInfo.screenRect;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%% CONSTRUCT STIMULUS TEXTURES %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gratingtex=Screen('MakeTexture', w,...
    grayPix*ones(visibleSize));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DRAW TEXTURES %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%% DRAW GRATING TEXTURE %%%%%%%%%%%%%%%%%%%%%%%
vbl=Screen('Flip', w);
% Set the runtime of each trial by adding duration to vbl time
duration = trial.Timing(2);
runtime = vbl + duration;
n = 0;
while (vbl < runtime)
    n = n+1; % Add to counter for flipCheck box
    % Draw a gray screen
    Screen('FillRect', w,grayPix);
    
    % Draw a box at the bottom right of the screen to record
    % all screen flips using a photodiode. Please see the file
    % FlipCheck.m in the stimulus directory for further
    % explanation
    FlipCheck(w, screenRect, [whitePix, blackPix], n)
    
    % update the vbl timestamp and provide headroom for jitters
    vbl = Screen('Flip', w, vbl + (waitframes - 0.5) * ifi);
    % exit the while loop and flag to one if user presses  key
    if KbCheck
        KbCheckFlag = 1;
        break;
    else
        KbCheckFlag = 0;
        
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IMPORTANT YOU MUST CLOSE EACH TEXTURE IN THE LOOP OTHERWISE THESE
% OBJECTS WILL REMAIN IN MEMORY FOR SOME TIME AND ULTIMATELY LEAD TO
% JAVA OUT OF MEMORY ERRORS!!!
Screen('Close', gratingtex)