function fval = AEP(x,ModelSetup,Farm_orientation_offset)
% Annual Energy Production (AEP) Cost Function
%
%inputs
%-------------------------------------------------------------------------
% x - population set. These are diffrent farm configuration options.
%     Depending if this is 2D or 1D modelling, the length of the row of x will
%     contain either x and y coordinates or just x coordinates. The 
%     dimension of modelling is set by the user and is found in ModelSetup.
%
% ModelSetup - the inputs for the run case. Stored in a class object.
%
% Outputs
% -------------------------------------------------------------------------
% fval - the power output for each farm configuration
%
% Additional Notes:
%
% This cost function evaluates data based of a wind rose that has to be
% preloaded into the configuration of the environmental class. If no wind
% rose data has been uploaded then this function will not execute
% correctly.

%define fixed parameters - we are assuming farms contain only one type of
%turbines
tic
D = ModelSetup.Turbine.Diameter;
A = pi*D^2 / 4 ;
rho = ModelSetup.Environment.density;
u_cut_in  = ModelSetup.Turbine.u_cut_in ;
u_cut_out = ModelSetup.Turbine.u_cut_out ;
% Note N is the number of possible farm layouts.
N = size(x,1);
fval = zeros(1,N);

if nargin<3
    Farm_orientation_offset = 0;
end

switch ModelSetup.CostFunction.Option
    case 1
        
        % AEP model using all wind and velocity values
        n_directions = numel(ModelSetup.Environment.wind_rose.Direction);
        n_speeds     = numel(ModelSetup.Environment.wind_rose.Speeds);
        
        for i = 1:n_directions
            
            ModelSetup.Environment.Wind_direction = ModelSetup.Environment.wind_rose.Direction(i) + Farm_orientation_offset + 90;
            ModelSetup.Environment.TI_a = ModelSetup.Environment.wind_rose.Data.('Average TI')(i);
            
            for j = 1:n_speeds
                
                ModelSetup.Environment.freestream_velocity = ModelSetup.Environment.wind_rose.Speeds(j);
                
                if or(ModelSetup.Environment.freestream_velocity < u_cut_in , ModelSetup.Environment.freestream_velocity > u_cut_out)
                    continue
                end
                
                %calculate the probability of this wind speed at this wind direction
                %occuring throughout the entire wind rose
                
                probability = (table2array(ModelSetup.Environment.wind_rose.Data(i,1+j))/table2array(ModelSetup.Environment.wind_rose.Data(i,end-1)))  * table2array(ModelSetup.Environment.wind_rose.Data(i,end))/100;
                
                for h = 1:N
                    Vi = Inflow_Velocity(x(h,:),ModelSetup);
%                     Cp = Cp_value(ModelSetup.Turbine,Vi);
%                     fval(h) = sum(0.5*rho*A*Cp.*(Vi.^3))*probability + fval(h);
                    fval(h) = power(Vi,ModelSetup.Turbine,rho)*probability + fval(h);
                end
            end
            
            
        end
        
        
        
    case 2
        
        % % AEP model using just the average speed found by the weibul distribution
        n_directions = numel(ModelSetup.Environment.wind_rose.Direction);
        n_speeds     = numel(ModelSetup.Environment.wind_rose.Speeds);
        idx_cut_in = min(find(ModelSetup.Environment.wind_rose.Speeds>=u_cut_in));
        idx_cut_out = max(find(ModelSetup.Environment.wind_rose.Speeds<=u_cut_out));
        
        for i = 1:n_directions
            
            ModelSetup.Environment.Wind_direction = ModelSetup.Environment.wind_rose.Direction(i) + Farm_orientation_offset + 90 ;
            ModelSetup.Environment.TI_a = ModelSetup.Environment.wind_rose.Data.('Average TI')(i);
            ModelSetup.Environment.freestream_velocity = ModelSetup.Environment.wind_rose.Data.('Average Speed')(i);
            
%             calculate the probability of this wind speed at this wind direction
%             occuring throughout the entire wind rose
            
            probability =  sum(table2array(ModelSetup.Environment.wind_rose.Data(i,1+idx_cut_in:1+idx_cut_out)))/table2array(ModelSetup.Environment.wind_rose.Data(i,end-1))    *  (table2array(ModelSetup.Environment.wind_rose.Data(i,end))/100);
            
            for h = 1:N
                Vi = Inflow_Velocity(x(h,:),ModelSetup);
%                 Cp = Cp_value(ModelSetup.Turbine,Vi);
%                 fval(h) = sum(0.5*rho*A*Cp.*(Vi.^3))*probability + fval(h);
                fval(h) = power(Vi,ModelSetup.Turbine,rho)*probability + fval(h);
            end
            
        end
        
        
    case 3 %rapid evaluation based on global properties
        
         ModelSetup.Environment.freestream_velocity = ModelSetup.Environment.wind_rose.GlobalSummary.Mean_Wind_Speed;
         ModelSetup.Environment.Wind_direction =  ModelSetup.Environment.wind_rose.GlobalSummary.Mean_direction;
         ModelSetup.Environment.TI_a = ModelSetup.Environment.wind_rose.GlobalSummary.Mean_TI_a;
         
         for h = 1:N
             Vi = Inflow_Velocity(x(h,:),ModelSetup);
             fval(h) = power(Vi,ModelSetup.Turbine,rho)+ fval(h);
         end
end

    fval = -fval * (365*24);
    a = toc;
    disp(a)
end