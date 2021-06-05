%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Test bed for the ga algorithm in 2d for the WMR farm
clear
clc
%close all

%load in the Turbine and Environment object
load('WMR_DATA.mat')


%Set the operating Model conditions
ModelSetup = ModelSetup;
ModelSetup.Environment = environment;
ModelSetup.Turbine = SWT_6_154;
ModelSetup.Wakemodel = 'Bastankah_TI';
ModelSetup.WakeSummation = 'Quadratic';
ModelSetup.Turbine.Cp_calibration_distance = 0;
ModelSetup.Blockage = 0;
ModelSetup.Ground = 0;
ModelSetup.CostFunction.Option = 2;  

D = ModelSetup.Turbine.Diameter;
%% collection bin for output data
Data = struct();
%%

%% Population
Population = Population_WMH_xy;
%Population = Population_new;

%length of genome of population - 2*number of turbines
nvar = length(Population);

%Define the GA Population size that will search the solution space
N = 100;

%Define the Bounds for the WMR farm - note we are working in a rotated
%frame
lb = [zeros(1,nvar)];
ub = [5700*ones(1,nvar)];

%Define the Objective and constraints Function
FitnessFcn = @(x)AEP(x,ModelSetup,Farm_orientation_offset);
constraint = @(x)nonlinconstraint(x,D,ModelSetup);

%Define the Input options to the GA
opts = optimoptions('ga','PopulationSize',N);
opts.PlotFcn = {@gaplotbestf};%,@gaplotstopping,@gaplotdistance};
%opts.InitialPopulationRange = [lb(1); ub(1)];
opts.FunctionTolerance = 1e-50 ;
opts.InitialPopulationMatrix = Population;
opts.MaxStallGenerations = 300;
opts.MaxGenerations = 200;
opts.CrossoverFraction = 0.85;
opts.EliteCount = 5; %i.e this sets there to 5 elite indiciduals
opts = optimoptions(opts,'UseVectorized',false);
opts = optimoptions(opts,'UseParallel',true);
opts = optimoptions(opts,'MutationFcn',{@mutationadaptfeasible});

%Execute GA
[Population_new,Fval1,exitFlag,Output] = ga(FitnessFcn,nvar,[],[],[],[],lb,ub,constraint,opts);


figure 
plot(Population_new(1:nvar/2),Population_new(nvar/2 +1:nvar),'bx')
hold on
plot(Population(1:nvar/2),Population(nvar/2 + 1:nvar),'kx')

if ModelSetup.Blockage
    
else
    ModelSetup.Blockage = 1;
    fval2 = AEP(Population_new,ModelSetup,Farm_orientation_offset);
end



