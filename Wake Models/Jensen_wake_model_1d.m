
function Vw = Jensen_wake_model_1d(population,turbine,environment,Vw,Wake_Summation_Model)
% Wake Model Basic - Jensen
%This is a basic jensen wake model that will be used to evaluate the
%turbine inflow velocities for a 1D config.
%
%input arguments
%--------------------------------------------------------------------------
%population  - Defines the array containing the coordinates of the turbines.
%              Fisrt column defines the x coordinate, second column defines 
%              the y coordinate.
%
%turbine     - name of object that defines the turbine parameters
%
%environment - object containing the data for the environment of operation
%              for these turbines
%
%Vw          - Defines the velocity wake influence matrix that will be used
%              to evealuate the inflow velocities at each turbine. 
%--------------------------------------------------------------------------

%Assign Variables

D = turbine.Diameter;                 
Z_h = turbine.Hubheight;
Z_0 = environment.surface_roughness;
alpha = 0.5 / log(Z_h/Z_0);    %wake decay coefficient 
[Vw_size ~] = size(Vw);
Ao = eye(Vw_size);

%store population locations
location.x = population(:,1);

%calculate the influence coefficients initialise 
Vw(1,1) = environment.freestream_velocity;
for i = 1:Vw_size
    if i ~= 1
        Vw(i,i) = WakeSummation_Selection(Vw,Ao,i,freestream_velocity,Wake_Summation_Model);
    end
    %array of distances from current turbine to other turbines
    distance = turbine_distance_calculator_1D(location.x(i:end));
    
    a = turbine_induction_factor(Vw(i,i),turbine);
    if i == Vw_size
    else 
        j = i+1;
         Vw(i,j:end) = Vw(i,i) * (1 - (2*a)./(1+(2*alpha.*distance(2:end))./D));
    end
end
    
end