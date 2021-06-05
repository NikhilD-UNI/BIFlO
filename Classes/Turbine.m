classdef Turbine
    properties
        Hubheight = 0;              %[m] default set to zero
        Diameter  = 0;              %[m] default set to zero
        Ct    =[] ;                 %[m/s , -] defines the relation between free stream and Ct [:,2], first column is velocity, second is Ct
        
        % The user should define either the cp or power curve for the
        % given turbine
        
        Cp    =[] ;                 %[m/s , -] defines the relation between free stream and coefficient of power [:,2], first column is velocity, second is Cp. i.e this is the cp curve
        Power =[] ;                 %[m/s , W] defines the relation between free stream and power [:,2], first column is velocity, second is power. i.e this is the power curve;
        
        
        Cp_calibration_distance = 0; %[m]  the distance in front of the turbine where the mast was located to calculate wind speed for the power curves,
       
        Rated_Power= 0;             %[W] - the rated power of the wind turbine
        Rated_Power_speed = 0;      %[m/s] - Speed at which you hit the rated power of the turbine
        u_cut_in = 4 ;              %[m/s] cut in speed - Default set to 4
        u_cut_out= 25;              %[m/s] cut out speed - Default set to 25
        
        eff_drive = 1;              %Drive train efficiency - defualt value set to 1;
    end
    methods
        
        function r = CT_value(obj,wind_speed)
            %Member Function that conducts the 1D interpolation of
            %coefficient of thrust using the given data for Ct found in the
            %Ct variable
             u = wind_speed;
             u = reshape(u,length(u),1);
             for j = 1:length(u)
                 %error handling
                 try
                     [idx1,idx2] = idx_find(u(j),obj.Ct(:,1));
                 catch
                     if u(j)<min(obj.Ct(:,1))
                         r(j) = obj.Ct(1,2);
                         continue
                     elseif u(j) >= max(obj.Ct(:,1))
                         r(j) = obj.Ct(end,2);
                         continue
                     end
                 end
                 
                 %linear interpolation
                 if idx2~=idx1
                     r(j) = obj.Ct(idx1,2)+( (obj.Ct(idx2,2)-obj.Ct(idx1,2))/(obj.Ct(idx2,1)-obj.Ct(idx1,1))  ) *(u(j)-obj.Ct(idx1,1));
                 else
                     r(j) = obj.Ct(idx1,2);
                 end
             end
        end
        
        function r = Cp_value(obj,wind_speed)
            %Member Function that conducts the 1D interpolation of
            %coefficient of thrust using the given data for Cp found in the
            %Ct variable
            u = wind_speed;
            u = reshape(u,length(u),1);
            for j = 1:length(u)
                %error handling
                if u(j)<min(obj.Cp(:,1))
                    % below cut in speed
                    r(j) = 0;
                    continue
                elseif u(j) == max(obj.Cp(:,1))
                    %below cut out speed
                    r(j) = obj.Cp(end,2);
                    continue
                elseif u(j) > max(obj.Cp(:,1))
                    %below cut out speed
                    r(j) = 0;
                    continue
                end
                
                [idx1,idx2] = idx_find(u(j),obj.Cp(:,1));
                %linear interpolation scheme
                if idx2~=idx1
                    r(j) = obj.Cp(idx1,2)+( (obj.Cp(idx2,2)-obj.Cp(idx1,2))./(obj.Cp(idx2,1)-obj.Cp(idx1,1))  ) .*(u(j)-obj.Cp(idx1,1));
                else
                    r(j) = obj.Cp(idx1,2);
                end
            end
            r = r';
        end
        
        function r = power_value(obj,wind_speed)
            %Member Function that conducts the 1D interpolation of
            %coefficient of thrust using the given data for Cp found in the
            %Cp variable
            u = wind_speed;
            u = reshape(u,length(u),1);
            for j = 1:length(u)
                %error handling
                if u(j)<min(obj.Power(:,1))
                    % below cut in speed
                    r(j) = 0;
                    continue
                elseif u(j) == max(obj.Power(:,1))
                    %below cut out speed
                    r(j) = obj.Power(end,2);
                    continue
                elseif u(j) > max(obj.Power(:,1))
                    %above cut out speed
                    r(j) = 0;
                    continue
                end
                
                [idx1,idx2] = idx_find(u(j),obj.Power(:,1));
                %linear interpolation scheme
                if idx2~=idx1
                    r(j) = obj.Power(idx1,2)+( (obj.Power(idx2,2)-obj.Power(idx1,2))./(obj.Power(idx2,1)-obj.Power(idx1,1))  ) .*(u(j)-obj.Power(idx1,1));
                else
                    r(j) = obj.Power(idx1,2);
                end
            end
            r = r';
        end
        
        function r = inverse_power_value(obj,power,v_mean)
           
            if (power == obj.Rated_Power)
                r = v_mean;
                return
            end
            
            [idx1,idx2] = idx_find(power,obj.Power(:,2));
            
            r = interp1([obj.Power(idx1,2) obj.Power(idx2,2)],[obj.Power(idx1,1) obj.Power(idx2,1)],power);
            return
        end
    
        function p = power(Vi,Turbine,rho)
            
            if isempty(Turbine.Cp)
                power = power_value(Turbine,Vi);
                p = sum(power);
                return
            end
            
            if isempty(Turbine.Power)
                
                D = Turbine.Diameter;
                eta = Turbine.eff_drive;
                A = pi*D^2 / 4 ;
                
                cp = Cp_value(Turbine,Vi);
                p = sum(0.5*rho*eta*A*cp.*(Vi.^3));
                
                return
            end
            
        end
        
        function v_bar = mean_power_producing_velocity(Turbine,wind_speed_bins,frequency,rho)
            
             n_bins                   = numel(wind_speed_bins);
            [n_freq_rows,n_freq_cols] = size(frequency);
            
            wind_speed_bins = reshape(wind_speed_bins,1,n_bins);
            
            idx_cut_in = max(find(wind_speed_bins <= Turbine.u_cut_in));
            idx_cut_out = max(find(wind_speed_bins <= Turbine.u_cut_out));
            
            if n_freq_cols ~= n_bins
                error('The number of wind speed frequencies do not match with the number of wind speeds')
            end
            
            P_tot = 0;
            
            for i = 1: n_freq_rows
                for j = 1:n_bins
                    %calculate the total power that a single turbine can
                    %produce at a set of wind speeds with given frequencies
                    P_tot = P_tot + (power(wind_speed_bins(j),Turbine,rho) * frequency(i,j));
                    
                end
                %calculate the mean power producing wind speed. We will
                %divide P_tot by the number of events where power was
                %produced
                P_bar  = P_tot / (sum(frequency(i,idx_cut_in:idx_cut_out)));
                v_mean = sum(wind_speed_bins(idx_cut_in:idx_cut_out).*(frequency(i,idx_cut_in:idx_cut_out)./(sum(frequency(i,idx_cut_in:idx_cut_out)))) );
                
                v_bar(i) = inverse_power_value(Turbine,P_bar,v_mean);
                P_tot = 0;
            end
                
        end
    
end
end

function [idx1,idx2] = idx_find(value,array)
%searches for the value in array and returns the indexes of the array which
%bound that value
n = length(array);
n_val = length(value);

for j = 1:n_val
    for i = 1:n-1
        if value(j) <array(i+1) && value(j) >array(i)
            idx1(j) =i;
            idx2(j) =i+1;
            break
        end
        if value(j) == array(i)
            idx1(j) =i;
            idx2(j) =i;
            break
        end
    end
end
end