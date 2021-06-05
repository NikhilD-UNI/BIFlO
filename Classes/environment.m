classdef environment
    properties
        surface_roughness    %[m]
        freestream_velocity  %[m/s]
        Wind_direction       %[deg]
        density = 1.225      %[kg/m^3] - density at hub height
        TI_a                 %[%] - Ambient Turbulence Intensity
        
        wind_rose = struct('Data',table(),'Direction',[],'Speeds',[]) % A data container for the wind rose data
    end
    methods
        function obj  = configure_wind_rose_table(environment)
            obj = environment;
            Direction = obj.wind_rose.Direction;
            Speeds    = obj.wind_rose.Speeds;
            
            D_size  = size(Direction);
            S_size  = numel(Speeds);
            
            if D_size(2) > 1
                Direction = Direction';
                D_size  = size(Direction);
            end
            
            obj.wind_rose.Data = table('Size',[D_size(1) S_size+7], 'VariableTypes', repmat({'double'},1,S_size+7));
            
            obj.wind_rose.Data.Properties.VariableNames{1} = 'Directions';
            obj.wind_rose.Data.Directions = Direction;
            
            for i = 1:S_size
                obj.wind_rose.Data.Properties.VariableNames{i+1} = num2str(Speeds(i));
                obj.wind_rose.Data.Properties.VariableUnits{i+1} = 'm/s';
            end
            obj.wind_rose.Data.Properties.VariableNames{end-5} = 'Weibul k';
            obj.wind_rose.Data.Properties.VariableNames{end-4} = 'Weibul c';
            obj.wind_rose.Data.Properties.VariableNames{end-3} = 'Average TI';
            obj.wind_rose.Data.Properties.VariableNames{end-2} = 'Average Speed';
            obj.wind_rose.Data.Properties.VariableNames{end-1} = 'Number of Events';
            obj.wind_rose.Data.Properties.VariableNames{end}   = '% of Global Events';
            
        end
        
        function obj = wind_rose_data_assign(environment,array,TI_array)
            
            obj = environment;
            array_size = size(array);
            Direction = obj.wind_rose.Direction;
            Speeds    = obj.wind_rose.Speeds;
            
            if array_size(1) ~= numel(Direction)
                error('The number of rows in the data array enetered does not match the number of wind direction bins stated')
            end   
            if array_size(2) ~= numel(Speeds)
                error('The number of columns in the data array enetered does not match the number of wind speed bins stated')
            end
            for i = 1: numel(Speeds)
                obj.wind_rose.Data.(num2str(Speeds(i)))(1:end) = array(1:end,i);
            end
            
            obj.wind_rose.Data.('Average TI')(1:end) = TI_array(1:end);
            
        end
        
        function obj = wind_rose_data_processing(environment)
            
            %calculate the basic wind direction bin percentages and sum up
            %total number of events that occured. This is for global
            %analysis
            
            obj = environment;
            Direction = obj.wind_rose.Direction;
            Speeds    = obj.wind_rose.Speeds;
            Speeds    = reshape(Speeds,1,numel(Speeds));
            n_speeds  = numel(Speeds);
            
             array = table2array(obj.wind_rose.Data);
             
             n_global_events = sum(sum(array(:,2:n_speeds+1)));
             
             for i = 1: numel(Direction)
                 obj.wind_rose.Data.('Number of Events')(i) =  sum(array(i,2:n_speeds+1));
                 obj.wind_rose.Data.('% of Global Events')(i) = (obj.wind_rose.Data.('Number of Events')(i)/n_global_events ) * 100;
             end
            
             % For each wind direction bin calculate the weibul k and c
             % parameter
             
             
             %the method of max likelyhood to evaluate the k and c values
             %of the weibul distribution
             
             
             for i = 1:numel(Direction)
                 
                 n = obj.wind_rose.Data.('Number of Events')(i);
                 diff = 0.1;
                 k = 1.55 ;
                 
                 while abs(diff) > 0.01
                     
                     k = k - diff/2 ;
                     term_1 = sum((Speeds.^k).*(log(Speeds)).*array(i,2:n_speeds+1));
                     term_2 = sum((Speeds.^k).*array(i,2:n_speeds+1));
                     term_3 = sum((log(Speeds)).*array(i,2:n_speeds+1));
                     
                     k_dash = ( term_1/term_2  - term_3/n)^(-1) ;
                     
                     diff = k - k_dash;
                 end
                 
                 c = (1/n * sum((Speeds.^k).*array(i,2:n_speeds+1))) ^ (1/k);
                 
                 obj.wind_rose.Data.('Weibul k')(i) = k;
                 obj.wind_rose.Data.('Weibul c')(i) = c;
                 
                 obj.wind_rose.Data.('Average Speed')(i) = c*gamma(1+1/k);
             end
             
             % create a summary section based of the global data
             % calculate the mean wind speed across the year
             
             n_events_per_speed = sum(array(:,2:n_speeds+1));
             
             diff = 0.1;
             k = 1.55 ;
             
             while abs(diff) > 0.01
                 
                 k = k - diff/2 ;
                 term_1 = sum((Speeds.^k).*(log(Speeds)).*n_events_per_speed);
                 term_2 = sum((Speeds.^k).*n_events_per_speed);
                 term_3 = sum((log(Speeds)).*n_events_per_speed);
                 
                 k_dash = ( term_1/term_2  - term_3/n_global_events)^(-1) ;
                 
                 diff = k - k_dash;
             end
             
             c = (1/n_global_events * sum((Speeds.^k).*n_events_per_speed)) ^ (1/k);
             
             obj.wind_rose.GlobalSummary.Mean_Wind_Speed = c*gamma(1+1/k);
             obj.wind_rose.GlobalSummary.Max_Wind_Speed  = max(Speeds);
             obj.wind_rose.GlobalSummary.Min_Wind_Speed  = min(Speeds);
             obj.wind_rose.GlobalSummary.Weibul_k  = k;
             obj.wind_rose.GlobalSummary.Weibul_c  = c;
             
        end
        
        function obj = wind_rose_data_processing_probability_averaging(environment,u_cut_in,u_cut_out)
            
            %calculate the basic wind direction bin percentages and sum up
            %total number of events that occured. Here k and c will be
            %determined using values just within the cut in and cut out
            %range. I.e this is the average power producing velocity
            
            obj = environment;
            Direction = obj.wind_rose.Direction;
            Speeds    = obj.wind_rose.Speeds;
            Speeds    = reshape(Speeds,1,numel(Speeds));
            n_speeds  = numel(Speeds);
            idx_cut_in = min(find(Speeds>=u_cut_in));
            idx_cut_out = max(find(Speeds<=u_cut_out));
            
            
            % Based on the truncated weibul distribution formula we can
            % estimate the average prower producing velocity
            
            a = 0;
            
            for i = 1: numel(Direction)
               k = obj.wind_rose.Data.('Weibul k')(i);
               c = obj.wind_rose.Data.('Weibul c')(i);
               
               term1 = exp(-((u_cut_in-a)/c)^k)/(1-exp(-((u_cut_out-a)/c)^k));
               term2 = gamma(1/k + 1) * gammainc(((u_cut_out-a)/c)^k , 1/k +1) ;
               term3 = gamma(1/k + 1) * gammainc(((u_cut_in-a)/c)^k , 1/k +1) ;
               term4 = gamma(1) * gammainc(((u_cut_out-a)/c)^k , 1) ;
               term5 = gamma(1) * gammainc(((u_cut_in-a)/c)^k , 1);
               u_ave = term1 * ( c*term2 - c*term3 + a*term4 -a*term5 ) ;
                
               obj.wind_rose.Data.('Average Speed')(i) = u_ave ;
            end
        end
        
        function obj = wind_rose_data_power_average_register(environment,V_power_averages)
            obj = environment;
            Direction = obj.wind_rose.Direction;
            for i = 1: numel(Direction)
                obj.wind_rose.Data.('Average Speed')(i) = V_power_averages(i) ;
            end
        end
    end
    
end