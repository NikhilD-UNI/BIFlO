function a = turbine_induction_factor(inflow_velocity,turbine)
CT = CT_value(turbine,inflow_velocity);
% Taken from 'Superposition of vortex cylinders for steady and unsteady simulation of rotors of ﬁnite tip-speed ratio' E. Branlard and M. Gaunaa
ac = 0.34 ;

%1D momentum theory
a  = (1-sqrt(1-CT))/2 ; 

% implemnet the Spera Correction for high thrust loading configurations
if a > ac
    a = (CT - 4*ac^2)/(4*(1 - 2*ac));
end
end