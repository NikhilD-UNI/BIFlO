function A = A_overlap(R_wake,R,distance)
% This function determines the overlapping area of a wake at a given point
% downstream and the swept rotor area.
%--------------------------------------------------------------------------
%inputs 
% R_wake = radius [m] of te wake,
% R      = radius [m] of the turbine that lies in the wake 
% distance = distance [m] between the central wake axis and the turbine hub
%            axis
%--------------------------------------------------------------------------
%Outputs
% A = The overlap area



% offset from distance/2
h = distance /2 ;
x = (R_wake^2 - R^2)/(2*distance) ;
%half angle of sector of overlap in the wake -  origin wake axis
theta = acos((h + x)/R_wake);
%half angle of sector of overlap in the wake -  origin turbine axis of wake covered turbine

if or(R_wake >= distance + R , R_wake <= R)
    A = pi*R^2;
    return
elseif distance >= R + R_wake 
    A = 0;
    return
elseif (h - x) < 0
    alpha = acos(abs(h-x)/R);
    A_wake_segment = 0.5 * R_wake^2 * ((2*theta)-sin(2*theta));
    A_turbine_segment = 0.5 * R^2 * ((2*alpha)-sin(2*alpha));
    A = pi*R^2 - A_turbine_segment + A_wake_segment;
    return
else
    alpha = acos((h-x)/R);
    A_wake_segment = 0.5 * R_wake^2 * ((2*theta)-sin(2*theta));
    A_turbine_segment = 0.5 * R^2 * ((2*alpha)-sin(2*alpha));
    A = A_wake_segment + A_turbine_segment;
end



end