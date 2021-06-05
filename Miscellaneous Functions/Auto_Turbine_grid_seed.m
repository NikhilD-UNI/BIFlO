function [x_loc,y_loc] = Auto_Turbine_grid_seed(x_boundary,y_boundary)
%this function seeds a population of grid points within your farm to allow
%for turbine locations to be assigned when adding new turbines. This should
%only be produced once.

% locate constraints 
x_max = max(x_boundary);
x_min = min(x_boundary);
y_max = max(y_boundary);
y_min = min(y_boundary);

diff_x = x_max-x_min;
diff_y = y_max-y_min;


%create a grid within those points
x_grid = x_min:diff_x/99:x_max;
y_grid = y_min:diff_y/99:y_max;

[x_grid,y_grid] = meshgrid(x_grid,y_grid);

x_grid = reshape(x_grid,1,numel(x_grid));
y_grid = reshape(y_grid,1,numel(y_grid));

%find grid points that line in the boundary of this farm
idx_in = inpolygon(x_grid,y_grid, x_boundary,y_boundary);

%return the coordinate of grid points within your boundary

x_loc = x_grid(idx_in);
y_loc = y_grid(idx_in);
end