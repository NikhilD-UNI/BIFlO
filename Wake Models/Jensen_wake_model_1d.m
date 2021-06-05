function Vw = Jensen_wake_model_1d(population,turbine,environment,Vw,Wake_Summation_Model)
% Wake Model Basic - Jensen
%This is a basic jensen wake model that will be used to evaluate the
%turbine inflow velocities.
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
%
%Wake_Summation_Model - Wake Summation Model
%--------------------------------------------------------------------------

%Assign Variables

D = turbine.Diameter;                 
Z_h = turbine.Hubheight;
Cp_d = turbine.Cp_calibartion_distance;
Z_0 = environment.surface_roughness;
Uo  = environment.freestream_velocity;
alpha = 0.5 / log(Z_h/Z_0);    %wake decay coefficient 
[Vw_size ~] = size(Vw);
Ao = ones(Vw_size,Vw_size) - diag([ones(1,Vw_size)]);

%store population locations
location.x = population(:,1);


if Vw(1,1) == 0
    Vw(1,1) = Uo;
end

if Vw(1,1) ~= Uo
   Uo =  Vw(1,1);
end

%calculate the influence coefficients
for i = 1:Vw_size
    if i ~= 1
        %Wake summation model
        Vw(i,i) = WakeSummation_Selection(Vw,Ao,i,Uo,Wake_Summation_Model);
    end
    %array of distances from current turbine to other turbines
    distance = turbine_distance_calculator_1D(location.x(i:end))-Cp_d;
    
    a = turbine_induction_factor(Vw(i,i),turbine);
    if i == Vw_size
    else 
        j = i+1;
         Vw(i,j:end) = Vw(i,i) * (1 - (2*a)./(1+(2*alpha.*distance(2:end))./D));
    end
end
    
end