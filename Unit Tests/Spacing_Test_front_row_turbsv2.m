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
ModelSetup.Wakemodel = 'Jensen';

D = ModelSetup.Turbine.Diameter;
A = pi*D^2 / 4 ;
rho = ModelSetup.Environment.density;

Data= struct();
L = [0 1];
%xcoord = [1000 1000 1000 1000];
xcoord = [0 10*D 20*D 30*D 40*D];
%ycoord = [-7.5*D -2.5*D 2.5*D 7.5*D]; 
ycoord = [D D D D D];
figure

for k = 1:2
    hcount = 1;
    for h = 10
        for j = 1: length(L);
            count = 1;
            for i = 0.5:0.1:5
                
                ModelSetup.Environment.freestream_velocity = h;
                ModelSetup.Blockage = L(j);
                
                if k == 1
                    %population = [xcoord 3*xcoord 5*xcoord 7*xcoord 9*xcoord i*ycoord i*ycoord i*ycoord i*ycoord i*ycoord];
                    population = [i*xcoord i*xcoord i*xcoord i*xcoord i*xcoord -10*ycoord -5*ycoord 0*ycoord 5*ycoord 10*ycoord];
                    N = numel(population);
                elseif k ==2
                    xcoord = [D D D D D];
                    ycoord = [-7.5*D -2.5*D 0 2.5*D 7.5*D];
                    population = [xcoord 3*xcoord 5*xcoord 7*xcoord 9*xcoord i*ycoord i*ycoord i*ycoord i*ycoord i*ycoord];
                end
                
                pop(count,:) = population ;
                if k == 2
                    %latteral spacing
                    Data.Farm_density(hcount,count) = 20 / (9*i*(ycoord(4)-ycoord(1))/1000);
                    Data.Spacing(hcount,count,k) = 5*i ;
                    
                elseif k == 1
                    %Depth Spacing
                    Data.Farm_density(hcount,count) = (N/2) / (20*D*i*(xcoord(4)-xcoord(1))/1000^2);
                    Data.Spacing(hcount,count,k) = 10*i ;
                    
                end
                [Vi,Vw,idx] = Inflow_Velocity(population,ModelSetup) ;
                %fval = fitness(population,ModelSetup);
                Cp = Cp_value(LW,Vi);
                fval = sum(0.5*rho*A*Cp(idx).*(Vi(idx).^3));
                
                if j == 1
                    Data.farm_no_block(hcount,count,k) = -fval;
                else
                    Data.farm_with_block(hcount,count,k) = -fval;
                end
                
                count = count + 1;
            end
        end
        
        
        hcount = hcount+1;
        
    end
end

diff = (Data.farm_no_block - Data.farm_with_block)./Data.farm_no_block * 100 ;

%edge turbines
for i = 1:hcount-1 
plot(Data.Spacing,diff(i,:))
hold on
end
grid on

xlabel('Turbine Density [Turbines/km^${2}$]','Interpreter','latex')

%xlabel('Normalised Streamwise Turbine Spacing','interpreter','latex')
ylabel('Power reduction incurred by farm blockage [\%]','Interpreter','latex')