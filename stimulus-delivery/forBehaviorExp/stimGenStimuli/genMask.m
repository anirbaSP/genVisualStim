function mask = genMask(szInDegree)
% This function generate the mask matrix, that output can feed to
% function _Screen_ to make a 2D mask for other texture we are drawing.
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
grayPix = GammaCorrect(grayLum);
degPerPix = monitorInfo.degPerPix;

% construct a 2-D grid of points to calculate our grating over
% (note we center the grating and extend it by one period)
szInPix = ceil(szInDegree/degPerPix);
mask = ones(szInPix+1, szInPix+1, 2) * grayPix;

% make a 2-D grid over mask positions (mx,my) to calculate
% the mask value
[mx,my]=meshgrid(-szInPix/2:szInPix/2,...
    -szInPix/2:szInPix/2);

% Calculate mask transparency vals (i.e. the 3rd Dimension
% over the gridpoints (note 255 is fully transparent)
mask(:, :, 2)=255 * (1-(mx.^2 + my.^2 <=...
    (szInPix/2).^2));

    
    
    
