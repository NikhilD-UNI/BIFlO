%% Spacing Test
%
%This test is to observe how percentage farm losses due to blockage vary
%with farm spacing.
%
%
clear 
clc


Data= struct();
L = [0 1];
xcoord = [1000 1000 1000 1000];
ycoord = [-750 -250 250 750]; 
figure

hcount = 1
for h = 6:2:20
for j = 1: length(L);
count = 1;
for i = 0.5:0.1:15

ModelSetup = ModelSetup;
load('Test_objects')
ModelSetup.Environment = environment;
ModelSetup.Environment.freestream_velocity = h;
ModelSetup.Environment.Wind_direction = 0;
ModelSetup.Turbine = LW;
ModelSetup.WakeSummation = 'Linear';
ModelSetup.Wakemodel = 'Bastankah';
ModelSetup.Blockage = L(j);

population = [xcoord 3*xcoord 5*xcoord 7*xcoord 9*xcoord i*ycoord i*ycoord i*ycoord i*ycoord i*ycoord];
pop(count,:) = population ;
Data.Farm_density(hcount,count) = 20 / (9*i*(ycoord(4)-ycoord(1))/1000);
% [Vi,Vw] = Inflow_Velocity(population,ModelSetup) ; 
fval = fitness(population,ModelSetup);  

    if j == 1
        Data.farm_no_block(hcount,count) = -fval;
    else
        Data.farm_with_block(hcount,count) = -fval;
    end
    count = count + 1;
end
end
diff(hcount,:) = (Data.farm_no_block(hcount,:) - Data.farm_with_block(hcount,:))./Data.farm_no_block(hcount,:) * 100;
plot(Data.Farm_density(hcount,:),diff(hcount,:))
hold on

 hcount = hcount+1;

end
grid on
xlabel('Turbine Density [Turbines/km^{2}]')
ylabel('Power reduction incurred by farm blockage [%]')
% figure
% plot(population(1:length(population)/2), population(length(population)/2  +1 :end),'kx')