classdef ModelSetup
    properties
        Turbine                                                                     % Turbine Class
        Environment                                                                 % Environment Class
        WakeSummation = 'Quadratic';                                                % Wake Summation model to be used
        Wakemodel = 'Bastankah'    ;                                                % Wake model to be used
        CostFunction = struct('Model','AEP','Option',2)                             % Cost Function Model
        Ground = 0 ;                                                                % ground effect on/off => 1 IS ON, 0 IS OFF
        Grid_Method = struct('Method','cartesian','Resolution',0,'nSectors',0)      % do you want a cartesian or polar mesh setup
        Blockage = 0;                                                               % 1 to include in modelling, 0 to not.
        Gamma_t_model = struct('Momentum1D',0,'Momentum1D_Troldborg',0,...        % Tangential Vorticity strength model
                                'Cal_min_upstream_error',0,'Spera_correction',1)
    end
    methods
        function obj = default_grid_assign(ModelSetup)
            % if user doesn't change the settings default settings are
            % used.
            if strcmp(ModelSetup.Grid_Method.Method,'polar') && (or(ModelSetup.Grid_Method.Resolution == 0,ModelSetup.Grid_Method.nSectors == 0)) 
                ModelSetup.Grid_Method.Resolution = 10;
                ModelSetup.Grid_Method.nSectors   = 36;
                obj = ModelSetup;
                
            else 
                obj = ModelSetup;
            end
            
        end
        
        function gamma_t = Tang_vorticity_strength(Vi,ct,ModelSetup)

            if ModelSetup.Gamma_t_model.Momentum1D
               gamma_t = -Vi*(1 - sqrt(1-ct));
               
            elseif ModelSetup.Gamma_t_model.Momentum1D_Troldborg
               gamma_t = -Vi*(1 - sqrt(1-1.1*ct));
               
            elseif ModelSetup.Gamma_t_model.Cal_min_upstream_error
                gamma_t = -2*Vi* (0.169*ct + 0.400*ct^2 - 0.482*ct^3 + 0.396*ct^4);
                
            elseif ModelSetup.Gamma_t_model.Spera_correction
                gamma_t = -Vi*2*turbine_induction_factor(Vi,ModelSetup.Turbine);
            end
        end
    end
end