%% Spacing Test on front row
%
%This test is to observe how percentage farm losses due to blockage vary
%with farm spacing.
%
%
clear 
clc

ModelSetup = ModelSetup;
load('Test_objects')
ModelSetup.Environment = environment;
ModelSetup.Environment.Wind_direction = 0;
ModelSetup.Turbine = LW;
ModelSetup.WakeSummation = 'Quadratic';
ModelSetup.Wakemodel = 'Bastankah';

D = ModelSetup.Turbine.Diameter;
A = pi*D^2 / 4 ;
rho = ModelSetup.Environment.density;

Data= struct();
L = [0 1];
%xcoord = [1000 1000 1000 1000];
xcoord = [0 10*D 20*D 30*D];
%ycoord = [-7.5*D -2.5*D 2.5*D 7.5*D]; 
ycoord = [D D D D];
figure

hcount = 1;
for h = 10
for j = 1: length(L);
count = 1;
for i = 0.4:0.1:15

ModelSetup.Environment.freestream_velocity = h;
ModelSetup.Blockage = L(j);

%population = [xcoord 3*xcoord 5*xcoord 7*xcoord 9*xcoord i*ycoord i*ycoord i*ycoord i*ycoord i*ycoord];
 population = [i*xcoord i*xcoord i*xcoord i*xcoord i*xcoord -7.5*ycoord -2.5*ycoord 2.5*ycoord 7.5*ycoord 12.5*ycoord];

pop(count,:) = population ;
%latteral spacing
% Data.Farm_density(hcount,count) = 20 / (9*i*(ycoord(4)-ycoord(1))/1000);
% Data.Spacing(hcount,count) = 5*i ;

%Depth Spacing
 Data.Farm_density(hcount,count) = 20 / (15*D*i*(xcoord(4)-xcoord(1))/1000^2);
 Data.Spacing(hcount,count) = 10*i ;
[Vi,Vw,idx] = Inflow_Velocity(population,ModelSetup) ; 
%fval = fitness(population,ModelSetup);  
Cp = Cp_value(LW,Vi);
fval = 0.5*rho*A*Cp(idx).*(Vi(idx).^3);

    if j == 1
        Data.farm_no_block(1:length(idx),count) = -fval;
    else
        Data.farm_with_block(1:length(idx),count) = -fval;
    end
    
    count = count + 1;
end
end


%  hcount = hcount+1;

end
diff = (Data.farm_no_block - Data.farm_with_block)./Data.farm_no_block * 100 ;

%edge turbines
plot(Data.Spacing,diff(1,:),'k')
hold on
%centre Turbines
plot(Data.Spacing,diff(2,:),'r')
grid on
%xlabel('Turbine Density [Turbines/km^{2}]')
xlabel('Normalised Streamwise Turbine Spacing')
ylabel('Power reduction incurred by farm blockage [%]')