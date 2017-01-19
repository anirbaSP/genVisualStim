%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% copyright (c) 2015 Pei Sabrina Xu (based on Matthew Caudill 2012)
%
% this program is free software: you can redistribute it and/or modify it
% under the terms of the gnu general public license as published by the
% free software foundation, either version 3 of the license, or at your
% option) any later version.
%
% this program is distributed in the hope that it will be useful, but
% without any warranty; without even the implied warranty of
% merchantability or fitness for a particular purpose.  see the gnu general
% public license for more details.
%
% you should have received a copy of the gnu general public license along
% with this program.  if not, see <http://www.gnu.org/licenses/>.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function initState = stimGenInit(~)
% StimGenInit is a function that initializes the stimGen gui with user
% defined options. This file should be edited for each user/Rig
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Written by PSX 2015
% Modified by: PSX 10/18/2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % Set the user of this rig
% initState.user = 'PSX';

% Set the default mode, it can be 'behavior' or 'not behavior'
initState.behaviorOrNot = 1; 

% Set the defualt stimulus
initState.defaultStimType = 'DelayedMatchToSample';

% List all the stimulus types, --------To be added--------
initState.defaultStimTypes = {'Left Right Full-field Drifting Grating';
    'LeftRightMovingVS';
    'DelayedMatchToSampleMove';
    'DelayedMatchToSample'};

% Set the default table matching the above stimulus
% initState.defaultTable = ...
%     StimGenDefaultTable('Full-field Drifting Grating');

% Set the header
initState.header = '';

% Set the default file name 
initState.fileName = 'debug';

% Set the default trial state (1 = true (save) 0 = false (don't save)
initState.autoSave = 0;

initState.sudoTrial = ...
    {'1','2', '0', '1', '0', 'stop', };% 0 is repeat 'Blank', '2', '1', 'repeat', 'stop'};

initState.delay = 500000; % unit: us
initState.duration = 1;
end

