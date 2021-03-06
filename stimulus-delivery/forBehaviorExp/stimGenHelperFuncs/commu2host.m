%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%copyright (c) 2015  Pei Sabrina Xu
%
%this program is free software: you can redistribute it and/or modify
%it under the terms of the gnu general public license as published by
%the free software foundation, either version 3 of the license, or
%at your option) any later version.
%
%this program is distributed in the hope that it will be useful,
%but without any warranty; without even the implied warranty of
%merchantability or fitness for a particular purpose.  see the
%gnu general public license for more details.
%
%you should have received a copy of the gnu general public license
%along with this program.  if not, see <http://www.gnu.org/licenses/>.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function argout = commu2host(task, connection, curTrial)

commuInformation;

if isempty(commuInfo)
    argout = [];
    return
end

switch commuInfo.type
    case 'udp' 
        % turn off warning. Because it's normall to wait for udp data from
        % the host machine, turning off the uncessary timeout warning.
        warning('off','all')
        
        switch task
            case 'initiateReceiveConnection'
                ur = udp(commuInfo.hostIP, commuInfo.hostPortS, 'LocalPort', commuInfo.vsPortR);
                set(ur, 'InputBufferSize', 5000, 'OutputBufferSize', 5000, 'Timeout', 1)
                fopen(ur);
                
                argout = ur;
                
            case 'initiateSendConnection'
                us = udp(commuInfo.hostIP, commuInfo.hostPortR, 'LocalPort', commuInfo.vsPortS);
                set(us, 'InputBufferSize', 5000, 'OutputBufferSize', 5000, 'Timeout', 1)
                fopen(us);
                
                argout = us;
                
            case 'getTrialKeys'
                if nargin < 2
                    error('Please supply Connection as input')
                end
                u = connection;
                % find the flag for trailkey, the flag is a string
                curData = '';
                KbCheckFlag = 0;
                len = length(commuInfo.trialKeysFlag);
                while ~strncmp(curData, commuInfo.trialKeysFlag, len)
                    curData = fscanf(u);
                    
                    if KbCheck    
                        KbCheckFlag = 1;
                        break;
                    end
                end
                % Once find the flag, the next patch of data will be the trial key,
                % which is a binary data
                
                if KbCheckFlag
                    argout = [];
                else
                trialKeys = curData(len+1:end);
                trialKeys = str2num(trialKeys);
                
                argout = trialKeys;
                end
                
            case 'getTrialStartTrigger' % stop command is also handled here
                if nargin < 2
                    error('Please supply Connection as input')
                end
                u = connection;
                curData = '';
                KbCheckFlag = 0;
                pos = [];
                while isempty(pos)
                    curData = fscanf(u); % read the current udp data
                    if ~isempty(curData)
                        stopTrial = strncmp(curData, commuInfo.stopFlag, ...
                            length(commuInfo.stopFlag)); % check stop
                        if stopTrial
                            return % to do: check how to stop experiment 
                        else
                            pos = strfind(curData, commuInfo.triggerFlag);
                            if KbCheck
                                KbCheckFlag = 1;
                                break;
                            end
                        end
                    end
                end
                if KbCheckFlag
                    argout = [];
                else
                argout = str2num(curData(length(commuInfo.triggerFlag)+pos:end));
                end
                
            case 'reportTrlDone'
                if nargin < 3
                    error('Please supply Connection and current trial number as input')
                end
                u = connection;
                fprintf(u, [commuInfo.TrlDoneFlag ' %.3f'], curTrial);
                
                argout = 0; 
                
            otherwise
                error('Undefined task for UDP communication');
        end
        
        %warning('on','all')
        
    otherwise
        error('Undefined communication Type');
        % add cases for other types
end



