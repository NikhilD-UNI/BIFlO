function score = population_to_grid_score(x_turb,y_turb,x_grid,y_grid,ModelSetup)
% Assigns a score to each of the grid seed points depending on how far away
% it is from your turbines. The grid point the furthest away from all
% turbines is likely to be an okay location for an initial guess.
%
% input
% -------------------------------------------------------------------------
% x_turb = Turbine locations - x coordinates
% y_turb = Turbine locations - y coordinates
% x_grid = the underlying mesh grid within the farm boundary - xccordinate
% y_grid = the underlying mesh grid within the farm boundary - yccordinate
% 
% Output
% -------------------------------------------------------------------------
% score - the score evelauation for each grid point

n_turbs = numel(x_turb);
n_grid  = numel(x_grid);
D = ModelSetup.Turbine.Diameter;
score = zeros(1,n_grid);

% reshape matrix
x_turb = reshape(x_turb,n_turbs,1);
y_turb = reshape(y_turb,n_turbs,1);
x_grid = reshape(x_grid,1,n_grid);
y_grid = reshape(y_grid,1,n_grid);

% calculate distances
distance = sqrt( ( x_grid - x_turb).^2 + ( y_grid - y_turb ).^2 );
[~ ,idx_col] = find(distance <= 5*D);
if n_turbs == 1
    score = distance;
else
    score = sum(distance);
end
idx_col = unique(idx_col);
score(idx_col) = 0;
    

end