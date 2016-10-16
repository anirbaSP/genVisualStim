function reportTrlDone(commuType, commuInfo)
% REPORTTRIALDONE send out a signal to indicate the current trial is done,
% e.g. in a behavior experiment, the visual stimulus computer send out a
% string 'TrlDone' to the host computer at the end of each trial. It's
% designed to supports universal comunication types, so we can flexibly add
% new communication types as needed.

% See also COMMUINFORMATION

switch commuType
    case 'udp'
        u = commuInfo.connection;  % udp ID
        % pre-defined str that signals a trial is done
        TrlDoneFlag = commuInfo.TrlDoneFlag; 
       
        fprintf(u, TrlDoneFalg);
        
    otherwise
        error('undefined trigger signal')
end