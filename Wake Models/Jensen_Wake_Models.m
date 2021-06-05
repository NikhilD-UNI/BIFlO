function Vw = Jensen_Wake_Models(x_grid,y_grid,z_grid,population,turbine,environment,Vw,Wake_Summation_Model)
%
%Inputs
%--------------------------------------------------------------------------
% (x,y.z)_grid = coordinates of the x, y and z locations respectively.
% population   = post processed population array [N by 2] array
% turbine      = turbine object
% environment  = environment object
% Vw           = wake velocity influence matrix [N by N]
% Wake_Summation_Model = wake summation model to be used - string
%
%output
%--------------------------------------------------------------------------
% Vw           = updated wake velocity influence matrix [N by N]

R  = turbine.Diameter/2 ;
Uo = environment.freestream_velocity;
Ao = zeros(size(Vw)); % initialise overlap area
[Vw_size ~] = size(Vw);

% if Vw(1,1) == 0
    Vw(1,1) = Uo(1);
% end
% if Vw(1,1) ~= Uo
%    Uo = Vw(1,1);
% end


[~,ny] = size(population);
xh = population(:,1);
if ny == 2
    yh = population(:,2);
else
    yh = zeros(1,ny);
end


for i = 1:Vw_size
    if i ~=1
         Vw(i,i) = WakeSummation_Selection(Vw,Ao,i,Uo(i),Wake_Summation_Model);
    end
    
    [Uw, V_inflow, A] = Jensen_Wake_model_VC(x_grid,y_grid,z_grid,Vw(i,i),turbine,environment,xh,yh,i);
    %takes the inflow velocities from wake model and adds it to the Vw container
    a = Vw(i,i);
    Vw(i,:) = V_inflow';
    Vw(i,i) = a;
    %takes the overlapping areas from the wake model and adds it to the Ao container
    Ao(i,:) = A'/(pi*R^2);

end