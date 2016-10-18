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
function runRealTimeVisualStimuli(vsPool,stimulusType,screenInfo,connection)
% This function plays visual stimulus in the VS machine according to
% command from a host machine. For each trial, it first receives a start
% trigger signal, the trigger signal also contain information about what
% stimulus to show. Basically, VS machine already have a pool of stimuli,
% but which one to show and how to show it depends on the command from host
% machine.
% INPUTS:
%   vsPool: a cell array of all visual stimuli that can be shown. Each cell
%       entry contains all necessary information to define a stimulus. See
%       function _LeftRightMovingVS_.
%   stimulusType: a string specify stimulus type. The current acceptable
%       types including 'LeftRightMovingVS'. Other types are to be added as
%       needed.
%   screenInfo: a structure with current screen information. See output of
%       function _initializeScreen_.
%   connection: a structure with information of current host-VS
%       communication. See output of function commu2host. Currently there
%       are 5 acceptable command '1' (vs category 1), '2' (vs category 2),
%       'repeat' (repeat the last vs), 'blank' (no stimulus), and 'stop'
%       (stop playing visual stimulation). The meaning of vs category 1 and
%       2 can be further custom defined in specific behavior task. For
%       example, in my delayed match-to-sample behavior task, category 1 is
%       a 2nd vs appeared in the left screen match the 1st vs, and category
%       2 is a 2nd vs appeared in the right screen match the 2st vs.

% If connection is missing -- for example, under the situation that no host
% machine is available and we want to debug the code -- this function will
% automatically take sudo host commands, which is a pre-defined cell array
% namely sudoTrial, see the begining of the code.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Written by PSX/Oct 2016
% Modified by: PSX/

%%%%%%%%%%%%%%%%%%%%%% DEFAULTS FOR TESTING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin < 4
    connection = [];
    sudoTrial = {'1','2', 'repeat', '1', '2', '1', '2', '2', '1','2', 'repeat', 'stop', };% 'Blank', '2', '1', 'repeat', 'stop'};
    stimulusType = 'DelayedMatchToSample'; %'LeftRightMovingVS'; %; % %
    screenInfo = initializeScreen;
    screenInfo = setflipCheckforScreen(screenInfo, 'trial');
    vsPool = genVSPool(screenInfo);
end

%%%%%%%%%%%%%%%%%%%%%% Create a file and save vsPool %%%%%%%%%%%%%%%%%%%%%%
saveFilePath = '/Users/Sabrina/Documents/MATLAB/stimulus-delivery_beta2.0/ForBehaviorExp/Debug/';
save([saveFilePath 'debug_vsPool'], 'vsPool', '-mat');
fileID = fopen([saveFilePath 'debug_Trial.vstim'], 'w');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
% sreen will now be black before visual stimulus (Matthew Caudill 2012).
Screen('Preference', 'VisualDebuglevel', 3);
% see http://psychtoolbox.org/FaqBlueScreen for a reference

% HIDE CURSOR FROM SCREEN
% HideCursor;

% Exit Codes and initialization
KbCheckFlag = 0;
% This is a flag indicating we need to break from the trials structure
% loop below. The flag becomes true (=1) if the user presses any key

stopFlag = false;
% initalize stopFalg to be false. Only when a stop command is recieved
% from the host machine, stopFlag will turned to true.

% MAIN LOOP OVER TRIALS
i = 0; % preset trial count
lastKey = '';

while ~stopFlag && i< length(sudoTrial)
    
    i = i+1;
    
    %%%%%%%%%%%%%%%%% WAIT THE TRIGGER TO START THIS TRAIL %%%%%%%%%%%%%%%
    % We can use the trigger signal not only inidate a start, but also
    % more information. For example, below is an example that 1)empty
    % output indicate no trigger signal received, so we press the
    % keyboard to stop the loop; 2) output 1 and 2 represent specific
    % trial paramenters, eg. "Orientation".
    if ~isempty(connection)
        thisKey = commu2host('getTrialStartTrigger', connection.receive);
    else
        thisKey = sudoTrial{i};
        WaitSecs(1);
    end
    
    %%%%%%%%%%%%%%%%%%%%% CHOOSE TO-BE-PLAYED STIMULUS %%%%%%%%%%%%%%%%%%%%
    thisStimIdx = ceil(rand * length(vsPool));
    
    switch thisKey
        case 'repeat'
            thisKey = lastKey;
            thisStimIdx = lastStimIdx;
        case 'blank' % do be added if necessary
        case 'stop'
            break 
        case ''
            error('Trial command from the host machine is empty')
    end
    
    %%%%%%%%%%%%%%%%%%%%%% PARALLEL PORT TRIGGER OUT %%%%%%%%%%%%%%%%%%%%%%
    % After constructing the stimulus texture we are now ready to
    % trigger the parallel port and begin our draw to the screen. This
    % function is located in the stimGen helper functions directory.
    % ParPortTrigger;
    
    %%%%%%%%%%%%%%%%%%%% IF NECESSARY PLAY A TONE %%%%%%%%%%%%%%%%%%%%%%%%%
    %     if thistrial.tone
    %         generateTone;
    %     end
    generateTone;
    WaitSecs(0.5);
    %%%%%%%%%%%%%%%%%%%%%%% DRAW DELAY GRAY SCREEN %%%%%%%%%%%%%%%%%%%%%%%%  
    % delay = thistrial.Timing(1); % If necessary add delay feature
    % drawBackgroundScreen(s,delay,s.grayPix);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%% PLAY STIMULUS %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    switch stimulusType
        case 'Full-field Grating'
            LeftRightFullFieldGrating(thisKey,screenInfo)
        case 'LeftRightMovingVS'
%             LeftRightMovingVS(thisKey, screenInfo, vsPool(thisStimIdx))
              DelayedMatchToSample(thisKey,screenInfo,vsPool(thisStimIdx))
        case 'DelayedMatchToSample'
            % generate a second unmatched stimulus
            if length(vsPool) > 1
            while length(thisStimIdx) == 1
                tmp = ceil(rand * length(vsPool));
                if ~isequal(tmp, thisStimIdx)
                    thisStimIdx(2) = tmp;
                end
            end
            end
            DelayedMatchToSample(thisKey,screenInfo,vsPool(thisStimIdx))
        otherwise
            error('Undefined stimulus type')
            %       case 'Blank'
            %           BlankVisualStimulus(thistrial, s);
            % Blank has been implemented in every StimulusType function. This
            % is better in the sense that we can control the timing of blank
            % trial to be the same as other stimuli
    end
    
    %%%%%%%%%%%%%%%%% DRAW INTERSTIMULUS GRAY SCREEN %%%%%%%%%%%%%%%%%%%%%%
    % Between trials we want to draw a gray screen for a time of wait
    %     wait = thistrial.Timing(3);
    %     drawBackgroundScreen(s,wait,s.grayPix);
    
    %%%%%%%%%%%%%%%%%%%% REPORT 'TrlDone' FOR BEHAVIOR %%%%%%%%%%%%%%%%%%%%
    % Is it necessary? to-be-discussed
    %     if isfield(thistrial, 'reportTrlDone')
    if ~isempty(connection)
        commu2host('reportTrlDone', connection.send, i);
    end
    
    lastKey = thisKey;
    lastStimIdx = thisStimIdx;
    
    %%%%%%%%%%%%%%%%%%%% SAVE VISUAL STIMULUS INFORMATION %%%%%%%%%%%%%%%%%
    fwrite(fileID, [i thisStimIdx], 'uint8');
end

fclose(fileID);

% Restore normal priority scheduling in case something else was set
% before:
% Priority(0);

%The same commands wich close onscreen and offscreen windows also close
%textures. We still need to close any screens opened prior to the trial
%loop ( the prep screen for example)
%Screen('CloseAll');

% IMPORTANT YOU MUST CLOSE EACH TEXTURE IN THE LOOP OTHERWISE THESE
% OBJECTS WILL REMAIN IN MEMORY FOR SOME TIME AND ULTIMATELY LEAD TO
% JAVA OUT OF MEMORY ERRORS!!!
Screen('CloseAll')
temp = instrfindall;
delete(temp)
%Screen('Close', gratingtex)

%%%%%%%%%%%%%%%%%%%%%%%% Turn On PTB verbose warnings %%%%%%%%%%%%%%%%%%%%%
Screen('Preference', 'Verbosity',3);
% please see the following page for an explanation of this function
%  http://psychtoolbox.org/FaqWarningPrefs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
java.lang.Runtime.getRuntime().gc % call garbage collect (likely useless)
return

