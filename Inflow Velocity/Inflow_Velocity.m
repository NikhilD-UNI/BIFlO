function [Vi,Vw,idx_front_row] = Inflow_Velocity(population,ModelSetup)

% load key variables and create a copy of key classes
turbine     = ModelSetup.Turbine;
environment = ModelSetup.Environment;
Wake_Model  = ModelSetup.Wakemodel;
Wake_Summation_Model = ModelSetup.WakeSummation;
cpd = turbine.Cp_calibration_distance;
Ground      = ModelSetup.Ground;
%% Global pre processing
% population is a 1D string containg the individual population's
% chromosones/genomes

[n.x, n.y]  = size(population);
%reformat the population to account for 2D effects. Exception is for 1D
%model:

if strcmp(Wake_Model,'Jensen_1D') == 0
    %genome string contains [X Y] = [x1,x2,x3 ....xn, y1,y2,y3....yn]
    xh = population(1:n.y/2);
    yh = population((n.y/2 + 1) : end);
    population = [xh',yh'];
    [population,~,idx_front_row] = population_sort(population,ModelSetup);
    [n.x, n.y]  = size(population);
end

%% Implementation of Model
switch Wake_Model
    case 'Jensen_1D'
        if (n.x > 1) && (n.y > 1)
            error('A 1D model has been selected. The Population matrix does not contain a 1D set of coordinates')
        end
        if n.x == 1
            population = population';
            n.x = n.y;
            n.y = 1;
        end
        % local Pre Processing - if population needs to be ordered in sequence
        [population I] = sort(population);
        
        %Define mesh/grid parameters
        [x_grid,y_grid,z_grid] = grid_gen(population,ModelSetup);
        
        %initialise velocity variables
        Vw = zeros(n.x,n.x);   %wave velocity influence matrix
        ux_induced = zeros(n.x,1); %induced velocity container
        Uo = environment.freestream_velocity;
        
        if ModelSetup.Blockage == 0
            
            Vw = Jensen_wake_model_1d(population,turbine,environment,Vw,Wake_Summation_Model);
            Vi = diag(Vw);
            
        elseif ModelSetup.Blockage == 1
            %Calculate Vw matrix and inflow velocities
            for j = 1:4
                Vw = Jensen_wake_model_1d(population,turbine,environment,Vw,Wake_Summation_Model);
                Vi = diag(Vw);
                
                %calculating the induction flow field
                for i = 1:n.x
                    xh = population(i);
                    yh = 0;
                    ct = CT_value(turbine,Vi(i));
                    gamma_t = Tang_vorticity_strength(Vi(i),ct,ModelSetup);
                    
                    %ux = elementary_vortex_cylinder(x_grid,y_grid,z_grid,gamma_t,turbine,environment,xh,yh,Ground);
                    ux = skewed_vortex_cylinder(x_grid,y_grid,z_grid,gamma_t,ct,turbine,environment,xh,yh,Ground);
                    ux_induced = ux_induced + ux';
                end
                u = Uo + ux_induced(1);
                Vw(1,1) = u;
                % disp(Vi(1));
                ux_induced = zeros(n.x,1);
            end
        end
        %       Vi is in the ordered format and needs to change back
        Vi(I) = Vi;
        
        
        
    case 'Jensen'
        %Define mesh/grid parameters
        ModelSetup.Grid_Method.Method = 'cartesian';
        [x_grid,y_grid,z_grid] = grid_gen(population,ModelSetup);
        
        %Define mesh/grid parameters for blockage model
        ModelSetup.Grid_Method.Method = 'front_row';
        ModelSetup.Turbine.Cp_calibration_distance= 328;
        [x_grid2,y_grid2,z_grid2] = grid_gen(population,ModelSetup,idx_front_row);
        
        %initialise velocity variables
        Vw = zeros(n.x,n.x);   %wake velocity influence matrix
        ux_induced = zeros(1,n.x); %induced velocity container
        Uo_init = environment.freestream_velocity;
        environment.freestream_velocity = Uo_init * ones(1,n.x);
        
        if ModelSetup.Blockage == 0
            Vw = Jensen_Wake_Models(x_grid,y_grid,z_grid,population,turbine,environment,Vw,Wake_Summation_Model);
            Vi = diag(Vw);
            
        elseif ModelSetup.Blockage == 1
            
            %Calculate Vw matrix and inflow velocities
            for j = 1:4
                Vw = Jensen_Wake_Models(x_grid,y_grid,z_grid,population,turbine,environment,Vw,Wake_Summation_Model);
                Vi = diag(Vw);
                
                for i = 1:n.x
                    
                    ct = CT_value(turbine,Vi(i));
                    gamma_t = Tang_vorticity_strength(Vi(i),ct,ModelSetup);
                    %ux = elementary_vortex_cylinder(x_grid,y_grid,z_grid,gamma_t,turbine,environment,xh(i),yh(i),Ground);
                    ux = skewed_vortex_cylinder(x_grid2,y_grid2,z_grid2,gamma_t,ct,turbine,environment,xh(i),yh(i),Ground);
                    ux_induced = ux_induced + ux';
                    
                end
                environment.freestream_velocity = Uo_init + ux_induced;
                ux_induced = zeros(1,n.x);
            end
            Vw = Jensen_Wake_Models(x_grid,y_grid,z_grid,population,turbine,environment,Vw,Wake_Summation_Model);
            Vi = diag(Vw);
        end
        
        
    case 'BPAM'
        
        %Define mesh/grid parameters for wake model
        ModelSetup.Grid_Method.Method = 'polar';
        [x_grid,y_grid,z_grid,weights] = grid_gen(population,ModelSetup);
        
        %Define mesh/grid parameters for blockage model
        ModelSetup.Grid_Method.Method = 'front_row';
        [x_grid2,y_grid2,z_grid2] = grid_gen(population,ModelSetup,idx_front_row);
        
        %initialise velocity variables
        Vw = zeros(n.x,n.x);   %wake velocity influence matrix
        ux_induced = zeros(1,n.x); %induced velocity container
        Uo_init = environment.freestream_velocity;
        environment.freestream_velocity = Uo_init * ones(1,n.x);
        
        if ModelSetup.Blockage == 0
            Vw = Bastankah_Wake_Models(x_grid,y_grid,z_grid,weights,population,turbine,environment,Vw,Wake_Model,Wake_Summation_Model);
            Vi = diag(Vw);
            
        elseif ModelSetup.Blockage == 1
            
            %Calculate Vw matrix and inflow velocities
            for j = 1:4
                Vw = Bastankah_Wake_Models(x_grid,y_grid,z_grid,weights,population,turbine,environment,Vw,Wake_Model,Wake_Summation_Model);
                Vi = diag(Vw);
                
                for i = 1:n.x
                    
                    ct = CT_value(turbine,Vi(i));
                    gamma_t = Tang_vorticity_strength(Vi(i),ct,ModelSetup);
                    %ux = elementary_vortex_cylinder(x_grid2,y_grid2,z_grid2,gamma_t,turbine,environment,xh(i),yh(i),Ground);
                    ux = skewed_vortex_cylinder(x_grid2,y_grid2,z_grid2,gamma_t,ct,turbine,environment,xh(i),yh(i),Ground);
                    ux_induced = ux_induced + ux';
                    
                end
                environment.freestream_velocity = Uo_init + ux_induced;
                ux_induced = zeros(1,n.x);
            end
            Vw = Bastankah_Wake_Models(x_grid,y_grid,z_grid,weights,population,turbine,environment,Vw,Wake_Model,Wake_Summation_Model);
            Vi = diag(Vw);
        end
        
        
    case 'BPAMTI'
        
        %Define mesh/grid parameters for wake model
        ModelSetup.Grid_Method.Method = 'polar';
        [x_grid,y_grid,z_grid,weights] = grid_gen(population,ModelSetup);
        
        %Define mesh/grid parameters for blockage model
        ModelSetup.Grid_Method.Method = 'front_row';
        [x_grid2,y_grid2,z_grid2] = grid_gen(population,ModelSetup,idx_front_row);
        
        %initialise velocity variables
        Vw = zeros(n.x,n.x);   %wake velocity influence matrix
        ux_induced = zeros(1,n.x); %induced velocity container
        Uo_init = environment.freestream_velocity;
        environment.freestream_velocity = Uo_init * ones(1,n.x);
        
        if ModelSetup.Blockage == 0
            Vw = Bastankah_Wake_Models(x_grid,y_grid,z_grid,weights,population,turbine,environment,Vw,Wake_Model,Wake_Summation_Model);
            Vi = diag(Vw);
            
        elseif ModelSetup.Blockage == 1
            
            %Calculate Vw matrix and inflow velocities
            for j = 1:4
                Vw = Bastankah_Wake_Models(x_grid,y_grid,z_grid,weights,population,turbine,environment,Vw,Wake_Model,Wake_Summation_Model);
                Vi = diag(Vw);
                
                for i = 1:n.x
                    
                    ct = CT_value(turbine,Vi(i));
                    gamma_t = Tang_vorticity_strength(Vi(i),ct,ModelSetup);
                    %ux = elementary_vortex_cylinder(x_grid2,y_grid2,z_grid2,gamma_t,turbine,environment,xh(i),yh(i),Ground);
                    ux = skewed_vortex_cylinder(x_grid2,y_grid2,z_grid2,gamma_t,ct,turbine,environment,xh(i),yh(i),Ground);
                    ux_induced = ux_induced + ux';
                    
                end
                environment.freestream_velocity = Uo_init + ux_induced;
                ux_induced = zeros(1,n.x);
            end
            Vw = Bastankah_Wake_Models(x_grid,y_grid,z_grid,weights,population,turbine,environment,Vw,Wake_Model,Wake_Summation_Model);
            Vi = diag(Vw);
        end
        
        
        
        
end

end