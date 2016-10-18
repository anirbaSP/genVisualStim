function KbCheckFlag = drawBackgroundScreen(screenInfo,displayTime,fillColor)
%drawBackgroundScreen draws a screen to window specified by screenInfo for
%a duration displayTime with color fillColor and is updated at interframe
%interval (ifi, also specified by screenInfo). It is called by each of the
%visual stimuli and allows for adaptation to the change in luminance before
%the presentation of a stimulus.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%copyright (c) 2012  Matthew Caudill
%revised by Pei Sabrina Xu (2015)
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

%%%%%%%%%%%%%%%%%%%%%% DRAW PRESTIM GRAY SCREEN %%%%%%%%%%%%%%%%%%%%%%%%%%%
% We will draw an initialization gray screen to last
% trials(1).Initialization_Screen (s) long before the stimulus begins

% We start by performing an initial screen flip using Screen, we return
% back a time called vbl. This value is a high precision time estimate
% of when the graphics card performed a buffer swap. This time is what
% all of our times will be referenced to. More details at
% http://psychtoolbox.org/FaqFlipTimestamps

w = screenInfo.w;
screenRect = screenInfo.screenRect;
whitePix = screenInfo.whitePix;
waitframes = screenInfo.waitframes;
ifi = screenInfo.ifi;

KbCheckOn = 1; %screenInfo.KbCheckOn;
KbCheckFlag = 0; % KbCheckFlag is default to be 0

vbl=Screen('Flip', w);

% The time that the init screen will be drawn 
time = vbl + displayTime;

% Display a gray screen while the vbl is less than delay time. NOTE
% we are going to add 0.5*ifi to the vbl to give us some headroom
% to take possible timing jitter or roundoff-errors into account.
while (vbl < time)
    % Draw a gray screen
    Screen('FillRect', w, fillColor);
    
    FlipCheck(w, screenRect, [whitePix, whitePix], 0)
    
    % update the vbl timestamp and provide headroom for jitters
    vbl = Screen('Flip', w, vbl + (waitframes - 0.5) * ifi);
    
    if KbCheckOn % exit the while loop and flag to one if user presses any key
        if KbCheck
            KbCheckFlag = 1;
            break;
        end
    end
end


