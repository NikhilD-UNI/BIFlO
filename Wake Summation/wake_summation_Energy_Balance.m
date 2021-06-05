function u_turbine_number = wake_summation_Energy_Balance(Vw,Ao,turbine_number,freestream_velocity)
%Function that evaluates the superposition of wakes in accordance to the
%energy balance model
%
%Inputs
%--------------------------------------------------------------------------
%Vw             - Wake Velocity Influence Matrix
%
%turbine_number - the turbine you are looking to calculate the inflow
%                 velocity at (stored at Vw(i,i), where i = turbine number.
%
%freestream_velocity
%
%
%Output
%--------------------------------------------------------------------------
%u_turbine_number = the inflow velocity at the number turbine

Uo = freestream_velocity;
[Vw_size,~] = size(Vw);
% need to find the components of the upstream wake that will influence the
% current turbine
idx = idx_search(Vw,Vw_size,turbine_number);      % doesn't hold for when VW is populated

if isempty(idx)
    u_turbine_number = Uo;
else
%collect relevant data in those column and rows. Column 1 - u_ji, column 2  u_j

    for i = 1:length(idx)
        wake_velocities_pair(i,1:2) = [Vw(idx(i),turbine_number) Vw(idx(i),idx(i))];
    end
%Implement Energy Balance Model
u_turbine_number = sqrt(Uo^2-sum( Ao(idx,turbine_number).*(wake_velocities_pair(:,2).^2  - wake_velocities_pair(:,1).^2)));
%u_turbine_number = sqrt(Uo^2-sum(   Uo^2  - wake_velocities_pair(:,1).^2));
end
end

function idx = idx_search(Vw,Vw_size,turbine_number)
j = 1;
idx =[];
for i = 1:Vw_size
    if (Vw(i,turbine_number) == 0) && (i~= turbine_number)
        continue
    elseif (Vw(i,turbine_number) ~= 0) && (i~= turbine_number)
        idx(j) = i;
        j = j+1;
    end
end
end