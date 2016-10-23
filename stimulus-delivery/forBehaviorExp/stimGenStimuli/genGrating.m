function grating = genGrating(spaceFreq, contrast, szInDegree)
% This function generate the grating vector, that output can feed to
% function _Screen_ to make a static grating texture of a drifting grating.
% We need the contrast and the spatial frequency. 
% INPUT:
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Written by PSX/10-08-2016 (based on Matthew Caudill 2012)
% Modified by: PSX/
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
monitorInformation;
whiteLum = PixToLum(WhiteIndex(monitorInfo.screenNumber));
blackLum = PixToLum(BlackIndex(monitorInfo.screenNumber));
grayLum = (whiteLum + blackLum)/2;
degPerPix = monitorInfo.degPerPix;

% convert to pixel units
pxPerCycle = ceil(1/(spaceFreq*degPerPix));
freqPerPix = (spaceFreq*degPerPix)*2*pi;

% construct a 2-D grid of points to calculate our grating over
% (note we center the grating and extend it by one period)
szInPix = ceil(szInDegree/degPerPix);
x = meshgrid(-(szInPix)/2:(szInPix)/2 + pxPerCycle, 1);

% compute the grating in Luminance values
grating = grayLum + (whiteLum-grayLum)*contrast*cos(freqPerPix*x);

% convert the grating to pixel values
grating = GammaCorrect(grating);

