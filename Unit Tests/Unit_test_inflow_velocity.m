%% Unit test inflow velocity
%This test looks at how the power within a farm changes based on turbine
%spacing in the lateral direction and what effects blockage have on those
%results.

clear 
clc

%% set up model
ModelSetup = ModelSetup;
load('Test_objects')
ModelSetup.Environment = environment;
ModelSetup.Environment.Wind_direction = 0;
ModelSetup.Turbine = LW;
ModelSetup.WakeSummation = 'Linear';
ModelSetup.Wakemodel = 'Jensen';

Data= struct();
L = [0 1 0 1];
for j = 1: length(L);
for i = 5:20

ModelSetup.Environment.freestream_velocity = i;
ModelSetup.Blockage = L(j);

if or(j == 1, j==2) 
population = [1000 1000 1000 1000 3000 3000 3000 3000 5000 5000 5000 5000 7000 7000 7000 7000 9000 9000 9000 9000 -1000 0 1000 2000 -1000 0 1000 2000 -1000 0 1000 2000 -1000 0 1000 2000 -1000 0 1000 2000];
else
population = [1000 1000 1000 1000 3000 3000 3000 3000 5000 5000 5000 5000 7000 7000 7000 7000 9000 9000 9000 9000 -500 0 500 1000 -500 0 500 1000 -500 0 500 1000 -500 0 500 1000 -500 0 500 1000];
end

[Vi,Vw] = Inflow_Velocity(population,ModelSetup) ; 
fval = fitness(population,ModelSetup)  ;

if or(j == 1, j==2) 
Data.powerbf(j,i) = fval;
else
Data.powerlf(j,i) = fval;
end

if mod(j,2) == 0
plot(i,-fval,'ko')
hold on
else
plot(i,-fval,'ro')
hold on
end

end
end

diff = (-Data.powerbf(1,5:20)) - (-Data.powerbf(2,5:20));
diff2 = (-Data.powerlf(3,5:20)) - (-Data.powerlf(4,5:20));
diff3 =((-Data.powerbf(1,5:20)) - (-Data.powerbf(2,5:20)))./(-Data.powerbf(1,5:20)) * 100 ;
diff4 = ((-Data.powerlf(3,5:20)) - (-Data.powerlf(4,5:20)))./(-Data.powerlf(3,5:20)) * 100; 

% figure
% plot(population(1:length(population)/2), population(length(population)/2  +1 :end),'kx')
 