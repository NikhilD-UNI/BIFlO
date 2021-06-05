%with farm spacing.
%
%
clear 
clc

ModelSetup = ModelSetup;
load('Test_objects')
ModelSetup.Environment = environment;
ModelSetup.Environment.freestream_velocity = 10;
ModelSetup.Environment.Wind_direction = 0;
ModelSetup.Turbine = LW;
ModelSetup.WakeSummation = 'Quadratic';
ModelSetup.Wakemodel = 'Bastankah_TI';
ModelSetup.Turbine.Cp_calibration_distance = 0;
ModelSetup.Environment.TI_a = 0.05;
ModelSetup.Ground = 1;

D = ModelSetup.Turbine.Diameter;
A = pi*D^2 / 4 ;
rho = ModelSetup.Environment.density;

Data= struct();
L = [0 1];
%xcoord = [1000 1000 1000 1000];
xcoord = [D D D D D]*10;
%ycoord = [-7.5*D -2.5*D 2.5*D 7.5*D]; 
ycoord = [D D D D D]*10;

N_pairs = 1; % note this number dictates the number of staggered rows and pairs
N_turbs_row = 13; %turbines in front row , -1 for row behind
spacing = [1:1:3];

Data.nTurbs = (2*N_turbs_row -1)*N_pairs;

i_count = 1;
for i = [spacing]
    j_count = 1;
    for j = [spacing]

    xh1 = [zeros(1,N_turbs_row)];
    xh2 = [zeros(1,N_turbs_row-1)] + i*5*D;
    
    yh1 = j*5*D*[0:1:N_turbs_row-1];
    yh2 = j*5*D*[0:1:N_turbs_row-2] + j*5*D/2;
    
    xh = repmat([xh1 xh2],1,N_pairs);
    yh = repmat([yh1 yh2],1,N_pairs);
    
    correctx = 2*i*5*D*[reshape(repmat([0:1:N_pairs-1],2*N_turbs_row-1,1),1,numel(xh))];
    xh = xh + correctx;
    
    population = [xh yh];
    
    Data.farmDensity(i_count,j_count) = Data.nTurbs/((max(yh))*max(xh)/1000^2);
    
    
    for k = [1 0]
        
        ModelSetup.Blockage = k;
        
        [Vi,Vw,idx] = Inflow_Velocity(population,ModelSetup) ;
        %fval = fitness(population,ModelSetup);
        Cp = Cp_value(LW,Vi);
        fval = sum(0.5*rho*A*Cp(idx).*(Vi(idx).^3));
        fval2 = sum(0.5*rho*A*Cp.*(Vi.^3));
        
        if k == 1
            P_farm_front_block   = fval;
            P_farm_block   = fval2;
        elseif k == 0
            P_farm_front_no_block = fval;
            P_farm_no_block   = fval2;
        end
        
    end
    
    P_loss(i_count,j_count) = (P_farm_front_no_block - P_farm_front_block)/P_farm_front_no_block * 100;
    P_loss_farm(i_count,j_count) = (P_farm_no_block - P_farm_block)/P_farm_no_block * 100;
    
    j_count = j_count+1;
    end
    i_count = i_count+1
end

[Spacing_plot_x,Spacing_plot_y] = meshgrid(spacing*5,spacing*5);

figure
surf(Spacing_plot_x,Spacing_plot_y,P_loss)
xlabel('[S$_{x}$/D] ','fontsize',18,'interpreter','latex')
ylabel('[S$_{y}$/D] ','fontsize',18,'interpreter','latex')
% 
% figure
% surf(Spacing_plot_x,Spacing_plot_y,P_loss_farm)
% xlabel('[S$_{x}$/D] ','fontsize',18,'interpreter','latex')
% ylabel('[S$_{y}$/D] ','fontsize',18,'interpreter','latex')
