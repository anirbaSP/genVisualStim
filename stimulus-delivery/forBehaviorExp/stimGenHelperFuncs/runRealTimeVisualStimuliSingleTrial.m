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

function  handles = runRealTimeVisualStimuliSingleTrial(handles)
% This is the single trial version of the function
% _runRealTimeVisualStimuli_ (see detail discription there) . It's called
% by the GUI _stimGenforBeh_. There are basically the following INPUT,
% which is parsed by the GUI handles.
%   curTrialNum
%   sudoTrial
%   connection
%   vsPool
%   lastKey
%   lastStimIdx
%   stimType
%   screenInfo

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Written by PSX/Oct 2016
% Modified by: PSX/
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% get input from handles
curTrialNum = handles.curTrialNum;
sudoTrial = handles.sudoTrial;
connection = handles.connection;
vsPool = handles.vsPool;
lastKey = handles.lastKey;
lastStimIdx = handles.lastStimIdx;
stimType = handles.stimType;
screenInfo = handles.screenInfo;
duration = handles.duration;

%%%%%%%%%%%%%%%%%%%% WAIT THE TRIGGER TO START THIS TRAIL %%%%%%%%%%%%%%%%%
% We can use the trigger signal not only inidate a start, but also
% more information. For example, below is an example that 1)empty
% output indicate no trigger signal received, so we press the
% keyboard to stop the loop; 2) output 1 and 2 represent specific
% trial paramenters, eg. "Orientation".
curTrialNum = curTrialNum + 1;
if ~isempty(connection)
    thisKey = commu2host('getTrialStartTrigger', connection.receive);
    if isnumeric(thisKey) && length(thisKey) == 2;
        handles.delay = thisKey(2);
        thisKey = thisKey(1);
    end
    if isnumeric(thisKey)
        thisKey = num2str(thisKey);
    end    
else
    thisKey = sudoTrial{curTrialNum};
    WaitSecs(1);
end

delay = handles.delay * 10^(-6);

%%%%%%%%%%%%%%%%%%%%% CHOOSE TO-BE-PLAYED STIMULUS %%%%%%%%%%%%%%%%%%%%
thisStimIdx = ceil(rand * length(vsPool));

switch thisKey
    case '0'
        thisKey = lastKey;
        thisStimIdx = lastStimIdx;
    case 'blank' % necessary?
    case 'stop'
        set(handles.stop, 'Value', 1);
        return
    case ''
        warndlg('Trial command from the host machine is empty')
        set(handles.stop, 'Value', 1);
        return
end

%%%%%%%%%%%%%%%%%%%%%% PARALLEL PORT TRIGGER OUT %%%%%%%%%%%%%%%%%%%%%%%%%%
% After constructing the stimulus texture we are now ready to
% trigger the parallel port and begin our draw to the screen. This
% function is located in the stimGen helper functions directory.
% ParPortTrigger;

%%%%%%%%%%%%%%%%%%%% IF NECESSARY PLAY A TONE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     if thistrial.tone
%         generateTone;
%     end
% generateTone;
% WaitSecs(0.5);
%%%%%%%%%%%%%%%%%%%%%%% DRAW DELAY GRAY SCREEN %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% delay = thistrial.Timing(1); % If necessary add delay feature
% drawBackgroundScreen(s,delay,s.grayPix);

%%%%%%%%%%%%%%%%%%%%%%%%%%%% PLAY STIMULUS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
thisKey
switch stimType
    case 'Full-field Grating'
        LeftRightFullFieldGrating(thisKey,screenInfo)
    case 'LeftRightMovingVS'
        % LeftRightMovingVS(thisKey, screenInfo, vsPool(thisStimIdx))
        DelayedMatchToSample(thisKey,screenInfo,vsPool(thisStimIdx),...
            duration, delay, struct('move', true))
    case 'DelayedMatchToSampleMove'
        % generate a second unmatched stimulus
        if length(vsPool) > 1
            while length(thisStimIdx) == 1
                tmp = ceil(rand * length(vsPool)); % randomly choose adistractor
                if ~isequal(tmp, thisStimIdx)
                    thisStimIdx(2) = tmp;
                end
            end
        end
        DelayedMatchToSample(thisKey,screenInfo,vsPool(thisStimIdx), ...
            duration, delay, struct('move', true))
    case 'DelayedMatchToSample'
        % generate a second unmatched stimulus
        if length(vsPool) > 1
            while length(thisStimIdx) == 1
                tmp = ceil(rand * length(vsPool)); % randomly choose adistractor
                if ~isequal(tmp, thisStimIdx)
                    thisStimIdx(2) = tmp;
                end
            end
        end
        DelayedMatchToSample(thisKey,screenInfo,vsPool(thisStimIdx), ...
            duration, delay)
    otherwise
        error('Undefined stimulus type')
        %       case 'Blank'
        %           BlankVisualStimulus(thistrial, s);
        % Blank has been implemented in every StimulusType function. This
        % is better in the sense that we can control the timing of blank
        % trial to be the same as other stimuli
end

%%%%%%%%%%%%%%%%% DRAW INTERSTIMULUS GRAY SCREEN %%%%%%%%%%%%%%%%%%%%%%%%%%
% Between trials we want to draw a gray screen for a time of wait
%     wait = thistrial.Timing(3);
%     drawBackgroundScreen(s,wait,s.grayPix);

%%%%%%%%%%%%%%%%%%%% REPORT 'TrlDone' FOR BEHAVIOR %%%%%%%%%%%%%%%%%%%%%%%%
% Is it necessary? to-be-discussed
%     if isfield(thistrial, 'reportTrlDone')
if ~isempty(connection)
    commu2host('reportTrlDone', connection.send, curTrialNum);
end

handles.lastKey = thisKey;
handles.lastStimIdx = thisStimIdx;
handles.curTrialNum = curTrialNum;
handles.vsTrial(curTrialNum,:) = thisStimIdx;
