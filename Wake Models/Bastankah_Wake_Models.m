function Vw = Bastankah_Wake_Models(x_grid,y_grid,z_grid,weights,population,turbine,environment,Vw,Wake_Model,Wake_Summation_Model)

[Vw_size, ~] = size(Vw);
xh = population(:,1);
yh = population(:,2);

TI = zeros([size(Vw)]);

Uo = environment.freestream_velocity;
% Turbine 1 should always be at free stream velocity conditions
% if Vw(1,1) == 0
    Vw(1,1) = Uo(1);
% end
% If the value at turbine 1 is different from Uo as a result of blockage,
% update Uo.
% if Vw(1,1) ~= Uo
%    Uo = Vw(1,1);
% end

if strcmp(Wake_Model,'BPAM')

    for i = 1:Vw_size

        if i ~=1
            Vw(i,i) = WakeSummation_Selection(Vw,[],i,Uo(i),Wake_Summation_Model);
        end

        [~, V_inflow] = Bastankah_original_wake(x_grid,y_grid,z_grid,Vw(i,i),turbine,environment,xh,yh,i,1,weights);

        %takes the inflow velocities from wake model and adds it to the Vw container
        a = Vw(i,i);
        Vw(i,:) = V_inflow';
        Vw(i,i) = a;
    end

elseif strcmp(Wake_Model,'BPAMTI')

    for i = 1:Vw_size

        if i ~=1
            Vw(i,i) = WakeSummation_Selection(Vw,[],i,Uo(i),Wake_Summation_Model);
        end

        TI_temp = max(TI(:,i));
        [~, V_inflow , TI_plus] = Bastankah_TI_wake(x_grid,y_grid,z_grid,Vw(i,i),TI_temp,turbine,environment,xh,yh,i,1,weights);
        TI(i,:) = TI_plus';

        %takes the inflow velocities from wake model and adds it to the Vw container
        a = Vw(i,i);
        Vw(i,:) = V_inflow';
        Vw(i,i) = a;
    end

end

end