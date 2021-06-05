% test script for population control

clear 
clc
%close all

x_boundary = [0 0  8000 8000];
y_boundary = [0 8000 8000 0];

[x_loc,y_loc] = Auto_Turbine_grid_seed(x_boundary,y_boundary);


population = randi([0 8000],1,10);%[0 0 1000 2000 0 8000 1000 2000];
ModelSetup = ModelSetup;
ModelSetup.Turbine.Diameter = 100;

for i = 1:98
population = population_control(population,ModelSetup,x_loc,y_loc,1,2);

[n.x, n.y]  = size(population);
xh = population(1:n.y/2);
yh = population((n.y/2 + 1) : end);

plot(xh,yh,'kx')
pause(0.5)
end
hold on
plot(x_loc,y_loc,'r.')