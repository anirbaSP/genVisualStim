function generateTone

% Beep=sin([1:400]); 
% rate=22254; 
% for n=1:1000 
% sound(Beep,rate); 
% pause((length(Beep)/rate)) 
% clear playsnd 
% end

fs = 44100; % sampling frequency
T = 0.2;
t = 0:(1/fs):T;

f = 8000; % tone frequency
a = 0.2;
y = a*sin(2*pi*f*t);

sound(y, fs);