function trialKeys = getTrialKeys(commuInfo)

switch commuInfo.type
    case 'udp'
        u = commuInfo.connection;
        trialsKeyFlag = commuInfo.trailsKeyFlag;
        
        % find the flag for trailkey, the flag is a string
        curData = '';
        while ~strcmp(curData, trialsKeyFlag)
            curData = fscanf(u);
        end
        % Once find the flag, the next patch of data will be the trial key,
        % which is a binary data
        trialKeys = fread(u);
    otherwise
        % add cases for other types
end
            
    