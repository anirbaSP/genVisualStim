%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%copyright (c) 2012  Matthew Caudill
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
% This file contains all the monitor information for the Two Photon Rig;
% all information is stored in a monitor structure

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Written by MSC/2012
% Modified by: PSX/10-20-2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%% MONITOR INFORMATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

monitorInfo.screenNumber = 1;
monitorInfo.screenDistcm = 25;
monitorInfo.screenSizecmX = 52; %32.5; %         
monitorInfo.screenSizecmY = 29; %22.7; %       
monitorInfo.screenSizeDegX = 2*atan(monitorInfo.screenSizecmX/2/...
                                monitorInfo.screenDistcm)*180/pi;
monitorInfo.screenSizeDegY = 2*atan(monitorInfo.screenSizecmY/2/...
                                monitorInfo.screenDistcm)*180/pi;
monitorInfo.screenSizePixX = 1920; %1280; %
monitorInfo.screenSizePixY = 1080; %800; %
monitorInfo.degPerPix = monitorInfo.screenSizeDegX/...
                            monitorInfo.screenSizePixX;

monitorInfo.powerLawScaleFactor = .0001801;
monitorInfo.gamma = 2.386;
monitorInfo.waitframes = 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

