function [ux] = elementary_vortex_cylinder(x_grid,y_grid,z_grid,gamma_t,turbine,environment,xh,yh,Ground)
% This is an implementation of the elementary vortex cylinder model
% (semi-infinite)
% detialed in the paper:
%
%"Assessing the blockage effect of wind turbines and wind farms using an analytical vortex model"
% Authors: Emmanuel Branlard | Alexander R. Meyer Forsting
%
% Date last edited = 16/02/2021
% Nikhil Dawda
% 
%inputs
%---------------------------------------------------------------------------------------------------------
% x_grid = matrix or array of x coordinate points where you want the induction flow field to be evaluated at 
% y_grid =      '       '     y  '   '
% z_grid =      '       '     z  '   '
%
%gamma_t = Tangential vorticity on the vortex sheet
%
%turbine = turbine object 
%environment = environment object
%
% xh = x location of the turbine;
% yh = y location of the turbine;
%
%Ground = ground effect. 
%       - 1 = ground effect on
%       - 0 = ground effect off
%
%Outputs
%-----------------------------------------------------------------------------------------------------------
%ux = the axial induction field

%% Input handling
if (nargin < 9)
    Ground = 0;
end
%% General Parameter formatting

D = turbine.Diameter;     %turbine diameter
R = D/2 ;                 %turbine radius
zh= turbine.Hubheight;    %hub height of turbine
yaw = environment.Wind_direction; 

% ground effect
if Ground
        turbine_mirror = turbine;
        turbine_mirror.Hubheight = -zh;
        ux_mirror = elementary_vortex_cylinder(x_grid,y_grid,z_grid,gamma_t,turbine_mirror,xh,yh);
        ux = ux_mirror + elementary_vortex_cylinder(x_grid,y_grid,z_grid,gamma_t,turbine,xh,yh);
        delete(turbine_mirror);
        return
end

% change coordinate system to hub centric (i.e (0,0,0) is at turbine hub)
x_grid = x_grid - xh;
y_grid = y_grid - yh;
z_grid = z_grid - zh;

for i = 1:numel(x_grid)
    c = rotatez(yaw) * [x_grid(i);y_grid(i);z_grid(i)];
    x_grid(i) = c(1);
    y_grid(i) = c(2);
    z_grid(i) = c(3);
end

r_grid = sqrt(y_grid.^2 + z_grid.^2); %radius away from the central axis of the turbine


%% calculating the paremeters for the xflow field

ux = zeros([size(x_grid)]);           %initialises flow field

%alligned flow for turbine;

%eliptical parameters
k_2 = (4*r_grid*R)./((R+r_grid).^2 + x_grid.^2);  
k0_2 = (4*r_grid*R)./((R+r_grid).^2);             %when x = 0

%constant terms
term_1 = (R - r_grid + abs(R-r_grid))./(2*abs(R-r_grid)) ;
term_1(r_grid == R) = 1/2;                         %accounts for singularity at sheet

term_2 = (x_grid.*sqrt(k_2))./(2*pi*sqrt(r_grid*R)) ;

%Integral terms
[K,~] = ellipke(k_2);                              %complete eliptical integral of the first kind
PI = ellipticPi(k0_2,k_2);                         %complete elliptical integral of the third kind

%integral exception handling
PI(r_grid==R) = 0;    
PI(find(isinf(PI))) = 0;

% evaluate ux velocity
ux = gamma_t/2 * (term_1 + term_2.*(K + ((R-r_grid)./(R+r_grid)).*PI));
ux(r_grid==0) = gamma_t/2 * (1+x_grid(r_grid==0)./sqrt(R^2 + x_grid(r_grid==0).^2));

% if nan's appear at the circumfrence of the rotot plane, set the vortex
% strength to gamma_t/4;
ux(find(isnan(ux))) = gamma_t/4;

%% Set flow velocity in the cylinder behind the turbine to zero
if zh<0
    idx_r = intersect(find(r_grid >= (-2*zh - R)),find(r_grid <= (-2*zh +R)));
else
    idx_r = find(r_grid <= R);
end
idx_x = find(x_grid >= 0);
idx_xr = intersect(idx_r,idx_x);
ux(idx_xr) = 0;

end
