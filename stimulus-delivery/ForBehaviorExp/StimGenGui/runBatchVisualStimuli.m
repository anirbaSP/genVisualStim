%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%copyright (c) 2015 Sabrina Pei Xu and Matthew Caudill
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
function runBatchVisualStimuli(trials,s,connection)
%This function generates and draws a full field grating with parameters
%defined by the array of trials structures (see trialStruct.m). Trials
%structures are automatically generated from the table values in the gui
%by trialsStruct.m so your stimulus should take only one input namely
%trials. You can access parameters of a structure in the trials structure
%array using dynamic field referencing (e.g. trials(1).Orientation ...
%returns the orientaiton of trial 1). As you write your stimulus you can
%test it by creating a Default trials structure as done below so you can
%see if it is behaving as expected before adding it to the stimGen gui.

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

try
    % We will loop through our trials array structure, construct a grating
    % texture based on the values for each trial and then execute the
    % drawing in a while loop.
    
    % HIDE CURSOR FROM SCREEN
    % HideCursor;

    % Exit Codes and initialization
    KbCheckFlag = 0;
    % This is a flag indicating we need to break from the trials structure
    % loop below. The flag becomes true (=1) if the user presses any key

    % MAIN LOOP OVER TRIALS
    n_trial = numel(trials);
    for i = 1:n_trial
        
        thistrial = trials(i);
    
        %%%%%%% IF NECESSARY WATIT THE TRIGGER TO START THIS TRAIL%%%%%%%%%
        % We can use the trigger signal not only inidate a start, but also
        % more information. For example, below is an example that 1)empty
        % output indicate no trigger signal received, so we press the
        % keyboard to stop the loop; 2) output 1 and 2 represent specific
        % trial paramenters, eg. "Orientation".
        if isfield(thistrial, 'trigger')
            argout = commu2host('getTrialStartTrigger', connection.receive);
            if isempty(argout)   
               KbCheckFlag = 1;
            else
                 %%%% Here is a bug, if argout is empty, when we do not
                 %%%% recive pre-defined trial, we will not complete the
                 %%%% current trial due to lack trial info.
            switch argout  
                case 1
                    thistrial.Orientation = 0;
                case 2
                    thistrial.Orientation = 180; 
            end
            end
        end
                                 
        %%%%%%%%%%%%%%%%%%%%%%% PARALLEL PORT TRIGGER%%%%%%%%%%%%%%%%%%%%%%
        % After constructing the stimulus texture we are now ready to
        % trigger the parallel port and begin our draw to the screen. This
        % function is located in the stimGen helper functions directory.
        % ParPortTrigger;
        
        %%%%%%%%%%%%%%%%%%%% DRAW DELAY GRAY SCREEN %%%%%%%%%%%%%%%%%%%%%%%
        % DEVELOPER NOTE: Prior versions of stimuli used the func WaitSecs
        % to draw gray screens. This is a bad practice because the function
        % sleeps the matlab thread making the computer unresponsive to
        % KbCheck clicks. In addition PTB only guarantees the accuracy of
        % WaitSecs to the millisecond scale whereas VBL timestamps
        % described below uses GetSecs() a highly accurate submillisecond
        % estimate of the system time. All times should be referenced to
        % this estimate for better accuracy.
        
        % We start by performing an initial screen flip using Screen, we
        % return back a time called vbl. This value is a high precision
        % time estimate of when the graphics card performed a buffer swap.
        % This time is what all of our times will be referenced to. More
        % details at http://psychtoolbox.org/FaqFlipTimestamps
        delay = thistrial.Timing(1);
        drawBackgroundScreen(s,delay,s.grayPix);
        
        %%%%%%%%%%%%%%%%%%%%%% DRAW GRATING TEXTURE %%%%%%%%%%%%%%%%%%%%%%%   
        switch thistrial.Stimulus_Type
            case 'Full-field Grating'
                FullFieldGrating(thistrial, s);
            case 'Blank'
                BlankVisualStimulus(thistrial, s);
            otherwise
                error('Undefined stimulus type')
        end

            
        %%%%%%%%%%%%% DRAW INTERSTIMULUS GRAY SCREEN %%%%%%%%%%%%%%%%%%%%%%
        % Between trials we want to draw a gray screen for a time of wait
        wait = thistrial.Timing(3);
        drawBackgroundScreen(s,wait,s.grayPix);
        
        %%%%%%%%%%%%%%%% IF NECESSARY PLAY A TONE %%%%%%%%%%%%%%%%%%%%%%%%%
        if thistrial.tone
            generateTone;
        end
        
        %%%%%%%%%%%%%%%% REPORT 'TrlDone' FOR BEHAVIOR %%%%%%%%%%%%%%%%%%%%
        % Is it necessary? to-be-discussed
        if isfield(thistrial, 'reportTrlDone')
           commu2host('reportTrlDone', connection.send, i);
        end
        
    end
    
    % Restore normal priority scheduling in case something else was set
    % before:
    Priority(0);
    
    %The same commands wich close onscreen and offscreen windows also close
    %textures. We still need to close any screens opened prior to the trial
    %loop ( the prep screen for example)
    %Screen('CloseAll');
    
catch
    %this "catch" section executes in case of an error in the "try" section
    %above.  Importantly, it closes the onscreen window if its open.
    Screen('CloseAll');
    Priority(0);
    psychrethrow(psychlasterror);
end

%%%%%%%%%%%%%%%%%%%%%%%% Turn On PTB verbose warnings %%%%%%%%%%%%%%%%%%%%%
Screen('Preference', 'Verbosity',3);
% please see the following page for an explanation of this function
%  http://psychtoolbox.org/FaqWarningPrefs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
java.lang.Runtime.getRuntime().gc % call garbage collect (likely useless)
return




