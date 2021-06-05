function [Uw, V_inflow , TI_plus] = Bastankah_TI_wake(x_grid,y_grid,z_grid,Ui,TI,turbine,environment,xh,yh,turbine_number,comp_level,weights)
% Bastankah Port Agel model with Crespo Derivation for added TI.  [Uw V_inflow A]
%
% Methodology from:
% Analytical Modeling of Wind Farms: A New Approach for Power Prediction
% Amin Niayifar,and Fernando Porté-Agel 
%--------------------------------------------------------------------------
% x_grid, y_grid, z_grid = coordinate points where you want the wake defecit
%                         to be evaluated at.
% Ui                     = inflow velocity to current turbine
% TI                     = Maximum added turbulence intensity on previous models
% turbine                = turbine class
% environment            = environment class
% xh                     = turbine farm locations. Turbine number is expected to be linked to
%                           the order entered i.e xh(5) - x coordinate of turbine number 5;
% yh                     = ''
% turbine_number         = The number of the turbine in the farm that is
%                       generating the wake
%
% comp_level             = if set to 1, function will be configured to
%                          solve at grid points which are located on the
%                          discs that lie directly in the wake downstream.
%
% Weights                = the weights required for numerical averaging as
%                          given by the grid_gen function
%
%outputs
%--------------------------------------------------------------------------
% Uw       = velocity defecit values at grid points in the wake
% V_inflow = inflow velocities at the turbines that lie in the wake, 
% TI_plus  = Added Turbulence intensity from this turbine on any downstream turbine
  


% input and error handling
if nargin < 11
    comp_level = 0;
    weights = [];
end
if nargin == 11 && comp_level ~= 0
    error('It appears that the weights required for numerical averaging have not been entered. Please pull them from the grid_gen function and pass the weight matrix into input 10')
end
if nargin == 12 && comp_level ~= 0 && isempty(weights)
   warning('It appears that the weights required for numerical averaging have not been entered. Please pull them from the grid_gen function and pass the weight matrix into input 10. The averaged inflow velocities will not be returned as an array of zeros') 
end

% assign key variables
D = turbine.Diameter;
R = D/2;
zh = turbine.Hubheight;
Uo = environment.freestream_velocity;    %Note this is the expected global farm freestream 
TI_a = environment.TI_a;

if numel(Uo) == 1
else
    Uo = Uo(turbine_number);
end

Z_0 = environment.surface_roughness;
yaw = environment.Wind_direction;
no_turbines = length(xh);                %no of turbines


Ct = CT_value(turbine,Ui);
a  = turbine_induction_factor(Ui,turbine);
Beta = 0.5 * (1+sqrt(1-Ct))/(sqrt(1-Ct)) ;
e    = 0.2 * sqrt(Beta);
%k_star = 0.03;

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
TI_plus  = zeros(no_turbines,1);

%localise coordinates
x = x_grid - xh(turbine_number);
y = y_grid - yh(turbine_number);
z = z_grid - zh;

%% rotate the grid points , so that we are yawing into the wind
if yaw~=0
    for i = 1:numel(x_grid)
        c = rotatez(yaw) * [x(i);y(i);z(i)];
        x(i) = c(1);
        y(i) = c(2);
        z(i) = c(3);
    end
end

r = sqrt(y.^2 + z.^2);



if comp_level       
% Turbine in wake only calculation. Note this works on the assumption a
% polar grid is being used.
    
    if no_turbines == 1
        return
    end
    
    idx_xh_diff = find(xh_diff > 0) ;
    idx_xh_diff = reshape(idx_xh_diff,1,numel(idx_xh_diff));
    
    % calculate k* with added empirical turbulence intensity model
    % note this is the maximum wake TI just ahead of the rotor
    % plane
    TI_w     = sqrt(TI^2 + TI_a^2);
    k_star = 0.003678 + 0.3837*TI_w;
    
    sig_do_turbine = k_star*(xh_diff(idx_xh_diff)/D) + e;
    
    % 99.5% of the gauss distribution is assumed to define the spanwise
    % extent of the wake.
    Dw = 2.58*D*sig_do_turbine;           
    
    j = 1;
    for i = idx_xh_diff
        if (abs(yh_diff(i)) - R) <= Dw(j)/2
            
            sig_do = k_star*(x(:,:,i)/D) + e;           %sigma/do
            C      = 1 - sqrt(1-(Ct./(8*(sig_do).^2)));
            
            %calculate wake velocity defecit scalar
            dUw_Ui = C.*exp( - (r(:,:,i).^2)./(2*(sig_do*D).^2)  );
            idx_dUw_Ui = find(dUw_Ui < 0.0001);
            U = Ui * (1 - C.*exp( - (r(:,:,i).^2)./(2*(sig_do*D).^2)  ));
            U([idx_dUw_Ui]) = Uo ; 
            Uw(:,:,i)  = real(U);
            
            %calculate the average inflow velocity
            V_inflow(i)  = sum(sum(Uw(:,:,i) .* weights));
            
            %Calculate added TI at downstream turbines 
            TI_p    = 0.73*a^(0.8325) * TI_a^(0.0325) * (xh_diff(i)/D)^ (-0.32);
            Aw         = A_overlap(Dw(j)/2 , D/2 , abs(yh_diff(i))) ;
            TI_plus(i) = (Aw*4)/(pi*D^2) * TI_p;
            
        end
        j = j+1;
    end
    
else % this is for comp level = 0. I.e if you want to do a complete gridded domain evaluation;
  
    %need to find points in the wake
    idx_x = find(x >= 0);
    idx_x = reshape(idx_x,1,numel(idx_x));
    
    TI_w     = sqrt(TI^2 + TI_a^2);
    k_star = 0.003678 + 0.3837*TI_w;
    
    for i = [idx_x]
        sig_do = k_star*(x(i)/D) + e;                            %sigma/do
        C      = 1 - sqrt(1-(Ct/(8*(sig_do)^2)));
        Uw(i)  = Ui * (-C*exp( - (r(i)^2)/(2*(sig_do*D)^2)  ));      
    end
    
    
    idx_xh_diff = find(xh_diff > 0) ;
    idx_xh_diff = reshape(idx_xh_diff,1,numel(idx_xh_diff));
    sig_do_turbine = k_star*(xh_diff(idx_xh_diff)/D) + e;
    Dw = 2.58*D*sig_do_turbine;        
    
    j = 1;
    for i = idx_xh_diff
        if (abs(yh_diff(i)) - R) <= Dw(j)/2
            TI_p    = 0.66*a^(0.8325) * TI_a^(0.0325) * (xh_diff(i)/D)^ (-0.32);
            Aw         = A_overlap(Dw(j)/2 , D/2 , abs(yh_diff(i))) ;
            TI_plus(i) = (Aw*4)/(pi*D^2) * TI_p;
        end
        j= j+1;
    end
    
    % calculate the averaged inflow velocity
    if isempty(weights) == 0
        
        idx_xh_diff = find(xh_diff > 0) ;
        idx_xh_diff = reshape(idx_xh_diff,1,numel(idx_xh_diff));
        
        sig_do_turbine = k_star*(xh_diff(idx_xh_diff)/D) + e;
        Dw = 2.58*D*sig_do_turbine;
        
        j = 1;
        for i = idx_xh_diff
            if (abs(yh_diff(i)) - R) <= Dw(j)/2
                
                sig_do = k_star*(x(:,:,i)/D) + e;
                C      = 1 - sqrt(1-(Ct./(8*(sig_do).^2)));
                
                %calculate wake velocity defecit scalar
                dUw_Ui = C.*exp( - (r(:,:,i).^2)./(2*(sig_do*D).^2)  );
                idx_dUw_Ui = find(dUw_Ui < 0.0001);
                U = Ui * (1 - C.*exp( - (r(:,:,i).^2)./(2*(sig_do*D).^2)  ));
                U([idx_dUw_Ui]) = Uo ;
                Uw_temp(:,:,i)  = U;
                
                %calculate the average inflow velocity
                V_inflow(i)  = sum(sum(Uw_temp(:,:,i) .* weights));
                
            end
            j = j+1;
        end
    end
end

end