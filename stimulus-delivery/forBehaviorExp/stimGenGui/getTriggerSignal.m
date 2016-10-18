function getTriggerSignal(triggerType, commuInfo)
% GETTRIGGERSIGNAL monitors the trigger singal, it returns when the
% designed trigger signal is recieved. It's designed to supports universal
% trigger types, so we can flexibly add new trigger types as needed.

% See also COMMUINFORMATION

switch triggerType
    case 'udp'
        u = commuInfo.connection;  % udp ID
        triggerFlag = commuInfo.triggerFlag; % pre-defined flag that signals a trigger
        curData = '';
        while ~strcmp(curData, triggerFlag)
            curData = fscanf(u); % read the current udp data
        end
        
    otherwise
        error('undefined trigger signal')
end

