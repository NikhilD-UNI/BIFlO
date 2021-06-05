%unit test - Farm blockage point fence 

clear
clc
close all

ModelSetup = ModelSetup;
load('Test_objects')
ModelSetup.Environment = environment;
ModelSetup.Environment.freestream_velocity = 13;
ModelSetup.Environment.Wind_direction = 0;
ModelSetup.Turbine = LW;
ModelSetup.WakeSummation = 'Quadratic';
ModelSetup.Wakemodel = 'Bastankah';
ModelSetup.Blockage = 1;

population = randi([0 20000],1,100);

[V,~,idx_front] = Inflow_Velocity(population,ModelSetup);