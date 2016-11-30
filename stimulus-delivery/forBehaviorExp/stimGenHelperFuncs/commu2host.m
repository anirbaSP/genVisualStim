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
function argout = commu2host(task, connection, curTrialNum)
% This function reads the host command. Currently it support UDP
% communication. Any other comunication type can be added into the cases
% structure.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Written by PSX/September 2015
% Modified by: PSX/10-20-2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
                
            case 'getHeader'
                if nargin < 2
                    error('Please supply Connection as input')
                end
                u = connection;
                % find the flag for trailkey, the flag is a string
                curData = '';
                KbCheckFlag = 0;
                len = length(commuInfo.headerFlag);
                while ~strncmp(curData, commuInfo.headerFlag, len)
                    curData = fscanf(u);
                    
                    if KbCheck
                        KbCheckFlag = 1;
                        break;
                    end
                end
                % Once find the flag, the next patch of data will be the
                % header, which is a string
                
                if KbCheckFlag
                    argout = [];
                else
                    header = curData(len+1:end); % todo: what if header desen't
                    % arrive at one time? Consider to add a ending flag
                    
                    argout = header;
                end
                
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
                
            case 'getTrialStartTrigger' % get both trialKey and delay
                
                if nargin < 2
                    error('Please supply Connection as input')
                end
                u = connection;
                curData = '';
                KbCheckFlag = 0;
                value = [];
                cont2start = 1;
                flagc = {commuInfo.delayFlag};
                nflag = length(flagc);
                while isempty(value) || cont2start
                    curData = fscanf(u); % read the current udp data
                    if ~isempty(curData)
                        [namec valuec] = strread(curData, '%s %f');
                        if any(strcmp(commuInfo.stopFlag, namec))
                            argout = 'stop';
                            return
                        else
                            tmp = strcmp(commuInfo.triggerFlag, namec);
                            triggerValue = valuec(tmp);
                            for i = 1:nflag
                                tmp = strcmp(flagc{i},namec);
                                thisValue = valuec(tmp);
                                if length(thisValue) > 1
                                    thisValue = thisValue(end);
                                end
                                value= [value thisValue];
                            end
                        end
                        if ~isempty(triggerValue)
                            cont2start = 0;
                            value = [triggerValue value];
                        end
                    end
                    if KbCheck
                        KbCheckFlag = 1;
                        break;
                    end
                end
                 argout = value;
                if KbCheckFlag
                    argout = [];
                end
                
            case 'reportTrlDone'
                if nargin < 3
                    error('Please supply Connection and current trial number as input')
                end
                u = connection;
                fprintf(u, [commuInfo.TrlDoneFlag ' %.3f'], curTrialNum);
                
                argout = 0;
                
            otherwise
                error('Undefined task for UDP communication');
        end
        
        %warning('on','all')
        
    otherwise
        error('Undefined communication Type');
        % add cases for other types
end



