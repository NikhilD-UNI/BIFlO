function u_turbine_number = wake_summation_Linear(Vw,Ao,turbine_number,freestream_velocity)
%turbine number is the index of the turbine refernced in the Vw matrix.
%if for example we want the total influence on turbine 2, we want to
%evaluate using the values that are present in that column.

Uo = freestream_velocity;
[Vw_size,~] = size(Vw) ;
% need to find the components of the upstream wake that will influence the
% current turbine
idx = idx_search(Vw,Vw_size,turbine_number);      % doesn't hold for when VW is populated

if isempty(idx)
    u_turbine_number = Uo;
else

    for i = 1:length(idx)
        wake_velocities_pair(i,1:2) = [Vw(idx(i),turbine_number) Vw(idx(i),idx(i))];
    end
    
    % knowing the appropiate wake influence coefficient values.
    u_turbine_number = Uo * (1 - sum(Ao(idx,turbine_number).*(1-(wake_velocities_pair(:,1)./wake_velocities_pair(:,2)))));
    %u_turbine_number = Uo * (1 - sum(Ao(1:j-1,turbine_number).*(1-(wake_velocities_pair(:,1)./Uo)).^2));
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