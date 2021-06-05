function [Uw V_inflow A] = Jensen_Wake_model_VC(x_grid,y_grid,z_grid,Ui,turbine,environment,xh,yh,turbine_number)
%A Simple version implementation of the Jensen Wake Model.
%inputs
%--------------------------------------------------------------------------
%x_grid, y_grid, z_grid = coordinate points where you want the wake defecit
%                         to be evaluated at.
%Ui                     = inflow velocity to current turbine
%turbine                = turbine class
%xh                     = turbine farm locations. Turbine number is expected to be linked to
%                           the order entered i.e xh(5) - x coordinate of turbine number 5;
%yh                     = ''
%turbine_number         = The number of the turbine in the farm that is
%                       generating the wake
%
%outputs
%--------------------------------------------------------------------------
% Uw       = velocity defecit values at grid points in the wake
% V_inflow = inflow velocities at the turbines that lie in the wake, 
% A        = % Wake area coverage of turbines that lie in the wake   

% the latter 2 is returned in the same order as the array of turbine
% locations

%
D = turbine.Diameter;
R = D/2;
zh = turbine.Hubheight;
Z_0 = environment.surface_roughness;
yaw = environment.Wind_direction;
alpha = 0.5 / log(zh/Z_0);    %wake decay coefficient 
a = turbine_induction_factor(Ui,turbine);
no_turbines = length(xh);     %no of turbines

%distance of turbines from wake axis 

yh_diff = yh-yh(turbine_number);
xh_diff = xh-xh(turbine_number);

if yaw~=0
    for i = 1:numel(xh_diff)
    c = rotatez(yaw,1) * [xh_diff(i);yh_diff(i)];
    xh_diff(i) = c(1);
    yh_diff(i) = c(2);
    end
end

%Initialise outputs
Uw = zeros([size(x_grid)]);
V_inflow = zeros(no_turbines,1);
A = zeros(no_turbines,1);

%localise coordinates
x = x_grid - xh(turbine_number);
y = y_grid - yh(turbine_number);
z = z_grid - zh;

%% rotate the grid points , so that we are yawing into the wind
for i = 1:numel(x_grid)
    c = rotatez(yaw) * [x(i);y(i);z(i)];
    x(i) = c(1);
    y(i) = c(2);
    z(i) = c(3);
end

r = sqrt(y.^2 + z.^2);

%need to find points in the conical wake
idx_x = find(x >= 0);
idx_x = reshape(idx_x,1,numel(idx_x));
% this is an ineffcient way of doing this, ideally you would know the

for i = [idx_x]
   Dw = D + 2*alpha*x(i);
   if r(i) <= Dw/2
      %Uw(i) = Uo * (1 - (2*a)/(1+2*alpha*x(i)/D)); 
      Uw(i) = Ui * ( - (2*a)/(1+2*alpha*x(i)/D)); % wake defecit values
      
   end
   
end

%If there is only one turbine in the farm, exit function, if not calculate
%for other outputs
if no_turbines == 1
    V_inflow = [];
    A        = [];
    return;
else
    %find turbine index's that lie downstream of current turbine
    idx_xh_diff = find(xh_diff > 0);
    idx_xh_diff = reshape(idx_xh_diff,1,numel(idx_xh_diff));
    
    for i = idx_xh_diff
        Dw = D + 2*alpha*xh_diff(i);
        if (abs(yh_diff(i)) - R) <= Dw/2    %turbine lies in the wake
            %calculate the overlapping area
            A(i)  = A_overlap(Dw/2,R,abs(yh_diff(i)));
            %inflow velocity - velocity defecit scaled 
            V_inflow(i) = Ui * (1 - (2*a)/(1+2*alpha*xh_diff(i)/D));
        end
    end
end


end

