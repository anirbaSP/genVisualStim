function s = setflipCheckforScreen(s, flipCheck)

switch flipCheck
    case 'frame'
        frameON = s.whitePix;
        frameOFF = s.blackPix;
    case 'trial'
        frameON = s.blackPix;
        frameOFF = s.blackPix;
    otherwise
        error('FlipCheck each frame or trial? Unrecognizable mode')
end
s.frameON = frameON;
s.frameOFF = frameOFF;