%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% copyright (c) 2015 Pei Sabrina Xu
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

% For behavior expriment, visual stimulus computer is communicating with
% the host computer throughout the experiment. This file contains a
% commuInfo structure holding internet information as well as comunication
% type. It may be expanded later to do more.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Written by PSX/September 2015
% Modified by: PSX/10-20-2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
commuInfo.headerFlag = 'header&';
commuInfo.delayFlag = 'dly';