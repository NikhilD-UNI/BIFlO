function [ux uy uz] = skewed_vortex_cylinder(x_grid,y_grid,z_grid,gamma_t,ct,turbine,environment,xh,yh,Ground)
% Implementation of the skewed elemenatry vortex cylinder that is used to
% calculate the induced velocity flow field at a specific yaw angle
% Methodology From:
%
%"Assessing the blockage effect of wind turbines and wind farms using an analytical vortex model"
% Authors: Emmanuel Branlard | Alexander R. Meyer Forsting
%
%"Cylindrical vortex wake model: skewed cylinder, application to yawed or tilted rotors"
% Authors: E. Branlard | M. Gaunaa
%
%Date last edited: 17/02/2021
%Nikhil Dawda
%
%Inputs
%--------------------------------------------------------------------------------------------------------------
% x_grid = matrix or array of x coordinate points where you want the induction flow field to be evaluated at. 
% y_grid =      '       '     y  '   '
% z_grid =      '       '     z  '   '
%
%gamma_t = Tangential vorticity on the vortex sheet
%
% ct = thrust coefficient at a given inflow speed 
%
%turbine = turbine object 
%
%environment = environment object, containing the conditions in the environment
%
% xh = x location of the turbine;
% yh = y location of the turbine;
%
%Ground = ground effect. 
%       - 1 = ground effect on
%       - 0 = ground effect off
%
%Outputs
%---------------------------------------------------------------------------------------------------------------
% ux, uy, uz = induced velocity in the x , y , z axis respectively
%
%% Input Handling
if nargin < 10  
    Ground = 0;
end

%% Ground Effect
if Ground
    turbine_mirror = turbine;
    turbine_mirror.Hubheight = -turbine.Hubheight;
    [ux_m uy_m uz_m] = skewed_vortex_cylinder(x_grid,y_grid,z_grid,gamma_t,ct,turbine_mirror,environment,xh,yh);
    [ux uy uz] = skewed_vortex_cylinder(x_grid,y_grid,z_grid,gamma_t,ct,turbine,environment,xh,yh);
    ux = ux + ux_m;
    uy = uy + uy_m;
    uz = uz + uz_m;
    return
end
%% General Parameter Formatting

D = turbine.Diameter;                    %turbine diameter
R = D/2 ;                                %turbine radius
zh= turbine.Hubheight;                   %hub height of turbine
theta_yaw = 0        ;                   %yaw direction (deg2rad(environment.Wind_direction)) - SET TO ZERO (Not including wake steering)
yaw       = environment.Wind_direction;  % yaw direction for grid coordinate rotations.

%skew angle
chi = theta_yaw * (1+0.3*(1-sqrt(1-ct)));

% number of intervals for integration
n_int = 360;
theta = pi/2 + linspace(0,2*pi,n_int);

% change coordinate system to hub centric (i.e (0,0,0) is at turbine hub)
x_grid = x_grid - xh;
y_grid = y_grid - yh;
z_grid = z_grid - zh;

if yaw~=0
    for i = 1:numel(x_grid)
        c = rotatez(yaw) * [x_grid(i);y_grid(i);z_grid(i)];
        x_grid(i) = c(1);
        y_grid(i) = c(2);
        z_grid(i) = c(3);
    end
end

% We define psi = 0 on the y-axis
r_grid   = sqrt(y_grid.^2 + z_grid.^2);
psi_grid = psi_ang(y_grid,z_grid);

% Define constant parameters
m = tan(chi);
c = sqrt(1 + m^2);

% perform point integration
len = numel(x_grid);        %size of array matrix

ux = zeros([size(x_grid)]);      %initialise flow variables
uy = zeros([size(x_grid)]); 
uz = zeros([size(x_grid)]);

    for i = 1:len
        a_2 = R^2 + r_grid(i)^2 + x_grid(i)^2 - 2*r_grid(i)*R*cos(theta - psi_grid(i));
        b   = m*(r_grid(i)*cos(psi_grid(i)) - R*cos(theta)) + x_grid(i);

        a_x = R*(R - r_grid(i)*cos(theta - psi_grid(i)));
        b_x = m*R*cos(theta);

        a_y = R*x_grid(i)*cos(theta);
        b_y = -R*cos(theta);

        a_z = R*x_grid(i)*sin(theta);
        b_z = -R*sin(theta);

        ux(i) = gamma_t/(4*pi) * trapz(theta,(a_x.*c + b_x.*sqrt(a_2))./(a_2.*c - b.*sqrt(a_2)));
        uy(i) = gamma_t/(4*pi) * trapz(theta,(a_y.*c + b_y.*sqrt(a_2))./(a_2.*c - b.*sqrt(a_2)));
        uz(i) = gamma_t/(4*pi) * trapz(theta,(a_z.*c + b_z.*sqrt(a_2))./(a_2.*c - b.*sqrt(a_2)));
    end

    
%% Set flow velocity in the cylinder behind the turbine to zero
if zh<0
    % condition for mirrored image
    idx_r = intersect(find(r_grid >= (-2*zh - R)),find(r_grid <= (-2*zh +R)));
else
    idx_r = find(r_grid <= (R+1));
end
idx_x = find(x_grid >= 0);
idx_xr = intersect(idx_r,idx_x);
ux(idx_xr) = 0;

end