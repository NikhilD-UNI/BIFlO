% with farm spacing.
% Looking at how angling a wind farm can change the potential power
% extraction
%
clear 


ModelSetup = ModelSetup;
load('Test_objects')
ModelSetup.Environment = environment;
ModelSetup.Environment.freestream_velocity = 10;
ModelSetup.Environment.Wind_direction = 0;
ModelSetup.Turbine = LW;
ModelSetup.WakeSummation = 'Quadratic';
ModelSetup.Wakemodel = 'Jensen';
ModelSetup.Turbine.Cp_calibration_distance = 0;
ModelSetup.Environment.TI_a = 0.1;
ModelSetup.Ground = 1;

D = ModelSetup.Turbine.Diameter;
A = pi*D^2 / 4 ;
rho = ModelSetup.Environment.density;

Data= struct();
L = [0 1];

N_rows = 8;
N_cols = 8;
x_spacing = 5*D;
y_spacing = 5*D;

Data.nTurbs = N_rows * N_cols;
turb_no =[1:1:N_cols-1,N_cols:N_cols:Data.nTurbs];

angle = 0:10:80 ;

i_count = 1
for i = [angle]
    
    xh = [0:x_spacing:(N_rows-1)*x_spacing];
    xh = repmat(xh,N_cols,1);
    xh = reshape(xh,1,Data.nTurbs);
    
    yh = [0:y_spacing:(N_cols-1)*y_spacing];
    yh = repmat(yh,N_rows,1)';
    offsety = x_spacing*tand(i)*[0:1:N_rows-1];
    offsety = repmat(offsety,N_cols,1);
    yh = offsety + yh;
    yh = reshape(yh,1,Data.nTurbs);
       
    population = [xh yh];
    
    %Data.farmDensity(i_count,j_count) = Data.nTurbs/((max(yh))*max(xh)/1000^2);
    
    
    for k = [1 0]
        
        ModelSetup.Blockage = k;
        
        [Vi,Vw,idx] = Inflow_Velocity(population,ModelSetup) ;
        %fval = fitness(population,ModelSetup);
        Cp = Cp_value(LW,Vi);
        fval = sum(0.5*rho*A*Cp(idx).*(Vi(idx).^3));
        fval2 = sum(0.5*rho*A*Cp.*(Vi.^3));
        
        if k == 1
            
            P(i_count,:) = 0.5*rho*A*Cp([turb_no]).*(Vi([turb_no]).^3);
            P_norm(i_count,:) = P(i_count,:)/P(i_count,N_cols);
            %P_norm(i_count,:) = P(i_count,:)/mean(P(i_count,:));
            
            P_farm_front_block   = fval;
            P_farm_block   = fval2;
        elseif k == 0
            P_farm_front_no_block = fval;
            P_farm_no_block   = fval2;
        end
        
    end
    
    P_loss(i_count) = (P_farm_front_no_block - P_farm_front_block)/P_farm_front_no_block * 100;
    P_loss_farm(i_count) = (P_farm_no_block - P_farm_block)/P_farm_no_block * 100;
    
    i_count = i_count + 1;

end
%[Spacing_plot_x,Spacing_plot_y] = meshgrid(spacing*5,spacing*5);

% figure
% surf(Spacing_plot_x,Spacing_plot_y,P_loss)
% xlabel('[S$_{x}$/D] ','fontsize',18,'interpreter','latex')
% ylabel('[S$_{y}$/D] ','fontsize',18,'interpreter','latex')
% 
% figure
% surf(Spacing_plot_x,Spacing_plot_y,P_loss_farm)
% xlabel('[S$_{x}$/D] ','fontsize',18,'interpreter','latex')
% ylabel('[S$_{y}$/D] ','fontsize',18,'interpreter','latex')