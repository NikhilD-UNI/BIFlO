function [x_grid,y_grid,z_grid,weights] = grid_gen(population,ModelSetup,idx_front_row)
%This function helps generate the appropiate grid setup based on the
%wakemodel being used:
%
% Inputs
%--------------------------------------------------------------------------
% population    - this is the sorted/organised population array 
% Modelsetup    - this is the Modelsetup class
% idx_front_row - index of turbines in the populations that make up the
%                 front row turbines.
% 
% Outputs
%--------------------------------------------------------------------------
% x_grid, y_grid , z_ grid - grid coordinates of points that will be used
%                         to evaluate the flow speeds at in the wake model
%
% Weights                  - a set of weightings for the polar mesh that
%                            will help assist in the weighted averaging of
%                            the flow field across that disc.
%--------------------------------------------------------------------------


turbine     = ModelSetup.Turbine;
environment = ModelSetup.Environment;
Method      = ModelSetup.Grid_Method.Method;

%pull key global variables
Cp_d = turbine.Cp_calibration_distance;
yaw  = environment.Wind_direction ;
D    = turbine.Diameter;
[nTurb,~] = size(population);

%input handling
if nargin < 3
    idx_front_row = [];
end

switch Method
    case 'cartesian'
        if strcmp(ModelSetup.Wakemodel,'Jensen_1D')
            x = population-Cp_d;
            y = 0;
            z = turbine.Hubheight;
            [x_grid,y_grid,z_grid] = meshgrid(x,y,z);
            return
        else
            
            x = population(:,1);
            y = population(:,2);
            z_grid = turbine.Hubheight * ones(length(population(:,1)),1);
            
            
            Cp_d_rotate = rotatez(-yaw,1) * [Cp_d ; 0];
            x_grid = x - Cp_d_rotate(1);
            y_grid = y - Cp_d_rotate(2);
            
            return
        end
        
    case 'polar'
        
        % assign key variables
        R = D/2;
        ModelSetup = default_grid_assign(ModelSetup);  % if polar settings not set
        res = ModelSetup.Grid_Method.Resolution;
        nSect = ModelSetup.Grid_Method.nSectors;
        
        r = [R/res:R/res:R] - R/(2*res) ;
        theta = [360/nSect:360/nSect:360];
        
        nTurbines = length(population(:,1));
        xh = population(:,1);
        yh = population(:,2);
        zh = turbine.Hubheight;
        
        %create a disk of grid points about the point (0,0)
        x = zeros(res,nSect);
        y = r'*cosd(theta);
        z = r'*sind(theta);
        
        %rotate the grid points into the direction of yaw
        if yaw~=0
            for i = 1:numel(x)
                c = rotatez(-yaw) * [x(i);y(i);z(i)];
                x(i) = c(1);
                y(i) = c(2);
                z(i) = c(3);
            end
        end
        
        %for each turbine translate the grid points to the right location
        Cp_d_rotate = rotatez(-yaw,1) * [Cp_d ; 0];
        
        x_grid = zeros(res,nSect,nTurbines);
        y_grid = zeros(res,nSect,nTurbines);
        z_grid = zeros(res,nSect,nTurbines);
        
        for i = 1:nTurbines
%             x_grid(1,:,i) = x_grid(1,:,i) + xh(i) - Cp_d_rotate(1);
%             y_grid(1,:,i) = y_grid(1,:,i) + yh(i) - Cp_d_rotate(2);
%             z_grid(1,:,i) = z_grid(1,:,i) + zh;
            
            x_grid(1:end,:,i) = x + xh(i) - Cp_d_rotate(1);
            y_grid(1:end,:,i) = y + yh(i) - Cp_d_rotate(2);
            z_grid(1:end,:,i) = z + zh;
        end
        
        
        % calculate the weights for an averaging scheme
        r_w = [0:R/res:R];
        theta_rad = deg2rad(theta(1));
        weights   = ones(res,nSect);
        
        for i = 1:length(r_w)-1
            weights(i,:) = weights(i,:) * (0.5* (r_w(i+1)^2 - r_w(i)^2) * theta_rad)/(pi*R^2);
        end
        
        
    case 'front_row'
        
        
        %if user not defined the front row turbines - pull it from pop sort
        if isempty(idx_front_row)
            [~,~,idx_front_row] = population_sort(population,ModelSetup);
        end
        
        Cp_d_rotate = rotatez(-yaw,1) * [2.5*D ; 0];
        
        population_rotated(:,1) = population(:,1) - Cp_d_rotate(1);
        population_rotated(:,2) = population(:,2) - Cp_d_rotate(2);
        
        if or(nTurb == 1, all(population_rotated(:,2) == 0))
            x_grid = population_rotated(:,1);
            y_grid = population_rotated(:,2);
            z_grid = turbine.Hubheight * ones(nTurb,1);
            return
        end
        
        %need to rotate coordinate frame in wrt yaw
        if yaw~=0
            for i = 1:nTurb
                c = rotatez(yaw,1) * [population_rotated(i,1) ; population_rotated(i,2)];
                population_rotated(i,1) = c(1) ;
                population_rotated(i,2) = c(2) ;
            end
        end

        %calculate the x coordinate points for the rake that will define
        %the points where we will evaluate the change in Uo 
        try
            population_rotated(:,1) = interp1(population_rotated(idx_front_row,2),population_rotated(idx_front_row,1),population_rotated(:,2),'linear','extrap');
        catch
            % this catches the exception that lots of turbines have infact
            % been seated in the same location. In which case just return
            % the grids to be defined cpd in front of the turbine 
            
            if yaw~=0
                for i = 1:nTurb
                    c = rotatez(-yaw,1) * [population_rotated(i,1) ; population_rotated(i,2)];
                    population_rotated(i,1) = c(1) ;
                    population_rotated(i,2) = c(2) ;
                end
            end
            
            x_grid = population_rotated(:,1);
            y_grid = population_rotated(:,2);
            z_grid = turbine.Hubheight * ones(nTurb,1);
            
            return
        end
        
        %need to rotate coordinate frame in wrt yaw back to original pos
        if yaw~=0
            for i = 1:nTurb
                c = rotatez(-yaw,1) * [population_rotated(i,1) ; population_rotated(i,2)];
                population_rotated(i,1) = c(1) ;
                population_rotated(i,2) = c(2) ;
            end
        end
        
        x_grid = population_rotated(:,1);
        y_grid = population_rotated(:,2);
        z_grid = turbine.Hubheight * ones(nTurb,1);
end
end