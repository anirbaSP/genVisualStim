% u = instrfindall;
% delete(u)
% instrfindall

u1 = udp('192.168.137.3', 9091, 'LocalPort', 9090);
u1.Timeout = 20;
fopen(u1);
fwrite(u1, 1:10);
fclose(u1);
delete(u1);