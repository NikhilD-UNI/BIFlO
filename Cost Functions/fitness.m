function fval = fitness(x,ModelSetup)
% basic power fitness function
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

%define fixed parameters - we are assuming farms contain only one type of
%turbines
D = ModelSetup.Turbine.Diameter;
% A = pi*D^2 / 4 ;
% Turbine = ModelSetup.Turbine;
rho = ModelSetup.Environment.density;
nTurb = numel(x)/2 ;

tic
N = size(x,1);
fval = zeros(1,N);

for i = 1:N
    Vi = Inflow_Velocity(x(i,:),ModelSetup);
    d = min_distance_finder([x(i,:)],ModelSetup);
    if any(d < 5*D)
        badTurb = numel(find(d<5*D));
        %penalty factor
        p = badTurb/nTurb;
    else
        p = 1;
    end
    %Cp = Cp_value(Turbine,Vi);
    %fval(i) = -sum(0.5*rho*A*Cp.*(Vi.^3))*p;
    fval(i) = -power(Vi,ModelSetup.Turbine,rho)*p;
end

a = toc;
disp(a)
end