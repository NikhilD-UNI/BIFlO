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
ModelSetup.Wakemodel = 'Jensen';

D = ModelSetup.Turbine.Diameter;
A = pi*D^2 / 4 ;
rho = ModelSetup.Environment.density;

Data= struct();
L = [0 1];
%xcoord = [1000 1000 1000 1000];
xcoord = [D D D D D]*10;
%ycoord = [-7.5*D -2.5*D 2.5*D 7.5*D]; 
ycoord = [D D D D D]*10;

N_turb = 5; % note this number actually dictates number of rows and columns
spacing = [0.8:0.1:3];

i_count = 1;
for i = [spacing]
    j_count = 1;
    for j = [spacing]

    xh = i*10*D*[0:1:N_turb-1]; % streamwise
    yh = j*10*D*[0:1:N_turb-1]; % spanwise
    
    [xh,yh] = meshgrid(xh,yh);
    
    xh = reshape(xh,1,numel(xh));
    yh = reshape(yh,1,numel(yh));
    population = [xh yh];
    
    
    for k = [1 0]
        
        ModelSetup.Blockage = k;
        
        [Vi,Vw,idx] = Inflow_Velocity(population,ModelSetup) ;
        %fval = fitness(population,ModelSetup);
        Cp = Cp_value(LW,Vi);
        fval = sum(0.5*rho*A*Cp(idx).*(Vi(idx).^3));
        
        if k == 1
            P_farm_front_block   = fval;
        elseif k == 0
            P_farm_front_no_block = fval;
        end
        
    end
    
    P_loss(i_count,j_count) = (P_farm_front_no_block - P_farm_front_block)/P_farm_front_no_block * 100;
    
    j_count = j_count+1;
    end
    i_count = i_count+1
end

[Spacing_plot_x,Spacing_plot_y] = meshgrid(spacing*10,spacing*10);

figure
surf(Spacing_plot_x,Spacing_plot_y,P_loss)
xlabel('Normalised Streamwise Spacing Between Turbines [S$_{x}$/D] ','fontsize',18,'interpreter','latex')
ylabel('Normalised  Spanwise Spacing Between Turbines [S$_{y}$/D] ','fontsize',18,'interpreter','latex')

