function u = WakeSummation_Selection(Vw,Ao,turbine_number,freestream_velocity,Wake_Summation_Model)
% A selection function that executes the appropiate wake summation model.

if isempty(Ao)
    [Vw_size, ~] = size(Vw);
    Ao = ones(Vw_size);
end
    
switch Wake_Summation_Model
    case 'Quadratic'
       u = wake_summation_Quadratic(Vw,Ao,turbine_number,freestream_velocity);
    case 'Linear'
       u = wake_summation_Linear(Vw,Ao,turbine_number,freestream_velocity);
    case 'Energy_Balance'
       u = wake_summation_Energy_Balance(Vw,Ao,turbine_number,freestream_velocity);
end


end