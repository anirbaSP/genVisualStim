function screenInfo = initializeScreen

% Get monitor info from monitorInformation located in RigSpecificInfo dir.
% This structure contains all the pertinent monitor information we will
% need such as screen size and appropriate conversions from pixels to
% visual degrees
monitorInformation;

%================================= to do ==================================
% ----- ! PTB - ERROR: SYNCHRONIZATION FAILURE ! ----
% 
% One or more internal checks (see Warnings above) indicate that
% synchronization of Psychtoolbox to the vertical retrace (VBL) is not
% working on your setup.
% 
% This will seriously impair proper stimulus presentation and stimulus
% presentation timing! Please read 'help SyncTrouble' for information about
% how to solve or work-around the problem. You can force Psychtoolbox to
% continue, despite the severe problems, by adding the command
% Scren('close all')

% Screen('Preference', 'SkipSyncTests', 1); at the top of your script, if
% you really know what you are doing.
Screen('Preference', 'SkipSyncTests', 1);
%================================= to do ==================================


%%%%%%%%%%%%%%%%%%%%% TURN OFF PTB SYSTEM CHECK REPORT %%%%%%%%%%%%%%%%%%%%
Screen('Preference', 'Verbosity',1);
% This will suppress all but critical warning messages
% At the end of the code we will return the verbosity back to norm level 3
% please see the following page for an explanation of this function
% http://psychtoolbox.org/FaqWarningPrefs
% NOTE: as you debug your code comment this line because PTB will return
% back useful info about memory usage that will tell you about leaks that
% may casue problems

% When Screen('OpenWindow',w,color) is called, PTB performs many checks of
% your system. The time it takes to perform these checks depends on the
% noisiness of your system (up to two seconds on 2-photon rig). During this
% time it displays a white screen which is obviously not good for visual
% stimulation. We can disable the startup screen using the following. The
% sreen will now be black before visual stimulus
Screen('Preference', 'VisualDebuglevel', 3);
% see http://psychtoolbox.org/FaqBlueScreen for a reference

%%%%%%%%%%%%%%%%%%%%% OPEN A SCREEN & DETERMINE PARAMETERS %%%%%%%%%%%%%%%%
% Use a try except block to prevent the screen from hanging. During testing
% if the screen does hang press cntrl C or cntrl-alt del to bring up the
% task manager to stop PTB execution
try
    
    % Require OPENGL becasue some of the functions used here need the
    % OPENGL version of PTB
    AssertOpenGL;
    
    %%%%%%%%%%%%%%%%%% GET SPECIFIC MONITOR INFORMATION %%%%%%%%%%%%%%%%%%%
    
    % SCREEN WE WILL DISPLAY ON
    %Query monitorInformation for screenNumber
    s.screenNumber = monitorInfo.screenNumber;
    
    % COLOR INFORMATION OF SCREEN
    % Get black, white and gray color values for the current monitor
    s.whitePix = WhiteIndex(s.screenNumber);
    s.blackPix = BlackIndex(s.screenNumber);
    
    %Convert balck and white to luminance values to determine gray
    %luminance
    s.whiteLum = PixToLum(s.whitePix);
    s.blackLum = PixToLum(s.blackPix);
    s.grayLum = (s.whiteLum + s.blackLum)/2;
    
    % Now determine the pixel value of gray from the gray luminance
    s.grayPix = GammaCorrect(s.grayLum);
    
    % CONVERSION FROM DEGS TO PX AND SIZING INFO FOR SCREEN
    %conversion factor specific to monitor
    s.degPerPix = monitorInfo.degPerPix;
    % Size of the grating (in pix) that we will draw (1.5 times
    % monitor width)
    s.screenSizePixX = monitorInfo.screenSizePixX;
    s.screenSizePixY = monitorInfo.screenSizePixY;
    
    s.waitframes = monitorInfo.waitframes;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%% INITIAL SCREEN DRAW %%%%%%%%%%%%%%%%%%%%%%%%
    % We start with a gray screen before generating our stimulus and 
    % displaying our stimulus.
    
    % HIDE CURSOR FROM SCREEN
    % During the screen initialization period, we hide the cursor no matter
    % how, yet we can control whether to show the cursor afterwards
    % HideCursor;
    % OPEN A SCREEN WITH A BG COLOR OF GRAY (RETURN POINTER W)
    [s.w, s.screenRect]=Screen(s.screenNumber,'OpenWindow', s.grayPix);
    Screen('BlendFunction', s.w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    %%%%%%%%%%%%%%%%%%%%%%%%% PREP SCREEN FOR DRAWING %%%%%%%%%%%%%%%%%%%%%

    % SCRIPT PRIORITY LEVEL
    % Query for the maximum priority level availbale on this system. This
    % determines the priority level of the matlab thread (0= normal,
    % 1=high, 2=realTime priority) note that a setting of 2 may cause the
    % keyboard to be unresponsive. You may want to play with this number if
    % you have trouble recovering the screen back

    priorityLevel=MaxPriority(s.w);
    Priority(priorityLevel);

    % INTERFRAME INTERVAL INFO
    % Get the montior inter-frame-interval
    s.ifi = Screen('GetFlipInterval',s.w);

    %on old slow machines we may not be able to update every ifi. If your
    %graphics processor is too slow you can buy a better one or adjust the
    %number of frames to wait between flips below

    s.waitframes = 1; %I expect most new computers can handle updates at ifi
    s.ifiDuration = s.waitframes*s.ifi;

    % CREATE A DESTINATION RECTANGLE where the stimulus will be drawn to
    s.dstRect=[0 0 s.screenSizePixX s.screenSizePixX];
    %center the rectangle to the screen
    s.dstRect=CenterRect(s.dstRect, s.screenRect);

    %%%%%%%%%%%%%%%%%%%%%% DRAW PRESTIM GRAY SCREEN %%%%%%%%%%%%%%%%%%%%%%%
    % We call the function stimInitScreen to draw a screen to the window 
    % before the stimulus appears to allow for any adaptation that is need 
    % to a change in luminance
    
    %===============================to do==================================
    % During the screen initialization period, we default to turn of
    % KbCheckOn 
    % s.KbCheckOn = 0;
    drawBackgroundScreen(s,s.ifiDuration,s.grayPix);
    %===============================to do==================================
    
    screenInfo = s;
    
catch
    %this "catch" section executes in case of an error in the "try" section
    %above.  Importantly, it closes the onscreen window if its open.
    Screen('CloseAll');
    Priority(0);
    psychrethrow(psychlasterror);
    
    screenInfo = [];
end
% The mouse cursor will always be hiden when playing visual stimulus, and
% pressing any key on the keyboard will stop the trials (this is because we
% will set the highest priority to drawing the screen, which may
% unavoidablely ignore/delaly responses to other tasks during that period,
% except for 'KbCheck' to terminate the trials. Therefore, using mouse
% during that period is not recommended). However, we will choose to show
% the cursor (and automatically turn off KbCheck) before and after trials
% when screen priority is set back to normal, which enable us to click and
% type.
Screen('Preference', 'Verbosity',3);
Priority(0);
ShowCursor;                            