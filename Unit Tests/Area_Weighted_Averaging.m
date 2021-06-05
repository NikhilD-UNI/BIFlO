% code to test the VC Model with ground effect
% Convergence test on area weighted averaging 

clear
clc
close all

%% define some key parameters
load('Test_objects.mat');
environment.freestream_velocity = 16;
Uo = environment.freestream_velocity;
environment.Wind_direction = 5;
ModelSetup = ModelSetup;
ModelSetup.Environment = environment;
ModelSetup.Turbine     = LW;
ModelSetup.Grid_Method.Method = 'polar';
ModelSetup.Grid_Method.Resolution = 50;
ModelSetup.Grid_Method.nSectors = 36;

D = LW.Diameter;
zh= LW.Hubheight;       % hub height of turbine
xh = D*[0 5 0];               %x coordinate of turbine
yh = [-0.75*D 0 0.75*D];               %y coordinate of turbine
R = D/2;                %radius [m]

p = population_sort([xh',yh'],ModelSetup);
xh = p(:,1)';
yh = p(:,2)';

[x_grid,y_grid,z_grid,weights] = grid_gen(p,ModelSetup);

% initialise flow container
u = zeros([size(x_grid)]);
Data = struct();

%% VC Elementary model test - here the flow is alligned an axisymmetric
for i = 1:100 
    for j = 1:100
        ModelSetup.Grid_Method.Resolution = i;
        ModelSetup.Grid_Method.nSectors = j;
        [x_grid,y_grid,z_grid,weights] = grid_gen(p,ModelSetup);
        
        Data.ngrid(i,j) = j; %* ModelSetup.Grid_Method.nSectors;
        [Uw,Vi] = Bastankah_original_wake(x_grid,y_grid,z_grid,Uo,LW,environment,xh,yh,1,1,weights);
        %         u = Uw;
        Data.Vel(i,j) = Vi(3);
    end
    disp(i);
end

[x,y] = meshgrid([1:100],[1:100]);
surf(x,y,Data.Vel)
% semilogx(Data.ngrid,Data.Vel,'k')
grid on
ylabel('Average Inflow Velocity [m/s]')