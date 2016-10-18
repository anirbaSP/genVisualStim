% For behavior expriment, visual stimulus computer is communicating with
% the host computer throughout the experiment. This file contains a
% commuInfo structure holding internet information as well as
% comunication type. It may be expanded later to do more.
%

% If you have no behavior experiment, please set
% commuInfo = [];

commuInfo.hostIP = '192.168.137.1';
commuInfo.hostPortS = 9090;
commuInfo.hostPortR = 9092;
commuInfo.vsIP = '192.168.137.3';
commuInfo.vsPortR = 9091;
commuInfo.vsPortS = 9093;
commuInfo.type = 'udp';
commuInfo.trialKeysFlag = 'key&';
commuInfo.triggerFlag = 'start'; % may come with post-fix trial information
commuInfo.stopFlag = 'stop';
commuInfo.TrlDoneFlag = 'TrlDone'; % pre-defined str that signals a trial is done