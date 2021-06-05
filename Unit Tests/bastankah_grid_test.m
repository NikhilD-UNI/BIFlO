% code to test the VC Model with ground effect
% 15/02/2021
% methodology from E.Branlard and Meyer Forsting 

clear
clc
close all

%% define some key parameters
load('Test_objects.mat');
environment.freestream_velocity = 16;
Uo = environment.freestream_velocity;
environment.Wind_direction = 0;
ModelSetup = ModelSetup;
ModelSetup.Environment = environment;
ModelSetup.Turbine     = LW;
ModelSetup.Grid_Method.Method = 'polar';
ModelSetup.Grid_Method.Resolution = 20;
ModelSetup.Grid_Method.nSectors = 72;

D = LW.Diameter;
zh= LW.Hubheight;       % hub height of turbine
xh = [0 5*D];
yh = [0 0];
R = D/2;                %radius [m]
A = pi*R^2;

p = population_sort([xh',yh'],ModelSetup);
xh = p(:,1)';
yh = p(:,2)';

[x_grid,y_grid,z_grid,weights] = grid_gen(p,ModelSetup);

ux1 = zeros([size(x_grid)]);      %initialises flow field
ux = zeros([size(x_grid)]);

% initialise flow container
u = Uo * ones([size(x_grid)]);

%% VC Elementary model test - here the flow is alligned an axisymmetric
for j = 1:1
    for i = 1: length(xh)
        
        
        ct = CT_value(LW,u(1,1,i));             % thrust coefficient
        gamma_t(i,j) = -u(1,1,i)*(1 - sqrt(1-ct));   % tangential vortex [m/s]
        fprintf('Turbine %d gamma_t %.5f \n',i,gamma_t(i,j));
        
        %% test bed for the elementary vortex cylindrer programme
        %ux = elementary_vortex_cylinder(x_grid,y_grid,z_grid,gamma_t(i,j),LW,environment,xh(i),yh(i));
        %ux = skewed_vortex_cylinder(x_grid,y_grid,z_grid,gamma_t(i,j),ct,LW,environment,xh(i),yh(i));
        %[Uw ,Vi(i,:), A(i,:)] = Jensen_Wake_model_VC(x_grid,y_grid,z_grid,Uo,LW,environment,xh,yh,i);
        [Uw,Vi] = Bastankah_original_wake(x_grid,y_grid,z_grid,u(1,1,i),LW,environment,xh,yh,i);
        
        ux1 = ux1 + ux + Uw;
        u = u + Uw;
    end
u = Uo + ux1;
ux1 = zeros([size(x_grid)]);
fprintf('\n')
end
