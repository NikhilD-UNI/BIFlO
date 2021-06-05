function population = population_control(population,ModelSetup,x_seed_grid,y_seed_grid,add_take,n_turbines)
%this function adds or takes away a turbine from your population and
%creates a new population genome set.
%
% input
%--------------------------------------------------------------------------
% population = The current population layout in genome sequence [X , Y],
%              where X and Y are the 1D array of x and y coordinate points
%              respectively; 
%
% x_seed_grid = the base grid population that allows for additional turbine
%               placements - x cordinate;
% y_seed_grid = the base grid population that allows for additional turbine
%               placements - y cordinate;
%
% add_take     = flag - if 1 add a turbine, if zero take away a turbine
%
% n_turbines   = instructs how manny turbines to take away or add; 
%
%
% Output
% -------------------------------------------------------------------------
% population = the new population genome string


%% Define any default input settings
if nargin < 6
    %default add or remove a turbine
    n_turbines = 1;
end

if nargin < 5
    %default add a turbine
    n_turbines = 1;
    add_take = 1;
end

[n.x, n.y]  = size(population);
xh = population(1:n.y/2);
yh = population((n.y/2 + 1) : end);

%%
switch add_take
    case 1 %add turbine(s)
        for i = 1:n_turbines
            score = population_to_grid_score(xh,yh,x_seed_grid,y_seed_grid,ModelSetup);
            [p,idx_max] = max(score);
            if p == 0
                break
            else
                xh = [xh x_seed_grid(idx_max)];
                yh = [yh y_seed_grid(idx_max)];
            end
        end
        
    case 0 %remove turbine(s)
        
        for i = 1:n_turbines
            dm = min_distance_finder([xh yh],ModelSetup);
            p = min(dm);
            idx_dup = find(dm==p);
            idx = find(dm~=p);
            if or(numel(idx) == n.y, isempty(idx))
                idx = 1;
            end
            if numel(idx_dup) > 1
                idx = [idx' idx_dup(1:end-1)'];
            end
            
            xh = xh(idx);
            yh = yh(idx);
        end
        
end

population = [xh yh];
end