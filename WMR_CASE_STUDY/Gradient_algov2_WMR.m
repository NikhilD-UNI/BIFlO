%script for gradient descent method v3 - i.e not using goldstein line
%search and simplied version
%
%Nikhil Dawda

clear, clc , close all

%% define model setup
load('WMR_DATA.mat')
%load()

%Set the operating Model conditions
ModelSetup = ModelSetup;
ModelSetup.Turbine = SWT_6_154;
ModelSetup.Environment = environment;
ModelSetup.Environment.surface_roughness = 0.001;
ModelSetup.WakeSummation = 'Linear';
ModelSetup.Wakemodel = 'Bastankah_TI';
ModelSetup.Blockage = 0;
ModelSetup.Ground = 0;
ModelSetup.Turbine.Cp_calibration_distance = 0;

D = ModelSetup.Turbine.Diameter;
Data = struct();
%% define run options

%Define the GA Population size that will search the solution space
N = 100;

%Define the Objective Function
FitnessFcn = @(x)cost(x,ModelSetup,Farm_orientation_offset); %Cost_Model_WMR(x,ModelSetup,Farm_orientation_offset); %
constraint = @(x)nonlinconstraint(x,D,ModelSetup);
%Define the Input options to the GA
opts = optimoptions('ga','PopulationSize',N);
opts.PlotFcn = {@gaplotbestf};%,@gaplotstopping,@gaplotdistance};
%opts.InitialPopulationRange = [lb(1); ub(1)];
opts.FunctionTolerance = 1e-50 ;
opts.MaxStallGenerations = 150;
opts.CrossoverFraction = 0.85;
opts = optimoptions(opts,'UseVectorized',false);
opts = optimoptions(opts,'UseParallel',true);
opts = optimoptions(opts,'MutationFcn',{@mutationadaptfeasible,0.5,0.5});



population = [0 0 0 5700 5700 5700 2850 2850 2850 0 2850 5700 0 2850 5700 2850 0 5700 ];

%%
%get coordinates of boundary points. They should go in a clockwise
%direction
x_boundary = [0 0 5700 5700];
y_boundary = [0 5700 5700 0];
%create seed grid from boundary
[x_loc,y_loc] = Auto_Turbine_grid_seed(x_boundary,y_boundary);

%% run ga algo with current layout
stop = 1e-8;

for j = 1:50
    for i = 1:2
        nvar = length(population);
        opts.InitialPopulationMatrix = population;
        opts.MaxGenerations = 25;
        lb = [zeros(1,nvar)];
        ub = [5700*ones(1,nvar)];
        [population,Fval,exitFlag,Output] = ga(FitnessFcn,nvar,[],[],[],[],lb,ub,constraint,opts);
        
        % store value
        Data.fd_fval(j,i) = Fval;
        Data.nTurbs(j,i)  = nvar/2;
        % Data.farmeff(j,i) =
        ModelSetup.Blockage = 1;
        Fval2 = cost(population,ModelSetup,Farm_orientation_offset);
        ModelSetup.Blockage = 0;
        Data.fd_fval2(j,i) = Fval2;
        % Data.farmeffblock(j,i) = (Fval2/(1e6*365*24))/(nvar/2 *6);
        % add one more turbine to get a new farm layout
        if i == 1
            Data.population_original(j,1:nvar) = population;
            population = population_control(population,ModelSetup,x_loc,y_loc,1,1);
        end
        % place new population into ga solver
    end
    Data.population_exit(j,1:nvar) = population;
    % calculate gradient via finite diffrence - backward difference
    Data.gradient(j) = (Data.fd_fval2(j,2) - Data.fd_fval2(j,1))/1;
    
    disp(Data.gradient(j))
    pause(1)
    
    if abs(Data.gradient(j)) < stop
        exitflag = 1;
        break
    end
    %% Grad descent
    % make an appropiate guess at the number of turbines to be added calculated
    % Use the gradient and a reasonable step size to control the new input.
    
    dk = -Data.gradient(j);
    alpha_k = 4e7;
    
    if Data.gradient(j) > 0
        add_take = 0;
    else
        add_take = 1;
    end
    
    Data.fval_old = Data.fd_fval(2);
    
    newTurbs = round(abs(alpha_k*dk));
    population_new = population_control(population,ModelSetup,x_loc,y_loc,add_take,newTurbs);
    
    nvar = length(population_new);
    opts.InitialPopulationMatrix = population_new;
    opts.MaxGenerations = 15;
    lb = [zeros(1,nvar)];
    ub = [5700*ones(1,nvar)];
    [population,Fval] = ga(FitnessFcn,nvar,[],[],[],[],lb,ub,constraint,opts);
    
    
    Data.fval_new(j) = Fval;
    
    if (Data.fval_new(j) - Data.fval_old) >= 0
        exitflag = 2;
        break
    end
end
   
figure
plot(population(1:nvar/2),population(nvar/2 + 1:end),'kx')