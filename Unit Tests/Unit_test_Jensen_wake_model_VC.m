%Unit test script for Jensen Wake Model VC
clear
clc
close all

%% define some key parameters
load('Test_objects.mat');
environment.freestream_velocity = 13;
Uo = environment.freestream_velocity;
environment.Wind_direction = 0;
D = LW.Diameter;
R = D/2;                  %radius [m]
zh= LW.Hubheight;         %hub height of turbine
xh = [5*D 0 10*D];             % x coordinate of turbine
yh = [0 0 100];                   % y coordinate of turbine
x = xh%[-2.5*D:D/10:5*D] ;   %x-coordinates in grid
y = 0%[-3*D:D:3*D]   ;   %y-coordinates in grid
z = zh%[0:zh/5:1.5*zh]       ;   %z-coordinates in grid


% x_local = x-xh;
% y_local = y-yh;
% z_local = z-zh;
% 
% % locate poaition where we want to take our ct value from
% idz = max(find(z_local<=0));
% idy = max(find(y_local<=0));
% idx = find(min(x_local));

%[x_grid,y_grid,z_grid] = meshgrid(x_local,y_local,z_local); % create mesh
[x_grid,y_grid,z_grid] = meshgrid(x,y,z);

[Uw, V ,A] = Jensen_Wake_model_VC(x_grid,y_grid,z_grid,Uo,LW,environment,xh,yh,1);

%contour((x_grid(:,:,idz))/R,(y_grid(:,:,idz))/R,Uw(:,:,idz)/Uo,40,'Fill','on')